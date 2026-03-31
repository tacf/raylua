--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_sprite_animation.c

]]

--[[
	raylib [textures] example - sprite animation

	Example complexity rating: [★★☆☆] 2/4

	Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
	BSD-like license that allows static linking with closed source software

	Copyright (c) 2014-2025 Ramon Santamaria (@raysan5)
]]

local MAX_FRAME_SPEED = 15
local MIN_FRAME_SPEED = 1

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - sprite animation")

local scarfy = rl.LoadTexture("resources/scarfy.png")

local position = rl.rlVertex2f(350.0, 280.0)
local frameRec = rl.new("Rectangle", 0.0, 0.0, scarfy.width / 6, scarfy.height)
local currentFrame = 0

local framesCounter = 0
local framesSpeed = 8

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	framesCounter = framesCounter + 1

	if framesCounter >= math.floor(60 / framesSpeed) then
		framesCounter = 0
		currentFrame = currentFrame + 1

		if currentFrame > 5 then currentFrame = 0 end

		frameRec.x = currentFrame * scarfy.width / 6
	end

	-- Control frames speed
	if rl.IsKeyPressed(rl.KEY_RIGHT) then
		framesSpeed = framesSpeed + 1
	elseif rl.IsKeyPressed(rl.KEY_LEFT) then
		framesSpeed = framesSpeed - 1
	end

	if framesSpeed > MAX_FRAME_SPEED then
		framesSpeed = MAX_FRAME_SPEED
	elseif framesSpeed < MIN_FRAME_SPEED then
		framesSpeed = MIN_FRAME_SPEED
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexture(scarfy, 15, 40, rl.WHITE)
	rl.DrawRectangleLines(15, 40, scarfy.width, scarfy.height, rl.LIME)
	rl.DrawRectangleLines(15 + math.floor(frameRec.x), 40 + math.floor(frameRec.y), math.floor(frameRec.width), math.floor(frameRec.height), rl.RED)

	rl.DrawText("FRAME SPEED: ", 165, 210, 10, rl.DARKGRAY)
	rl.DrawText(string.format("%02d FPS", framesSpeed), 575, 210, 10, rl.DARKGRAY)
	rl.DrawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 240, 10, rl.DARKGRAY)

	for i = 0, MAX_FRAME_SPEED - 1 do
		if i < framesSpeed then
			rl.DrawRectangle(250 + 21 * i, 205, 20, 20, rl.RED)
		end
		rl.DrawRectangleLines(250 + 21 * i, 205, 20, 20, rl.MAROON)
	end

	rl.DrawTextureRec(scarfy, frameRec, position, rl.WHITE)

	rl.DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, rl.GRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(scarfy)

rl.CloseWindow()
