-- Web build boot glue: color constants and small compatibility shims that
-- desktop raylua gets from FFI/raylib.lua but the web build needs spelled
-- out in plain Lua (no ffi.cdef available under standard Lua).

local function color(r, g, b, a)
  return { r = r, g = g, b = b, a = a }
end

rl.LIGHTGRAY = color(200, 200, 200, 255)
rl.GRAY = color(130, 130, 130, 255)
rl.DARKGRAY = color(80, 80, 80, 255)
rl.YELLOW = color(253, 249, 0, 255)
rl.GOLD = color(255, 203, 0, 255)
rl.ORANGE = color(255, 161, 0, 255)
rl.PINK = color(255, 109, 194, 255)
rl.RED = color(230, 41, 55, 255)
rl.MAROON = color(190, 33, 55, 255)
rl.GREEN = color(0, 228, 48, 255)
rl.LIME = color(0, 158, 47, 255)
rl.DARKGREEN = color(0, 117, 44, 255)
rl.SKYBLUE = color(102, 191, 255, 255)
rl.BLUE = color(0, 121, 241, 255)
rl.DARKBLUE = color(0, 82, 172, 255)
rl.PURPLE = color(200, 122, 255, 255)
rl.VIOLET = color(135, 60, 190, 255)
rl.DARKPURPLE = color(112, 31, 126, 255)
rl.BEIGE = color(211, 176, 131, 255)
rl.BROWN = color(127, 106, 79, 255)
rl.DARKBROWN = color(76, 63, 47, 255)
rl.WHITE = color(255, 255, 255, 255)
rl.BLACK = color(0, 0, 0, 255)
rl.BLANK = color(0, 0, 0, 0)
rl.MAGENTA = color(255, 0, 255, 255)
rl.RAYWHITE = color(245, 245, 245, 255)

rl.SHADER_LOC_MAP_DIFFUSE = rl.SHADER_LOC_MAP_ALBEDO
rl.SHADER_LOC_MAP_SPECULAR = rl.SHADER_LOC_MAP_METALNESS
rl.MATERIAL_MAP_DIFFUSE = rl.MATERIAL_MAP_ALBEDO
rl.MATERIAL_MAP_SPECULAR = rl.MATERIAL_MAP_METALNESS

-- TextFormat is a C varargs function; the generator can't bind it. Lua's
-- own string.format covers the common %d/%s/%f/%c specifiers scripts use.
rl.TextFormat = string.format

-- Some examples do `local rl = require("raylib")` instead of using the
-- global directly; hand back the same table either way.
package.loaded["raylib"] = rl
package.preload["raylib"] = function() return rl end

setmetatable(_G, { __index = rl })
