--[[
	raylib [textures] example - sprite stacking

	Example complexity rating: [★★☆☆] 2/4

	Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
	BSD-like license that allows static linking with closed source software

	Copyright (c) 2025 Robin (@RobinsAviary)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - sprite stacking")

local booth = rl.LoadTexture("resources/booth.png")

local stackScale = 3.0
local stackSpacing = 2.0
local stackCount = 122
local rotationSpeed = 30.0
local rotation = 0.0
local speedChange = 0.25

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- Use mouse wheel to affect stack separation
	stackSpacing = stackSpacing + rl.GetMouseWheelMove() * 0.1
	if stackSpacing < 0.0 then stackSpacing = 0.0 end
	if stackSpacing > 5.0 then stackSpacing = 5.0 end

	-- Spin right/left at different speeds
	if rl.IsKeyDown(rl.KEY_LEFT) or rl.IsKeyDown(rl.KEY_A) then
		rotationSpeed = rotationSpeed - speedChange
	end
	if rl.IsKeyDown(rl.KEY_RIGHT) or rl.IsKeyDown(rl.KEY_D) then
		rotationSpeed = rotationSpeed + speedChange
	end

	rotation = rotation + rotationSpeed * rl.GetFrameTime()

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	-- Get the size of a single slice
	local frameWidth = booth.width
	local frameHeight = booth.height / stackCount

	-- Get the scaled resolution to draw at
	local scaledWidth = frameWidth * stackScale
	local scaledHeight = frameHeight * stackScale

	-- Draw the stacked sprite
	for i = stackCount - 1, 0, -1 do
		local source = rl.new("Rectangle", 0.0, i * frameHeight, frameWidth, frameHeight)
		local dest = rl.new("Rectangle",
			screenWidth / 2.0,
			screenHeight / 2.0 + i * stackSpacing - stackSpacing * stackCount / 2.0,
			scaledWidth,
			scaledHeight
		)
		local origin = rl.rlVertex2f(scaledWidth / 2.0, scaledHeight / 2.0)

		rl.DrawTexturePro(booth, source, dest, origin, rotation, rl.WHITE)
	end

	rl.DrawText("A/D to spin\nmouse wheel to change separation (aka 'angle')", 10, 10, 20, rl.DARKGRAY)
	rl.DrawText(string.format("current spacing: %.01f", stackSpacing), 10, 50, 20, rl.DARKGRAY)
	rl.DrawText(string.format("current speed: %.02f", rotationSpeed), 10, 70, 20, rl.DARKGRAY)
	rl.DrawText("redbooth model (c) kluchek under cc 4.0", 10, 420, 20, rl.DARKGRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(booth)

rl.CloseWindow()
