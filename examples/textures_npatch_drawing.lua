--[[
    raylib [textures] example - npatch drawing

    Example complexity rating: [★★★☆] 3/4

    NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)

    Example originally created with raylib 2.0, last time updated with raylib 2.5

    Example contributed by Jorge A. Gomes (@overdev) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2018-2025 Jorge A. Gomes (@overdev) and Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - npatch drawing")

-- NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
local nPatchTexture = rl.LoadTexture("resources/ninepatch_button.png")

local mousePosition = rl.new("Vector2", 0, 0)
local origin = rl.new("Vector2", 0.0, 0.0)

-- Position and size of the n-patches
local dstRec1 = rl.new("Rectangle", 480.0, 160.0, 32.0, 32.0)
local dstRec2 = rl.new("Rectangle", 160.0, 160.0, 32.0, 32.0)
local dstRecH = rl.new("Rectangle", 160.0, 93.0, 32.0, 32.0)
local dstRecV = rl.new("Rectangle", 92.0, 160.0, 32.0, 32.0)

-- A 9-patch (NPATCH_NINE_PATCH) changes its sizes in both axis
local ninePatchInfo1 = {
	source = rl.new("Rectangle", 0.0, 0.0, 64.0, 64.0),
	left = 12, top = 40, right = 12, bottom = 12,
	layout = rl.NPATCH_NINE_PATCH
}

local ninePatchInfo2 = {
	source = rl.new("Rectangle", 0.0, 128.0, 64.0, 64.0),
	left = 16, top = 16, right = 16, bottom = 16,
	layout = rl.NPATCH_NINE_PATCH
}

-- A horizontal 3-patch (NPATCH_THREE_PATCH_HORIZONTAL) changes its sizes along the x axis only
local h3PatchInfo = {
	source = rl.new("Rectangle", 0.0, 64.0, 64.0, 64.0),
	left = 8, top = 8, right = 8, bottom = 8,
	layout = rl.NPATCH_THREE_PATCH_HORIZONTAL
}

-- A vertical 3-patch (NPATCH_THREE_PATCH_VERTICAL) changes its sizes along the y axis only
local v3PatchInfo = {
	source = rl.new("Rectangle", 0.0, 192.0, 64.0, 64.0),
	left = 6, top = 6, right = 6, bottom = 6,
	layout = rl.NPATCH_THREE_PATCH_VERTICAL
}

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do                              -- Detect window close button or ESC key
	-- Update
	mousePosition = rl.GetMousePosition()

	-- Resize the n-patches based on mouse position
	dstRec1.width = mousePosition.x - dstRec1.x
	dstRec1.height = mousePosition.y - dstRec1.y
	dstRec2.width = mousePosition.x - dstRec2.x
	dstRec2.height = mousePosition.y - dstRec2.y
	dstRecH.width = mousePosition.x - dstRecH.x
	dstRecV.height = mousePosition.y - dstRecV.y

	-- Set a minimum width and/or height
	if dstRec1.width < 1.0 then dstRec1.width = 1.0 end
	if dstRec1.width > 300.0 then dstRec1.width = 300.0 end
	if dstRec1.height < 1.0 then dstRec1.height = 1.0 end
	if dstRec2.width < 1.0 then dstRec2.width = 1.0 end
	if dstRec2.width > 300.0 then dstRec2.width = 300.0 end
	if dstRec2.height < 1.0 then dstRec2.height = 1.0 end
	if dstRecH.width < 1.0 then dstRecH.width = 1.0 end
	if dstRecV.height < 1.0 then dstRecV.height = 1.0 end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	-- Draw the n-patches
	rl.DrawTextureNPatch(nPatchTexture, ninePatchInfo2, dstRec2, origin, 0.0, rl.WHITE)
	rl.DrawTextureNPatch(nPatchTexture, ninePatchInfo1, dstRec1, origin, 0.0, rl.WHITE)
	rl.DrawTextureNPatch(nPatchTexture, h3PatchInfo, dstRecH, origin, 0.0, rl.WHITE)
	rl.DrawTextureNPatch(nPatchTexture, v3PatchInfo, dstRecV, origin, 0.0, rl.WHITE)

	-- Draw the source texture
	rl.DrawRectangleLines(5, 88, 74, 266, rl.BLUE)
	rl.DrawTexture(nPatchTexture, 10, 93, rl.WHITE)
	rl.DrawText("TEXTURE", 15, 360, 10, rl.DARKGRAY)

	rl.DrawText("Move the mouse to stretch or shrink the n-patches", 10, 20, 20, rl.DARKGRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(nPatchTexture)                                  -- Texture unloading

rl.CloseWindow()                                                 -- Close window and OpenGL context
