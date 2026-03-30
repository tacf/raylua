local keywords = {
  "int", "long", "short", "char", "float", "double",
  "uint8_t", "uint16_t", "uint32_t", "uint64_t",
  "const", "unsigned", "register", "signed",
  "void", "intptr_t", "uintptr_t", "bool", "size_t",
  "volatile", "extern"
}

local structs = {
  "Vector2", "Vector3", "Vector4", "Quaternion",
  "Matrix", "Color", "Rectangle", "Image", "Texture", "Texture2D",
  "RenderTexture", "NPatchInfo", "GlyphInfo", "Font",
  "Camera", "Camera2D", "Mesh", "Shader", "MaterialMap",
  "Material", "Model", "Transform", "BoneInfo", "ModelAnimation",
  "Ray", "RayCollision", "BoundingBox", "Wave", "Sound", "Music",
  "AudioStream", "VrDeviceInfo", "Camera3D", "RenderTexture2D",
  "TextureCubemap", "TraceLogCallback", "PhysicsBody",
  "GestureEvent", "GuiStyle", "GuiTextBoxState",
  "VertexBuffer", "DrawCall", "RenderBatch",
  "ShaderAttributeDataType", "MaterialMapIndex", "VrStereoConfig",
  "FilePathList", "AudioCallback", "AutomationEvent", "AutomationEventList",
  "LoadFileDataCallback", "SaveFileDataCallback",
  "LoadFileTextCallback", "SaveFileTextCallback",
  "float3", "float16"
}

local rl_structs = {
  "rlTraceLogLevel", "rlPixelFormat", "rlTextureFilter",
  "rlBlendMode", "rlShaderLocationIndex", "rlShaderUniformDataType",
  "rlShaderAttributeDataType", "rlFramebufferAttachType",
  "rlFramebufferAttachTextureType", "rlVertexBuffer", "rlDrawCall",
  "rlRenderBatch"
}

local functions = {}
local proto = {}
local seen = {}
local seen_from = {}

local file = io.open(arg[1], "wb")
local modules = { "api" }

for i = 2, #arg do
  modules[#modules + 1] = arg[i]
end

local keyword_set = {}
for _, v in ipairs(keywords) do keyword_set[v] = true end

local type_set = {}
for _, v in ipairs(structs) do type_set[v] = true end
for _, v in ipairs(rl_structs) do type_set[v] = true end

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function is_ignored_line(line)
  line = trim(line)

  return line == ""
      or line:sub(1, 2) == "//"
      or line:match("^/%*")
      or line:match("^typedef%s+")
      or line:match("^static%s+")
      or line:match("^inline%s+")
      or line:match("^enum%s+")
      or line:match("^struct%s+")
      or line:match("^union%s+")
end

local function extract_function_name(line)
  local before = line:match("^(.-)%s*%(")
  if not before then
    return nil
  end

  before = trim(before)
  local name = before:match("([_%a][_%w]*)%s*$")
  if not name then
    return nil
  end

  if keyword_set[name] or type_set[name] then
    return nil
  end

  return name
end

local function replace_function_name_with_ptr(line)
  local before, parens, after = line:match("^(.-)(%b())(.*)$")
  if not before then
    return nil
  end

  before = before:gsub("([_%a][_%w]*)%s*$", "(*)", 1)
  return before .. parens .. after
end

local function strip_param_names(line)
  line = " " .. line

  line = line:gsub("(%W)([%l_][%w_]*)", function(before, part)
    if keyword_set[part] or type_set[part] or part == "t" then
      return before .. part
    end
    return before
  end)

  line = trim(line)
  line = line:gsub("%s+", " ")
  line = line:gsub("([(),*.])%s+(%w)", function(a, b) return a .. b end)
  line = line:gsub("(%w)%s+([(),*.])", function(a, b) return a .. b end)
  line = line:gsub("%s*;%s*$", "")
  return line
end

local function make_proto(line)
  local proto_line = replace_function_name_with_ptr(line)
  if not proto_line then
    return nil
  end

  proto_line = strip_param_names(proto_line)
  if proto_line == "" then
    return nil
  end

  return proto_line
end

file:write [[
struct raylua_bind_entry {
  const char *name;
  const char *proto;
  void *ptr;
};

struct raylua_bind_entry raylua_entries[] = {
]]

for _, modname in ipairs(modules) do
  for line in io.lines("tools/" .. modname .. ".h") do
    local raw = trim(line)

    if raw:sub(1, 1) == "#" then
      file:write("  " .. raw .. "\n")
    elseif not is_ignored_line(raw) then
      local funcname = extract_function_name(raw)

      if funcname then
        if seen[funcname] then
          -- First definition wins; skip duplicates from later modules.
          -- Example: gesture functions appearing in both api.h and gestures.h.
        else
          local proto_line = make_proto(raw)

          if proto_line then
            seen[funcname] = true
            seen_from[funcname] = modname
            functions[#functions + 1] = funcname
            proto[#proto + 1] = proto_line
            file:write(string.format('  { "%s", "%s", &%s },\n', funcname, proto_line, funcname))
          else
            print("WARN: Invalid entry", funcname, raw)
          end
        end
      end
    end
  end
end

assert(#proto == #functions, "Mismatching proto and function count : " ..
  #proto .. " ~= " .. #functions)

print(string.format("Bound %d functions.", #proto))

file:write('  { NULL, NULL, NULL },\n')
file:write("};\n")

file:close()
