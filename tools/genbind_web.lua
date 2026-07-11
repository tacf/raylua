--[[
  Generates a standard-Lua (non-FFI) binding layer for raylib/raymath/rlgl/
  gestures/rcamera/physac/raygui, for the Emscripten/web build.

  Unlike the desktop build (which hands LuaJIT raw C function pointers via
  FFI), this emits real lua_CFunction wrapper functions using the standard
  Lua C API, marshaling raylib structs to/from plain Lua tables.

  Coverage is best-effort and mechanical:
    - scalars, strings, known structs (by value or by pointer), and
      pointer+count array pairs are fully marshaled.
    - unknown pointer types pass through opaquely (lightuserdata) so values
      can still be round-tripped between calls even when Lua can't inspect
      their fields.
    - functions taking a callback typedef or using varargs (TextFormat,
      TraceLog) are skipped; calling them from Lua raises a clear runtime
      error rather than failing to build or behaving unpredictably.

  Usage:
    lua genbind_web.lua <out_dir> <tools_dir> <module.h> [<module.h> ...]

  Writes <out_dir>/web_structs.h, web_structs.c, web_bind.c
]]

local meta = require "web_meta"

local out_dir = assert(arg[1], "usage: genbind_web.lua <out_dir> <tools_dir> <module.h...>")
local tools_dir = assert(arg[2], "usage: genbind_web.lua <out_dir> <tools_dir> <module.h...>")

local modules = {}
for i = 3, #arg do modules[#modules + 1] = arg[i] end
assert(#modules > 0, "usage: genbind_web.lua <out_dir> <tools_dir> <module.h...>")

--------------------------------------------------------------------------
-- Header parsing
--------------------------------------------------------------------------

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function normspace(s)
  return (trim(s):gsub("%s+", " "))
end

-- Parses a single "TYPE name" fragment (as found in a param list, or the
-- "RETTYPE FuncName" head of a declaration). Returns {base=, ptr=, name=}.
-- `name` is "" for the return-type case (no trailing identifier consumed).
local function parse_typed(fragment, want_name)
  fragment = normspace(fragment)

  local is_const = false
  if fragment:match("^const%s+") then
    is_const = true
    fragment = normspace(fragment:sub(7))
  end

  local base, name
  if want_name then
    base, name = fragment:match("^(.-)([%a_][%w_]*)%s*$")
    if not base then
      return nil
    end
  else
    base, name = fragment, ""
  end

  base = trim(base)
  local ptr = 0
  while base:sub(-1) == "*" do
    ptr = ptr + 1
    base = trim(base:sub(1, -2))
  end
  base = normspace(base)

  if base == "" then return nil end
  return { base = base, ptr = ptr, name = name, const = is_const }
end

-- Parses one declaration line, e.g.
--   "unsigned char *LoadFileData(const char *fileName, int *dataSize)"
-- Returns {name=, ret={base,ptr,const}, params={ {base,ptr,const,name}, ... }, vararg=bool}
local function parse_decl(line)
  local head, params_str = line:match("^(.-)%(([^%)]*)%)%s*$")
  if not head then return nil end

  local ret = parse_typed(head, true)
  if not ret then return nil end
  local fname = ret.name
  ret.name = nil

  params_str = trim(params_str)
  local params = {}
  local vararg = false

  if params_str ~= "" and params_str ~= "void" then
    for p in (params_str .. ","):gmatch("(.-),") do
      p = trim(p)
      if p ~= "" then
        if p == "..." then
          vararg = true
        else
          local pt = parse_typed(p, true)
          if not pt then return nil end
          params[#params + 1] = pt
        end
      end
    end
  end

  return { name = fname, ret = ret, params = params, vararg = vararg }
end

--------------------------------------------------------------------------
-- Collect declarations from all modules (first definition wins, matching
-- the native genbind.lua's dedup rule for functions shared across headers).
--------------------------------------------------------------------------

local decls = {}
local decl_order = {}

for _, modname in ipairs(modules) do
  local path = tools_dir .. "/" .. modname .. ".h"
  local f = assert(io.open(path, "r"), "cannot open " .. path)
  for line in f:lines() do
    line = trim(line)
    if line ~= "" and line:sub(1, 1) ~= "#" and not line:match("^typedef%s+") then
      local d = parse_decl(line)
      if d and not decls[d.name] then
        decls[d.name] = d
        decl_order[#decl_order + 1] = d.name
      elseif not d then
        io.stderr:write(string.format("genbind_web: WARN unparsed line in %s: %s\n", modname, line))
      end
    end
  end
  f:close()
end

--------------------------------------------------------------------------
-- Struct codegen (web_structs.h / web_structs.c)
--------------------------------------------------------------------------

local function field_c_decl(f)
  local k = f.kind
  if type(k) == "string" then
    local ctype = ({
      int = "int", uint = "unsigned int", short = "short", ushort = "unsigned short",
      long = "long", float = "float", double = "double", bool = "bool", uchar = "unsigned char",
    })[k]
    return ctype
  elseif k.struct then
    return k.struct
  elseif k.charbuf then
    return nil -- handled specially (fixed array)
  elseif k.numarr or k.structarr then
    return nil -- handled specially (fixed array)
  end
  error("unknown field kind for " .. f.name)
end

local struct_h = {}
local struct_c = {}

struct_h[#struct_h + 1] = [[
/* Auto-generated by tools/genbind_web.lua. Do not edit by hand. */
#ifndef RAYLUA_WEB_STRUCTS_H
#define RAYLUA_WEB_STRUCTS_H

#include <lua.h>
#include <raylib.h>
#include <raymath.h>
#include <rlgl.h>
#include <rgestures.h>

]]

struct_c[#struct_c + 1] = [[
/* Auto-generated by tools/genbind_web.lua. Do not edit by hand. */
#include "web_structs.h"
#include "web_marshal.h"
#include <string.h>
#include <stdlib.h>

]]

-- Canonical struct list (resolve aliases once, keep first-seen order).
local canon_order = {}
local canon_seen = {}
for name, def in pairs(meta.structs) do
  if type(def) == "table" then
    local fields, canon = meta.resolve(name)
    if fields and not canon_seen[canon] then
      canon_seen[canon] = true
      canon_order[#canon_order + 1] = canon
    end
  end
end
table.sort(canon_order)

for _, sname in ipairs(canon_order) do
  local fields = select(1, meta.resolve(sname))

  struct_h[#struct_h + 1] = string.format(
    "void web_check_%s(lua_State *L, int idx, %s *out);\n" ..
    "void web_push_%s(lua_State *L, const %s *v);\n" ..
    "void web_writeback_%s(lua_State *L, int idx, const %s *v);\n" ..
    "%s *web_array_get_%s(lua_State *L, int idx, int *count);\n\n",
    sname, sname, sname, sname, sname, sname, sname, sname
  )

  -- web_check_X: read fields from Lua table at idx into *out
  local check = {}
  check[#check + 1] = string.format("void web_check_%s(lua_State *L, int idx, %s *out) {\n", sname, sname)
  check[#check + 1] = "  memset(out, 0, sizeof(*out));\n"
  check[#check + 1] = "  if (!lua_istable(L, idx)) return;\n"
  for _, f in ipairs(fields) do
    local k = f.kind
    if type(k) == "string" then
      if k == "opaque" then
        -- opaque pointer fields are not settable from Lua field syntax; skip.
      elseif k == "opaqueval" then
        check[#check + 1] = string.format('  lua_getfield(L, idx, "%s");\n', f.name)
        check[#check + 1] = string.format("  web_check_opaque_struct(L, lua_gettop(L), &out->%s, sizeof(out->%s));\n", f.name, f.name)
        check[#check + 1] = "  lua_pop(L, 1);\n"
      else
        check[#check + 1] = string.format('  lua_getfield(L, idx, "%s");\n', f.name)
        if k == "bool" then
          check[#check + 1] = string.format("  out->%s = lua_toboolean(L, -1);\n", f.name)
        else
          check[#check + 1] = string.format("  out->%s = (%s)lua_tonumber(L, -1);\n", f.name, field_c_decl(f))
        end
        check[#check + 1] = "  lua_pop(L, 1);\n"
      end
    elseif k.struct then
      local _, canon = meta.resolve(k.struct)
      check[#check + 1] = string.format('  lua_getfield(L, idx, "%s");\n', f.name)
      check[#check + 1] = string.format("  web_check_%s(L, lua_gettop(L), &out->%s);\n", canon, f.name)
      check[#check + 1] = "  lua_pop(L, 1);\n"
    elseif k.charbuf then
      check[#check + 1] = string.format('  lua_getfield(L, idx, "%s");\n', f.name)
      check[#check + 1] = string.format(
        "  { const char *s = lua_tostring(L, -1); if (s) { strncpy(out->%s, s, %d - 1); } }\n",
        f.name, k.charbuf)
      check[#check + 1] = "  lua_pop(L, 1);\n"
    elseif k.numarr then
      local ctype = ({ int = "int", float = "float", uint = "unsigned int" })[k.numarr] or k.numarr
      check[#check + 1] = string.format('  lua_getfield(L, idx, "%s");\n', f.name)
      check[#check + 1] = string.format(
        "  if (lua_istable(L, -1)) { for (int i = 0; i < %d; i++) { lua_rawgeti(L, -1, i + 1); out->%s[i] = (%s)lua_tonumber(L, -1); lua_pop(L, 1); } }\n",
        k.n, f.name, ctype)
      check[#check + 1] = "  lua_pop(L, 1);\n"
    elseif k.structarr then
      local _, canon = meta.resolve(k.structarr)
      check[#check + 1] = string.format('  lua_getfield(L, idx, "%s");\n', f.name)
      check[#check + 1] = string.format(
        "  if (lua_istable(L, -1)) { for (int i = 0; i < %d; i++) { lua_rawgeti(L, -1, i + 1); web_check_%s(L, lua_gettop(L), &out->%s[i]); lua_pop(L, 1); } }\n",
        k.n, canon, f.name)
      check[#check + 1] = "  lua_pop(L, 1);\n"
    elseif k == "opaque" then
      -- opaque pointer fields are not settable from Lua field syntax; skip.
    end
  end
  check[#check + 1] = "}\n\n"
  struct_c[#struct_c + 1] = table.concat(check)

  -- web_push_X / web_writeback_X share field-pushing logic; writeback
  -- assumes a table already exists at idx (mutates in place), push creates
  -- a brand-new table and leaves it on top of the stack.
  local function emit_field_set(buf, target_expr, f)
    local k = f.kind
    if type(k) == "string" then
      if k == "opaque" then
        buf[#buf + 1] = string.format('  web_push_opaque(L, (void*)%s.%s); lua_setfield(L, %s, "%s");\n', "v", f.name, target_expr, f.name)
      elseif k == "opaqueval" then
        buf[#buf + 1] = string.format('  web_push_opaque_struct(L, &%s.%s, sizeof(%s.%s)); lua_setfield(L, %s, "%s");\n', "v", f.name, "v", f.name, target_expr, f.name)
      elseif k == "bool" then
        buf[#buf + 1] = string.format('  lua_pushboolean(L, %s.%s); lua_setfield(L, %s, "%s");\n', "v", f.name, target_expr, f.name)
      else
        buf[#buf + 1] = string.format('  lua_pushnumber(L, (double)%s.%s); lua_setfield(L, %s, "%s");\n', "v", f.name, target_expr, f.name)
      end
    elseif k.struct then
      local _, canon = meta.resolve(k.struct)
      buf[#buf + 1] = string.format("  web_push_%s(L, &v.%s); lua_setfield(L, %s, \"%s\");\n", canon, f.name, target_expr, f.name)
    elseif k.charbuf then
      buf[#buf + 1] = string.format(
        '  lua_pushlstring(L, %s.%s, strnlen(%s.%s, %d)); lua_setfield(L, %s, "%s");\n',
        "v", f.name, "v", f.name, k.charbuf, target_expr, f.name)
    elseif k.numarr then
      buf[#buf + 1] = string.format('  lua_newtable(L); for (int i = 0; i < %d; i++) { lua_pushnumber(L, (double)%s.%s[i]); lua_rawseti(L, -2, i + 1); } lua_setfield(L, %s, "%s");\n',
        k.n, "v", f.name, target_expr, f.name)
    elseif k.structarr then
      local _, canon = meta.resolve(k.structarr)
      buf[#buf + 1] = string.format('  lua_newtable(L); for (int i = 0; i < %d; i++) { web_push_%s(L, &%s.%s[i]); lua_rawseti(L, -2, i + 1); } lua_setfield(L, %s, "%s");\n',
        k.n, canon, "v", f.name, target_expr, f.name)
    end
  end

  local push = {}
  push[#push + 1] = string.format("void web_push_%s(lua_State *L, const %s *vp) {\n", sname, sname)
  push[#push + 1] = string.format("  %s v = *vp;\n", sname)
  push[#push + 1] = "  lua_newtable(L);\n"
  for _, f in ipairs(fields) do emit_field_set(push, "-2", f) end
  push[#push + 1] = "}\n\n"
  struct_c[#struct_c + 1] = table.concat(push)

  local wb = {}
  wb[#wb + 1] = string.format("void web_writeback_%s(lua_State *L, int idx, const %s *vp) {\n", sname, sname)
  wb[#wb + 1] = string.format("  %s v = *vp;\n", sname)
  wb[#wb + 1] = "  if (!lua_istable(L, idx)) return;\n"
  for _, f in ipairs(fields) do emit_field_set(wb, "idx", f) end
  wb[#wb + 1] = "}\n\n"
  struct_c[#struct_c + 1] = table.concat(wb)

  -- web_array_get_X: reads a 1-indexed Lua array table of struct-tables
  -- into a malloc'd C array (caller must free()).
  local arr = {}
  arr[#arr + 1] = string.format("%s *web_array_get_%s(lua_State *L, int idx, int *count) {\n", sname, sname)
  arr[#arr + 1] = "  int n = 0;\n"
  arr[#arr + 1] = "  if (lua_istable(L, idx)) n = (int)lua_rawlen(L, idx);\n"
  arr[#arr + 1] = string.format("  %s *out = (%s*)malloc(sizeof(%s) * (n > 0 ? n : 1));\n", sname, sname, sname)
  arr[#arr + 1] = "  for (int i = 0; i < n; i++) {\n"
  arr[#arr + 1] = "    lua_rawgeti(L, idx, i + 1);\n"
  arr[#arr + 1] = string.format("    web_check_%s(L, lua_gettop(L), &out[i]);\n", sname)
  arr[#arr + 1] = "    lua_pop(L, 1);\n"
  arr[#arr + 1] = "  }\n"
  arr[#arr + 1] = "  *count = n;\n"
  arr[#arr + 1] = "  return out;\n"
  arr[#arr + 1] = "}\n\n"
  struct_c[#struct_c + 1] = table.concat(arr)
end

struct_h[#struct_h + 1] = "#endif\n"

--------------------------------------------------------------------------
-- rl.new(structName, ...) positional constructor table (web_ctors.lua)
--------------------------------------------------------------------------

local ctors_lua = {}
ctors_lua[#ctors_lua + 1] = "-- Auto-generated by tools/genbind_web.lua. Do not edit by hand.\n"
ctors_lua[#ctors_lua + 1] = "local RAYLUA_STRUCT_FIELDS = {\n"
for name in pairs(meta.structs) do
  local fields = meta.resolve(name)
  if fields then
    local names = {}
    for _, f in ipairs(fields) do names[#names + 1] = string.format("%q", f.name) end
    ctors_lua[#ctors_lua + 1] = string.format("  %s = { %s },\n", name, table.concat(names, ", "))
  end
end
ctors_lua[#ctors_lua + 1] = "}\n\n"
ctors_lua[#ctors_lua + 1] = [[
function rl.new(name, ...)
  local fields = RAYLUA_STRUCT_FIELDS[name]
  if not fields then
    error("rl.new: unknown struct '" .. tostring(name) .. "' (web build)")
  end
  local t = {}
  local n = select("#", ...)
  for i, fname in ipairs(fields) do
    if i <= n then t[fname] = (select(i, ...)) end
  end
  return t
end

function rl.ref(obj)
  return obj
end

-- A few example scripts construct structs as `rl.Vector2(x, y)` instead of
-- `rl.new("Vector2", x, y)` (a callable-ctype idiom from the FFI build).
-- Mirror that here wherever it doesn't collide with a real bound function.
for sname in pairs(RAYLUA_STRUCT_FIELDS) do
  if rl[sname] == nil then
    rl[sname] = function(...) return rl.new(sname, ...) end
  end
end
]]

--------------------------------------------------------------------------
-- Function classification
--------------------------------------------------------------------------

local function base_kind(base)
  if meta.scalar_types[base] then return "scalar", meta.scalar_types[base] end
  if meta.callback_types[base] then return "callback" end
  if meta.opaque_handle_types[base] then return "handle" end
  local fields, canon = meta.resolve(base)
  if fields then return "struct", canon end
  return "unknown"
end

local function looks_like_count(name)
  local l = name:lower()
  return l:match("count$") or l:match("size$") or l:match("length$") or l:match("num$")
end

-- Builds the "slot" list for a function's parameters. Returns nil if the
-- function can't be bound at all (callback param, or return is a callback).
local function classify_params(params)
  local slots = {}
  local i = 1
  while i <= #params do
    local p = params[i]
    local bk, bd = base_kind(p.base)
    if bk == "callback" then return nil end

    if p.ptr == 0 then
      if bk == "handle" then
        slots[#slots + 1] = { kind = "opaque", p = p }
      elseif bk == "scalar" then
        slots[#slots + 1] = { kind = "scalar", p = p, sk = bd }
      elseif bk == "struct" then
        slots[#slots + 1] = { kind = "structval", p = p, canon = bd }
      else
        slots[#slots + 1] = { kind = "genericval", p = p }
      end
      i = i + 1
    else
      local nextp = params[i + 1]
      local pairable = p.const and p.ptr == 1 and nextp and nextp.ptr == 0
        and meta.scalar_types[nextp.base] and (meta.scalar_types[nextp.base] == "int" or meta.scalar_types[nextp.base] == "uint")
        and looks_like_count(nextp.name)

      if p.ptr >= 2 then
        slots[#slots + 1] = { kind = "opaqueptr", p = p }
        i = i + 1
      elseif bk == "callback" then
        return nil
      elseif p.base == "char" or p.base == "unsigned char" then
        if pairable then
          slots[#slots + 1] = { kind = "stringinput", p = p, cp = nextp }
          i = i + 2
        elseif not p.const then
          slots[#slots + 1] = { kind = "textbuf", p = p }
          i = i + 1
        else
          slots[#slots + 1] = { kind = "string", p = p }
          i = i + 1
        end
      elseif bk == "scalar" then
        if pairable then
          slots[#slots + 1] = { kind = "arrayinput_scalar", p = p, cp = nextp, sk = bd }
          i = i + 2
        else
          slots[#slots + 1] = { kind = "scalarbox", p = p, sk = bd }
          i = i + 1
        end
      elseif bk == "struct" then
        if pairable then
          slots[#slots + 1] = { kind = "arrayinput_struct", p = p, cp = nextp, canon = bd }
          i = i + 2
        else
          slots[#slots + 1] = { kind = "structref", p = p, canon = bd }
          i = i + 1
        end
      elseif bk == "handle" then
        slots[#slots + 1] = { kind = "opaqueptr", p = p }
        i = i + 1
      else
        slots[#slots + 1] = { kind = "opaqueptr", p = p }
        i = i + 1
      end
    end
  end
  return slots
end

local function classify_return(ret, slots)
  if ret.ptr == 0 then
    if ret.base == "void" then return { kind = "void" } end
    local bk, bd = base_kind(ret.base)
    if bk == "callback" then return nil end
    if bk == "handle" then return { kind = "opaqueret", stars = 0 } end
    if bk == "scalar" then return { kind = "scalarret", sk = bd } end
    if bk == "struct" then return { kind = "structret", canon = bd } end
    return { kind = "genericret", base = ret.base }
  else
    local bk = base_kind(ret.base)
    if bk == "callback" then return nil end
    if ret.ptr == 1 and ret.base == "char" then
      return { kind = "cstringret" }
    end
    -- Combo: T* return + trailing int/uint scalarbox param -> build a Lua
    -- string (char/uchar element) or array table (numeric/struct element)
    -- sized from that out-param, then MemFree() the raylib-owned buffer.
    local last = slots[#slots]
    if ret.ptr == 1 and last and last.kind == "scalarbox" and (last.sk == "int" or last.sk == "uint") then
      if ret.base == "unsigned char" then
        return { kind = "stringret_sized", size_slot = last }
      end
      local bk2, bd2 = base_kind(ret.base)
      if bk2 == "scalar" then
        return { kind = "arrayret_sized_scalar", sk = bd2, size_slot = last }
      elseif bk2 == "struct" then
        return { kind = "arrayret_sized_struct", canon = bd2, size_slot = last }
      end
    end
    return { kind = "opaqueret", stars = ret.ptr }
  end
end

--------------------------------------------------------------------------
-- Wrapper codegen (web_bind.c)
--------------------------------------------------------------------------

local bind_c = {}
bind_c[#bind_c + 1] = [[
/* Auto-generated by tools/genbind_web.lua. Do not edit by hand. */
#include <stdlib.h>
#include <string.h>
#include <lauxlib.h>
#include <lua.h>

#include <raylib.h>
#include <raymath.h>
#include <rlgl.h>
#include <rcamera.h>
#include <rgestures.h>

#define RAYGUI_IMPLEMENTATION
#define RAYGUIAPI static
#include <raygui.h>

#define PHYSAC_IMPLEMENTATION
#define PHYSACDEF static
#include <physac.h>

#include "web_structs.h"
#include "web_marshal.h"

]]

local scalar_ctype = {
  int = "int", uint = "unsigned int", short = "short", ushort = "unsigned short",
  long = "long", float = "float", double = "double", bool = "bool", uchar = "unsigned char",
}

local supported = {}
local skipped = {}

for _, name in ipairs(decl_order) do
  local d = decls[name]
  if d.vararg then
    skipped[#skipped + 1] = name
    goto continue
  end

  local slots = classify_params(d.params)
  if not slots then
    skipped[#skipped + 1] = name
    goto continue
  end

  local retinfo = classify_return(d.ret, slots)
  if not retinfo then
    skipped[#skipped + 1] = name
    goto continue
  end

  local lines = {}
  local call_args = {}
  local writeback = {}
  local cleanup = {}
  local argi = 0

  for si, s in ipairs(slots) do
    local var = "a" .. si
    if s.kind == "scalar" then
      local ctype = scalar_ctype[s.sk]
      argi = argi + 1
      if s.sk == "bool" then
        lines[#lines + 1] = string.format("  %s %s = lua_toboolean(L, %d);\n", ctype, var, argi)
      else
        lines[#lines + 1] = string.format("  %s %s = (%s)luaL_checknumber(L, %d);\n", ctype, var, ctype, argi)
      end
      call_args[#call_args + 1] = var

    elseif s.kind == "structval" then
      argi = argi + 1
      lines[#lines + 1] = string.format("  %s %s; web_check_%s(L, %d, &%s);\n", s.p.base, var, s.canon, argi, var)
      call_args[#call_args + 1] = var

    elseif s.kind == "genericval" then
      argi = argi + 1
      lines[#lines + 1] = string.format("  %s %s; web_check_opaque_struct(L, %d, &%s, sizeof(%s));\n", s.p.base, var, argi, var, s.p.base)
      call_args[#call_args + 1] = var

    elseif s.kind == "opaque" then
      argi = argi + 1
      lines[#lines + 1] = string.format("  %s %s = (%s)web_check_opaque(L, %d);\n", s.p.base, var, s.p.base, argi)
      call_args[#call_args + 1] = var

    elseif s.kind == "opaqueptr" then
      argi = argi + 1
      local stars = string.rep("*", s.p.ptr)
      lines[#lines + 1] = string.format("  %s%s %s = (%s%s)web_check_opaque(L, %d);\n", s.p.base, stars, var, s.p.base, stars, argi)
      call_args[#call_args + 1] = var

    elseif s.kind == "string" then
      argi = argi + 1
      lines[#lines + 1] = string.format("  const char *%s = luaL_checkstring(L, %d);\n", var, argi)
      call_args[#call_args + 1] = s.p.const and var or ("(char*)" .. var)

    elseif s.kind == "textbuf" then
      argi = argi + 1
      lines[#lines + 1] = string.format("  char %s[4096]; web_textbox_get(L, %d, %s, sizeof(%s));\n", var, argi, var, var)
      call_args[#call_args + 1] = (s.p.base == "unsigned char") and ("(unsigned char*)" .. var) or var
      writeback[#writeback + 1] = string.format("  web_textbox_set(L, %d, %s);\n", argi, var)

    elseif s.kind == "stringinput" then
      argi = argi + 1
      lines[#lines + 1] = string.format("  size_t %s_n; const char *%s = luaL_checklstring(L, %d, &%s_n);\n", var, var, argi, var)
      local elemcast = (s.p.base == "unsigned char") and ("(const unsigned char*)" .. var) or var
      call_args[#call_args + 1] = elemcast
      call_args[#call_args + 1] = string.format("(%s)%s_n", scalar_ctype[meta.scalar_types[s.cp.base]], var)

    elseif s.kind == "scalarbox" then
      argi = argi + 1
      local ctype = scalar_ctype[s.sk]
      if s.sk == "bool" then
        lines[#lines + 1] = string.format("  %s %s = web_box_get_bool(L, %d);\n", ctype, var, argi)
        writeback[#writeback + 1] = string.format("  web_box_set_bool(L, %d, %s);\n", argi, var)
      else
        lines[#lines + 1] = string.format("  %s %s = (%s)web_box_get_num(L, %d);\n", ctype, var, ctype, argi)
        writeback[#writeback + 1] = string.format("  web_box_set_num(L, %d, (double)%s);\n", argi, var)
      end
      call_args[#call_args + 1] = "&" .. var
      s.var = var -- referenced by size-combo return handling

    elseif s.kind == "structref" then
      argi = argi + 1
      lines[#lines + 1] = string.format("  %s %s; web_check_%s(L, %d, &%s);\n", s.p.base, var, s.canon, argi, var)
      call_args[#call_args + 1] = "&" .. var
      writeback[#writeback + 1] = string.format("  web_writeback_%s(L, %d, &%s);\n", s.canon, argi, var)

    elseif s.kind == "arrayinput_scalar" then
      argi = argi + 1
      local fn = ({ int = "web_array_get_int", uint = "web_array_get_uint", float = "web_array_get_float", uchar = "web_array_get_uchar", ushort = "web_array_get_ushort" })[s.sk]
        or "web_array_get_int"
      local ctype = scalar_ctype[s.sk]
      lines[#lines + 1] = string.format("  int %s_n = 0; %s *%s = %s(L, %d, &%s_n);\n", var, ctype, var, fn, argi, var)
      call_args[#call_args + 1] = var
      call_args[#call_args + 1] = string.format("(%s)%s_n", scalar_ctype[meta.scalar_types[s.cp.base]], var)
      cleanup[#cleanup + 1] = string.format("  free(%s);\n", var)

    elseif s.kind == "arrayinput_struct" then
      argi = argi + 1
      lines[#lines + 1] = string.format("  int %s_n = 0; %s *%s = web_array_get_%s(L, %d, &%s_n);\n", var, s.p.base, var, s.canon, argi, var)
      call_args[#call_args + 1] = var
      call_args[#call_args + 1] = string.format("(%s)%s_n", scalar_ctype[meta.scalar_types[s.cp.base]], var)
      cleanup[#cleanup + 1] = string.format("  free(%s);\n", var)
    end
  end

  local call_expr = string.format("%s(%s)", name, table.concat(call_args, ", "))

  local push_lines = {}
  local nret = 0

  if retinfo.kind == "void" then
    lines[#lines + 1] = "  " .. call_expr .. ";\n"
  elseif retinfo.kind == "scalarret" then
    local ctype = scalar_ctype[retinfo.sk]
    lines[#lines + 1] = string.format("  %s ret = %s;\n", ctype, call_expr)
    if retinfo.sk == "bool" then
      push_lines[#push_lines + 1] = "  lua_pushboolean(L, ret);\n"
    else
      push_lines[#push_lines + 1] = "  lua_pushnumber(L, (double)ret);\n"
    end
    nret = 1
  elseif retinfo.kind == "structret" then
    lines[#lines + 1] = string.format("  %s ret = %s;\n", d.ret.base, call_expr)
    push_lines[#push_lines + 1] = string.format("  web_push_%s(L, &ret);\n", retinfo.canon)
    nret = 1
  elseif retinfo.kind == "genericret" then
    lines[#lines + 1] = string.format("  %s ret = %s;\n", d.ret.base, call_expr)
    push_lines[#push_lines + 1] = string.format("  web_push_opaque_struct(L, &ret, sizeof(ret));\n")
    nret = 1
  elseif retinfo.kind == "cstringret" then
    lines[#lines + 1] = string.format("  const char *ret = %s;\n", call_expr)
    push_lines[#push_lines + 1] = "  lua_pushstring(L, ret ? ret : \"\");\n"
    nret = 1
  elseif retinfo.kind == "stringret_sized" then
    lines[#lines + 1] = string.format("  unsigned char *ret = %s;\n", call_expr)
    push_lines[#push_lines + 1] = string.format(
      "  if (ret) { lua_pushlstring(L, (const char*)ret, (size_t)%s); MemFree(ret); } else { lua_pushnil(L); }\n",
      retinfo.size_slot.var)
    nret = 1
  elseif retinfo.kind == "arrayret_sized_scalar" then
    local ctype = scalar_ctype[retinfo.sk]
    lines[#lines + 1] = string.format("  %s *ret = %s;\n", ctype, call_expr)
    push_lines[#push_lines + 1] = string.format(
      "  lua_newtable(L); if (ret) { for (int i = 0; i < %s; i++) { lua_pushnumber(L, (double)ret[i]); lua_rawseti(L, -2, i + 1); } MemFree(ret); }\n",
      retinfo.size_slot.var)
    nret = 1
  elseif retinfo.kind == "arrayret_sized_struct" then
    lines[#lines + 1] = string.format("  %s *ret = %s;\n", d.ret.base, call_expr)
    push_lines[#push_lines + 1] = string.format(
      "  lua_newtable(L); if (ret) { for (int i = 0; i < %s; i++) { web_push_%s(L, &ret[i]); lua_rawseti(L, -2, i + 1); } MemFree(ret); }\n",
      retinfo.size_slot.var, retinfo.canon)
    nret = 1
  elseif retinfo.kind == "opaqueret" then
    local stars = string.rep("*", retinfo.stars)
    lines[#lines + 1] = string.format("  %s%s ret = %s;\n", d.ret.base, stars, call_expr)
    push_lines[#push_lines + 1] = "  web_push_opaque(L, (void*)ret);\n"
    nret = 1
  end

  local body = {}
  body[#body + 1] = string.format("static int l_%s(lua_State *L) {\n", name)
  for _, l in ipairs(lines) do body[#body + 1] = l end
  for _, l in ipairs(push_lines) do body[#body + 1] = l end
  for _, l in ipairs(writeback) do body[#body + 1] = l end
  for _, l in ipairs(cleanup) do body[#body + 1] = l end
  body[#body + 1] = string.format("  return %d;\n", nret)
  body[#body + 1] = "}\n\n"

  bind_c[#bind_c + 1] = table.concat(body)
  supported[#supported + 1] = name

  ::continue::
end

bind_c[#bind_c + 1] = "static int l_web_unsupported(lua_State *L) {\n"
bind_c[#bind_c + 1] = "  return luaL_error(L, \"rl.%s is not available in the web build\", lua_tostring(L, lua_upvalueindex(1)));\n"
bind_c[#bind_c + 1] = "}\n\n"

bind_c[#bind_c + 1] = "static const luaL_Reg web_bind_supported[] = {\n"
for _, name in ipairs(supported) do
  bind_c[#bind_c + 1] = string.format('  { "%s", l_%s },\n', name, name)
end
bind_c[#bind_c + 1] = "  { NULL, NULL }\n};\n\n"

bind_c[#bind_c + 1] = "static const char *web_bind_unsupported[] = {\n"
for _, name in ipairs(skipped) do
  bind_c[#bind_c + 1] = string.format('  "%s",\n', name)
end
bind_c[#bind_c + 1] = "  NULL\n};\n\n"

bind_c[#bind_c + 1] = [[
void web_bind_register(lua_State *L, int tbl_index) {
  if (tbl_index < 0) tbl_index = lua_gettop(L) + tbl_index + 1;
  for (int i = 0; web_bind_supported[i].name; i++) {
    lua_pushcfunction(L, web_bind_supported[i].func);
    lua_setfield(L, tbl_index, web_bind_supported[i].name);
  }
  for (int i = 0; web_bind_unsupported[i]; i++) {
    lua_pushstring(L, web_bind_unsupported[i]);
    lua_pushcclosure(L, l_web_unsupported, 1);
    lua_setfield(L, tbl_index, web_bind_unsupported[i]);
  }
}
]]

--------------------------------------------------------------------------
-- Write output files
--------------------------------------------------------------------------

local function write_file(path, chunks)
  local f = assert(io.open(path, "wb"))
  f:write(table.concat(chunks))
  f:close()
end

write_file(out_dir .. "/web_structs.h", struct_h)
write_file(out_dir .. "/web_structs.c", struct_c)
write_file(out_dir .. "/web_bind.c", bind_c)
write_file(out_dir .. "/web_ctors.lua", ctors_lua)

io.stderr:write(string.format(
  "genbind_web: %d functions bound, %d skipped (out of %d parsed)\n",
  #supported, #skipped, #decl_order))
