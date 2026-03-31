--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_magnifying_glass.c

]]

--[[
    raylib textures example - magnifying glass

    Example complexity rating: [★★★☆] 3/4

    Example originally created with raylib 5.6, last time updated with raylib 5.6

    Example contributed by Luke Vaughan (@badram) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2026 Luke Vaughan (@badram)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - magnifying glass")

local bunny = rl.LoadTexture("resources/raybunny.png")
local parrots = rl.LoadTexture("resources/parrots.png")

-- Use image draw to generate a mask texture instead of loading it from a file
local circle = rl.GenImageColor(256, 256, rl.BLANK)
rl.ImageDrawCircle(circle, 128, 128, 128, rl.WHITE)
local mask = rl.LoadTextureFromImage(circle)                     -- Copy the mask image from RAM to VRAM
rl.UnloadImage(circle)                                           -- Unload the image from RAM

local magnifiedWorld = rl.LoadRenderTexture(256, 256)

-- Set magnifying glass zoom
local camera = rl.new("Camera2D")
camera.zoom = 2
-- Offset by half the size of the magnifying glass to counteract drawing the texture centered on the mouse position
camera.offset = rl.new("Vector2", 128, 128)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do                              -- Detect window close button or ESC key
	-- Update
	local mPos = rl.GetMousePosition()
	camera.target = mPos

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	-- Draw the normal version of the world
	rl.DrawTexture(parrots, 144, 33, rl.WHITE)
	rl.DrawText("Use the magnifying glass to find hidden bunnies!", 154, 6, 20, rl.BLACK)

	-- Render to the magnifying glass
	rl.BeginTextureMode(magnifiedWorld)
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode2D(camera)
	-- Draw the same things in the magnified world as were in the normal version
	rl.DrawTexture(parrots, 144, 33, rl.WHITE)
	rl.DrawText("Use the magnifying glass to find hidden bunnies!", 154, 6, 20, rl.BLACK)

	-- Draw bunnies only in the magnified world
	-- BLEND_MULTIPLIED lets them take on the color of the image below them
	rl.BeginBlendMode(rl.BLEND_MULTIPLIED)
	rl.DrawTexture(bunny, 250, 350, rl.WHITE)
	rl.DrawTexture(bunny, 500, 100, rl.WHITE)
	rl.DrawTexture(bunny, 420, 300, rl.WHITE)
	rl.DrawTexture(bunny, 650, 10, rl.WHITE)
	rl.EndBlendMode()
	rl.EndMode2D()

	-- Mask the magnifying glass view texture to a circle
	-- To make the mask affect only alpha, a CUSTOM blend mode is used with SEPARATE color/alpha functions
	rl.BeginBlendMode(rl.BLEND_CUSTOM_SEPARATE)
	rl.rlSetBlendFactorsSeparate(rl.RL_ZERO, rl.RL_ONE, rl.RL_ONE, rl.RL_ZERO, rl.RL_FUNC_ADD, rl.RL_FUNC_ADD)
	rl.DrawTexture(mask, 0, 0, rl.WHITE)
	rl.EndBlendMode()
	rl.EndTextureMode()

	-- Draw magnifiedWorld to screen, centered on cursor
	rl.DrawTextureRec(magnifiedWorld.texture, rl.new("Rectangle", 0, 0, 256, -256),
		rl.new("Vector2", mPos.x - 128, mPos.y - 128), rl.WHITE)

	-- Draw the outer ring of the magnifying glass
	rl.DrawRing(mPos, 126, 130, 0, 360, 64, rl.BLACK)

	-- Draw floating specular highlight on the glass
	local rx = mPos.x / 800
	local ry = mPos.y / 800
	rl.DrawCircle(math.floor(mPos.x - 64*rx) - 32, math.floor(mPos.y - 64*ry) - 32, 4, rl.ColorAlpha(rl.WHITE, 0.5))

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(parrots)
rl.UnloadTexture(bunny)
rl.UnloadTexture(mask)
rl.UnloadRenderTexture(magnifiedWorld)

rl.CloseWindow()                                                 -- Close window and OpenGL context
