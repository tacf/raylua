--[[
  Shared struct/type metadata for the web (non-FFI) binding generator.

  Every entry in `structs` describes a raylib struct that the generator knows
  how to marshal to/from a plain Lua table. Anything not listed here still
  works through the generic fallbacks in web_marshal.c (opaque pointer
  passthrough for pointers, malloc+memcpy passthrough for unknown by-value
  structs) -- it just isn't readable/writable field-by-field from Lua.

  Field kinds:
    "int" | "uint" | "short" | "ushort" | "long" | "float" | "double" | "bool"
      -- plain numeric/bool scalar
    "uchar"
      -- numeric scalar (0-255), distinct tag so callers can special-case
    { struct = "Vector2" }
      -- nested struct by value
    { charbuf = 32 }
      -- fixed char array, marshaled as a Lua string (truncated/padded)
    { numarr = "float", n = 4 }
      -- fixed numeric array, marshaled as a 1-indexed Lua array table
    { structarr = "Matrix", n = 2 }
      -- fixed array of structs, marshaled as a 1-indexed Lua array table
    "opaque"
      -- raw pointer field; passed through as lightuserdata, not readable
    "opaqueval"
      -- by-value field of an unregistered nested struct type; copied
      -- byte-for-byte through a GC'd userdata blob, not readable
]]

local M = {}

M.structs = {
  Vector2 = {
    { name = "x", kind = "float" },
    { name = "y", kind = "float" },
  },
  Vector3 = {
    { name = "x", kind = "float" },
    { name = "y", kind = "float" },
    { name = "z", kind = "float" },
  },
  Vector4 = {
    { name = "x", kind = "float" },
    { name = "y", kind = "float" },
    { name = "z", kind = "float" },
    { name = "w", kind = "float" },
  },
  Quaternion = "Vector4",
  Matrix = {
    { name = "m0", kind = "float" }, { name = "m4", kind = "float" },
    { name = "m8", kind = "float" }, { name = "m12", kind = "float" },
    { name = "m1", kind = "float" }, { name = "m5", kind = "float" },
    { name = "m9", kind = "float" }, { name = "m13", kind = "float" },
    { name = "m2", kind = "float" }, { name = "m6", kind = "float" },
    { name = "m10", kind = "float" }, { name = "m14", kind = "float" },
    { name = "m3", kind = "float" }, { name = "m7", kind = "float" },
    { name = "m11", kind = "float" }, { name = "m15", kind = "float" },
  },
  Color = {
    { name = "r", kind = "uchar" },
    { name = "g", kind = "uchar" },
    { name = "b", kind = "uchar" },
    { name = "a", kind = "uchar" },
  },
  Rectangle = {
    { name = "x", kind = "float" },
    { name = "y", kind = "float" },
    { name = "width", kind = "float" },
    { name = "height", kind = "float" },
  },
  Image = {
    { name = "data", kind = "opaque" },
    { name = "width", kind = "int" },
    { name = "height", kind = "int" },
    { name = "mipmaps", kind = "int" },
    { name = "format", kind = "int" },
  },
  Texture = {
    { name = "id", kind = "uint" },
    { name = "width", kind = "int" },
    { name = "height", kind = "int" },
    { name = "mipmaps", kind = "int" },
    { name = "format", kind = "int" },
  },
  Texture2D = "Texture",
  TextureCubemap = "Texture",
  RenderTexture = {
    { name = "id", kind = "uint" },
    { name = "texture", kind = { struct = "Texture" } },
    { name = "depth", kind = { struct = "Texture" } },
  },
  RenderTexture2D = "RenderTexture",
  NPatchInfo = {
    { name = "source", kind = { struct = "Rectangle" } },
    { name = "left", kind = "int" },
    { name = "top", kind = "int" },
    { name = "right", kind = "int" },
    { name = "bottom", kind = "int" },
    { name = "layout", kind = "int" },
  },
  GlyphInfo = {
    { name = "value", kind = "int" },
    { name = "offsetX", kind = "int" },
    { name = "offsetY", kind = "int" },
    { name = "advanceX", kind = "int" },
    { name = "image", kind = { struct = "Image" } },
  },
  Font = {
    { name = "baseSize", kind = "int" },
    { name = "glyphCount", kind = "int" },
    { name = "glyphPadding", kind = "int" },
    { name = "texture", kind = { struct = "Texture2D" } },
    { name = "recs", kind = "opaque" },
    { name = "glyphs", kind = "opaque" },
  },
  SpriteFont = "Font",
  Camera3D = {
    { name = "position", kind = { struct = "Vector3" } },
    { name = "target", kind = { struct = "Vector3" } },
    { name = "up", kind = { struct = "Vector3" } },
    { name = "fovy", kind = "float" },
    { name = "projection", kind = "int" },
  },
  Camera = "Camera3D",
  Camera2D = {
    { name = "offset", kind = { struct = "Vector2" } },
    { name = "target", kind = { struct = "Vector2" } },
    { name = "rotation", kind = "float" },
    { name = "zoom", kind = "float" },
  },
  Mesh = {
    { name = "vertexCount", kind = "int" },
    { name = "triangleCount", kind = "int" },
    { name = "vertices", kind = "opaque" },
    { name = "texcoords", kind = "opaque" },
    { name = "texcoords2", kind = "opaque" },
    { name = "normals", kind = "opaque" },
    { name = "tangents", kind = "opaque" },
    { name = "colors", kind = "opaque" },
    { name = "indices", kind = "opaque" },
    { name = "boneCount", kind = "int" },
    { name = "boneIndices", kind = "opaque" },
    { name = "boneWeights", kind = "opaque" },
    { name = "animVertices", kind = "opaque" },
    { name = "animNormals", kind = "opaque" },
    { name = "vaoId", kind = "uint" },
    { name = "vboId", kind = "opaque" },
  },
  Shader = {
    { name = "id", kind = "uint" },
    { name = "locs", kind = "opaque" },
  },
  MaterialMap = {
    { name = "texture", kind = { struct = "Texture2D" } },
    { name = "color", kind = { struct = "Color" } },
    { name = "value", kind = "float" },
  },
  Material = {
    { name = "shader", kind = { struct = "Shader" } },
    { name = "maps", kind = "opaque" },
    { name = "params", kind = { numarr = "float", n = 4 } },
  },
  Transform = {
    { name = "translation", kind = { struct = "Vector3" } },
    { name = "rotation", kind = { struct = "Quaternion" } },
    { name = "scale", kind = { struct = "Vector3" } },
  },
  BoneInfo = {
    { name = "name", kind = { charbuf = 32 } },
    { name = "parent", kind = "int" },
  },
  Model = {
    { name = "transform", kind = { struct = "Matrix" } },
    { name = "meshCount", kind = "int" },
    { name = "materialCount", kind = "int" },
    { name = "meshes", kind = "opaque" },
    { name = "materials", kind = "opaque" },
    { name = "meshMaterial", kind = "opaque" },
    { name = "skeleton", kind = "opaqueval" },
    { name = "currentPose", kind = "opaque" },
    { name = "boneMatrices", kind = "opaque" },
  },
  ModelAnimation = {
    { name = "name", kind = { charbuf = 32 } },
    { name = "boneCount", kind = "int" },
    { name = "keyframeCount", kind = "int" },
    { name = "keyframePoses", kind = "opaque" },
  },
  Ray = {
    { name = "position", kind = { struct = "Vector3" } },
    { name = "direction", kind = { struct = "Vector3" } },
  },
  RayCollision = {
    { name = "hit", kind = "bool" },
    { name = "distance", kind = "float" },
    { name = "point", kind = { struct = "Vector3" } },
    { name = "normal", kind = { struct = "Vector3" } },
  },
  BoundingBox = {
    { name = "min", kind = { struct = "Vector3" } },
    { name = "max", kind = { struct = "Vector3" } },
  },
  Wave = {
    { name = "frameCount", kind = "uint" },
    { name = "sampleRate", kind = "uint" },
    { name = "sampleSize", kind = "uint" },
    { name = "channels", kind = "uint" },
    { name = "data", kind = "opaque" },
  },
  AudioStream = {
    { name = "buffer", kind = "opaque" },
    { name = "processor", kind = "opaque" },
    { name = "sampleRate", kind = "uint" },
    { name = "sampleSize", kind = "uint" },
    { name = "channels", kind = "uint" },
  },
  Sound = {
    { name = "stream", kind = { struct = "AudioStream" } },
    { name = "frameCount", kind = "uint" },
  },
  Music = {
    { name = "stream", kind = { struct = "AudioStream" } },
    { name = "frameCount", kind = "uint" },
    { name = "looping", kind = "bool" },
    { name = "ctxType", kind = "int" },
    { name = "ctxData", kind = "opaque" },
  },
  VrDeviceInfo = {
    { name = "hResolution", kind = "int" },
    { name = "vResolution", kind = "int" },
    { name = "hScreenSize", kind = "float" },
    { name = "vScreenSize", kind = "float" },
    { name = "eyeToScreenDistance", kind = "float" },
    { name = "lensSeparationDistance", kind = "float" },
    { name = "interpupillaryDistance", kind = "float" },
    { name = "lensDistortionValues", kind = { numarr = "float", n = 4 } },
    { name = "chromaAbCorrection", kind = { numarr = "float", n = 4 } },
  },
  VrStereoConfig = {
    { name = "projection", kind = { structarr = "Matrix", n = 2 } },
    { name = "viewOffset", kind = { structarr = "Matrix", n = 2 } },
    { name = "leftLensCenter", kind = { numarr = "float", n = 2 } },
    { name = "rightLensCenter", kind = { numarr = "float", n = 2 } },
    { name = "leftScreenCenter", kind = { numarr = "float", n = 2 } },
    { name = "rightScreenCenter", kind = { numarr = "float", n = 2 } },
    { name = "scale", kind = { numarr = "float", n = 2 } },
    { name = "scaleIn", kind = { numarr = "float", n = 2 } },
  },
  FilePathList = {
    { name = "count", kind = "uint" },
    { name = "paths", kind = "opaque" },
  },
  AutomationEvent = {
    { name = "frame", kind = "uint" },
    { name = "type", kind = "uint" },
    { name = "params", kind = { numarr = "int", n = 4 } },
  },
  AutomationEventList = {
    { name = "capacity", kind = "uint" },
    { name = "count", kind = "uint" },
    { name = "events", kind = "opaque" },
  },
  GestureEvent = {
    { name = "touchAction", kind = "int" },
    { name = "pointCount", kind = "int" },
    { name = "pointId", kind = { numarr = "int", n = 8 } },
    { name = "position", kind = { structarr = "Vector2", n = 8 } },
  },
  float3 = {
    { name = "v", kind = { numarr = "float", n = 3 } },
  },
  float16 = {
    { name = "v", kind = { numarr = "float", n = 16 } },
  },
}

-- Typedefs that are secretly pointers (`typedef struct Foo *Bar;`) and thus
-- must be treated as opaque handles even when they appear with zero literal
-- `*` in a signature (e.g. `PhysicsBody body`, not `PhysicsBody *body`).
M.opaque_handle_types = {
  PhysicsBody = true,
}

-- Resolve typedef aliases (e.g. Quaternion -> Vector4) to their real field list.
function M.resolve(name)
  local seen = {}
  local cur = name
  while type(M.structs[cur]) == "string" do
    if seen[cur] then return nil end
    seen[cur] = true
    cur = M.structs[cur]
  end
  local fields = M.structs[cur]
  if type(fields) ~= "table" then return nil end
  return fields, cur
end

-- C function-pointer typedefs: any parameter of one of these types can't be
-- bound without a JS trampoline, so the generator skips the whole function.
M.callback_types = {
  TraceLogCallback = true,
  AudioCallback = true,
  LoadFileDataCallback = true,
  SaveFileDataCallback = true,
  LoadFileTextCallback = true,
  SaveFileTextCallback = true,
}

-- Plain numeric/bool scalar C type names -> normalized kind tag.
M.scalar_types = {
  ["int"] = "int",
  ["unsigned int"] = "uint",
  ["short"] = "short",
  ["unsigned short"] = "ushort",
  ["long"] = "long",
  ["unsigned long"] = "long",
  ["float"] = "float",
  ["double"] = "double",
  ["bool"] = "bool",
  ["size_t"] = "uint",
  ["unsigned char"] = "uchar",
  ["char"] = "uchar",
}

return M
