--[[
	raylib [textures] example - sprite explosion

	Example complexity rating: [★★☆☆] 2/4

	Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
	BSD-like license that allows static linking with closed source software

	Copyright (c) 2019-2025 Ramon Santamaria (@raysan5)
]]

local NUM_FRAMES_PER_LINE = 5
local NUM_LINES = 5

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - sprite explosion")

rl.InitAudioDevice()

local fxBoom = rl.LoadSound("resources/boom.wav")
local explosion = rl.LoadTexture("resources/explosion.png")

-- Init variables for animation
local frameWidth = explosion.width / NUM_FRAMES_PER_LINE
local frameHeight = explosion.height / NUM_LINES
local currentFrame = 0
local currentLine = 0

local frameRec = rl.new("Rectangle", 0, 0, frameWidth, frameHeight)
local position = rl.rlVertex2f(0.0, 0.0)

local active = false
local framesCounter = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- Check for mouse button pressed and activate explosion (if not active)
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and not active then
		position = rl.GetMousePosition()
		active = true

		position.x = position.x - frameWidth / 2.0
		position.y = position.y - frameHeight / 2.0

		rl.PlaySound(fxBoom)
	end

	-- Compute explosion animation frames
	if active then
		framesCounter = framesCounter + 1

		if framesCounter > 2 then
			currentFrame = currentFrame + 1

			if currentFrame >= NUM_FRAMES_PER_LINE then
				currentFrame = 0
				currentLine = currentLine + 1

				if currentLine >= NUM_LINES then
					currentLine = 0
					active = false
				end
			end

			framesCounter = 0
		end
	end

	frameRec.x = frameWidth * currentFrame
	frameRec.y = frameHeight * currentLine

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	if active then
		rl.DrawTextureRec(explosion, frameRec, position, rl.WHITE)
	end

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(explosion)
rl.UnloadSound(fxBoom)

rl.CloseAudioDevice()

rl.CloseWindow()
