#!/usr/bin/env lua
-- Update bindings script - extracts API from raylib headers
-- Handles:
--   * C/C++ comments
--   * multi-line declarations
--   * inline RMAPI function definitions from raymath.h
--   * callback typedefs needed by LuaJIT FFI
-- Skips:
--   * implementation blocks from header-only libs (except raymath)
--   * macros/preprocessor noise
--   * static/inline helpers
--   * va_list / TraceLogCallback

local API_PREFIXES = {
  "RLAPI", "CONFAPI", "GLAPI", "RMAPI", "PHYSACDEF", "RAYGUIAPI"
}

local CALLBACK_TYPEDEFS = {
  LoadFileDataCallback = true,
  SaveFileDataCallback = true,
  LoadFileTextCallback = true,
  SaveFileTextCallback = true,
  AudioCallback = true,
}

local ALLOW_BARE_PROTOTYPES = {
  gestures = true,
  rcamera = true,
}

local BAD_NAMES = {
  ["if"] = true,
  ["for"] = true,
  ["while"] = true,
  ["switch"] = true,
  ["return"] = true,
}

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function normalize_decl(s)
  s = trim(s)
  s = s:gsub("%s+", " ")
  s = s:gsub("%s*;%s*$", "")
  return s
end

local function has_api_prefix(line)
  for _, prefix in ipairs(API_PREFIXES) do
    if line:match("^" .. prefix .. "%s+") then
      return prefix
    end
  end
  return nil
end

local function strip_c_comments(content)
  local out = {}
  local i = 1
  local len = #content
  local state = "normal"

  while i <= len do
    local c = content:sub(i, i)
    local n = (i < len) and content:sub(i + 1, i + 1) or ""

    if state == "normal" then
      if c == '"' then
        out[#out + 1] = c
        state = "string"
        i = i + 1
      elseif c == "'" then
        out[#out + 1] = c
        state = "char"
        i = i + 1
      elseif c == "/" and n == "/" then
        out[#out + 1] = " "
        state = "line_comment"
        i = i + 2
      elseif c == "/" and n == "*" then
        out[#out + 1] = " "
        state = "block_comment"
        i = i + 2
      else
        out[#out + 1] = c
        i = i + 1
      end
    elseif state == "string" then
      out[#out + 1] = c
      if c == "\\" and i < len then
        out[#out + 1] = content:sub(i + 1, i + 1)
        i = i + 2
      elseif c == '"' then
        state = "normal"
        i = i + 1
      else
        i = i + 1
      end
    elseif state == "char" then
      out[#out + 1] = c
      if c == "\\" and i < len then
        out[#out + 1] = content:sub(i + 1, i + 1)
        i = i + 2
      elseif c == "'" then
        state = "normal"
        i = i + 1
      else
        i = i + 1
      end
    elseif state == "line_comment" then
      if c == "\n" or c == "\r" then
        out[#out + 1] = c
        state = "normal"
      end
      i = i + 1
    elseif state == "block_comment" then
      if c == "*" and n == "/" then
        state = "normal"
        i = i + 2
      else
        if c == "\n" or c == "\r" then
          out[#out + 1] = c
        end
        i = i + 1
      end
    end
  end

  return table.concat(out)
end

local function cut_at_implementation_section(module_name, content)
  -- raymath public API lives in RMAPI inline definitions, so do NOT cut it.
  if module_name == "raymath" then
    return content
  end

  local cut = nil
  local patterns = {
    "\n%s*#if%s+defined%s*%([%w_]+_IMPLEMENTATION%)",
    "\n%s*#ifdef%s+[%w_]+_IMPLEMENTATION",
    "\n%s*#elif%s+defined%s*%([%w_]+_IMPLEMENTATION%)",
  }

  for _, pat in ipairs(patterns) do
    local s = content:find(pat)
    if s and (not cut or s < cut) then
      cut = s
    end
  end

  if cut then
    return content:sub(1, cut - 1)
  end

  return content
end

local function should_skip_statement(stmt)
  return stmt == ""
      or stmt:match("^#")
      or stmt:match("^enum%s")
      or stmt:match("^struct%s")
      or stmt:match("^union%s")
      or stmt:match("^static%s")
      or stmt:match("^inline%s")
      or stmt:match("^extern%s+\"C\"")
      or stmt:match("QUERY")
      or stmt:match("__stdcall")
      or stmt:match("WIN32")
      or stmt:match("_WIN32")
      or stmt:match("DLL%-export")
      or stmt:match("va_list")
      or stmt:match("TraceLogCallback")
end

local function callback_typedef_name(stmt)
  if not stmt:match("^typedef%s+") then
    return nil
  end
  return stmt:match("%(%s*%*%s*([%w_]+)%s*%)%s*%(")
end

local function function_name_from_decl(stmt)
  local before = stmt:match("^(.-)%s*%(")
  if not before then
    return nil
  end
  return before:match("([_%a][_%w]*)%s*$")
end

local function bare_prototype_name(stmt)
  if stmt:match("^typedef%s+") then return nil end
  if stmt:match("^static%s+") then return nil end
  if stmt:match("^inline%s+") then return nil end
  if stmt:match("=") then return nil end
  if stmt:match("%(%s*%*") then return nil end
  if not stmt:match("%)") then return nil end

  local name = function_name_from_decl(stmt)
  if not name or BAD_NAMES[name] then
    return nil
  end

  return name
end

local function candidate_starts_decl(module_name, line)
  if has_api_prefix(line) then
    return true
  end

  if line:match("^typedef%s+") and callback_typedef_name(line) then
    return true
  end

  if ALLOW_BARE_PROTOTYPES[module_name] and bare_prototype_name(line) then
    return true
  end

  return false
end

local function finalize_buffer(buf)
  buf = trim(buf)
  if buf == "" then return nil end

  buf = trim((buf:gsub("%s*{%s*$", "")))
  buf = trim((buf:gsub("%s*;%s*$", "")))

  if buf == "" then return nil end
  return buf
end

local function collect_declarations(module_name, content)
  local decls = {}
  local buffer = nil

  for raw_line in content:gmatch("[^\r\n]+") do
    local line = trim(raw_line)

    if line == "" or line:match("^#") then
      -- skip
    else
      if buffer then
        buffer = buffer .. " " .. line

        if line:find("{", 1, true) then
          local decl = finalize_buffer(buffer)
          if decl then decls[#decls + 1] = decl end
          buffer = nil
        elseif line:find(";", 1, true) then
          local decl = finalize_buffer(buffer)
          if decl then decls[#decls + 1] = decl end
          buffer = nil
        end
      else
        if candidate_starts_decl(module_name, line) then
          if line:find("{", 1, true) or line:find(";", 1, true) then
            local decl = finalize_buffer(line)
            if decl then decls[#decls + 1] = decl end
          else
            buffer = line
          end
        end
      end
    end
  end

  return decls
end

local function extract_api(module_name, source_file, output_file)
  local source = io.open(source_file, "rb")
  if not source then
    print("ERROR: Cannot open " .. source_file)
    return false
  end

  local content = source:read("*all")
  source:close()

  content = strip_c_comments(content)
  content = cut_at_implementation_section(module_name, content)

  local typedefs = {}
  local funcs = {}
  local typedef_order = {}
  local func_order = {}
  local seen_typedef = {}
  local seen_func = {}

  for _, stmt in ipairs(collect_declarations(module_name, content)) do
    stmt = trim(stmt)

    if not should_skip_statement(stmt) then
      local cb_name = callback_typedef_name(stmt)

      if cb_name and CALLBACK_TYPEDEFS[cb_name] then
        local decl = normalize_decl(stmt)
        if not seen_typedef[cb_name] then
          seen_typedef[cb_name] = true
          typedefs[cb_name] = decl
          typedef_order[#typedef_order + 1] = cb_name
        end
      else
        local prefix = has_api_prefix(stmt)
        local func = nil
        local name = nil

        if prefix then
          func = trim(stmt:gsub("^" .. prefix .. "%s+", "", 1))
          name = function_name_from_decl(func)
        elseif ALLOW_BARE_PROTOTYPES[module_name] then
          name = bare_prototype_name(stmt)
          if name then
            func = stmt
          end
        end

        if func and name and not BAD_NAMES[name] and name:sub(1, 2) ~= "__" then
          func = normalize_decl(func)
          func = func:gsub("^extern%s+", "")
          if not seen_func[name] then
            seen_func[name] = true
            funcs[name] = func
            func_order[#func_order + 1] = name
          end
        end
      end
    end
  end

  table.sort(typedef_order)
  table.sort(func_order)

  local out = io.open(output_file, "w")
  if not out then
    print("ERROR: Cannot open " .. output_file)
    return false
  end

  for _, name in ipairs(typedef_order) do
    out:write(typedefs[name], "\n")
  end

  for _, name in ipairs(func_order) do
    out:write(funcs[name], "\n")
  end

  out:close()
  print("Updated " .. output_file .. " with " .. #typedef_order .. " typedefs and " .. #func_order .. " functions")
  return true
end

local modules = {
  { name = "api",      source = "raylib/src/raylib.h",    output = "tools/api.h" },
  { name = "raymath",  source = "raylib/src/raymath.h",   output = "tools/raymath.h" },
  { name = "rlgl",     source = "raylib/src/rlgl.h",      output = "tools/rlgl.h" },
  { name = "gestures", source = "raylib/src/rgestures.h", output = "tools/gestures.h" },
  { name = "rcamera",  source = "raylib/src/rcamera.h",   output = "tools/rcamera.h" },
  { name = "physac",   source = "physac/src/physac.h",    output = "tools/physac.h" },
  { name = "raygui",   source = "raygui/src/raygui.h",    output = "tools/raygui.h" },
}

local mode = arg[1] or "all"

if mode == "all" then
  print("Updating all bindings...")
  for _, m in ipairs(modules) do
    extract_api(m.name, m.source, m.output)
  end
  print("All bindings updated!")
elseif mode == "check" then
  print("Checking bindings...")
  for _, m in ipairs(modules) do
    local source = io.open(m.source, "rb")
    if source then
      local content = source:read("*all")
      source:close()
      local count = 0
      for _ in content:gmatch("\n") do count = count + 1 end
      print(m.source .. ": " .. count .. " lines")
    else
      print(m.source .. ": NOT FOUND")
    end
  end
else
  local selected = nil
  for _, mod in ipairs(modules) do
    if mod.output:match(mode) or mod.name == mode then
      selected = mod
      break
    end
  end

  if selected then
    extract_api(selected.name, selected.source, selected.output)
  else
    print("Usage: lua update_bindings.lua [all|api|raymath|rlgl|gestures|rcamera|physac|raygui]")
  end
end
