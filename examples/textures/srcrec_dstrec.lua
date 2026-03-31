--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_srcrec_dstrec.c

]]

--[[
	raylib [textures] example - srcrec dstrec

	Example complexity rating: [★★★☆] 3/4

	Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
	BSD-like license that allows static linking with closed source software

	Copyright (c) 2015-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - srcrec dstrec")

local scarfy = rl.LoadTexture("resources/scarfy.png")

local frameWidth = math.floor(scarfy.width / 6)
local frameHeight = scarfy.height

-- Source rectangle (part of the texture to use for drawing)
local sourceRec = rl.new("Rectangle", 0.0, 0.0, frameWidth, frameHeight)

-- Destination rectangle (screen rectangle where drawing part of texture)
local destRec = rl.new("Rectangle", screenWidth / 2.0, screenHeight / 2.0, frameWidth * 2.0, frameHeight * 2.0)

-- Origin of the texture (rotation/scale point), it's relative to destination rectangle size
local origin = rl.rlVertex2f(frameWidth, frameHeight)

local rotation = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	rotation = rotation + 1

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexturePro(scarfy, sourceRec, destRec, origin, rotation, rl.WHITE)

	rl.DrawLine(math.floor(destRec.x), 0, math.floor(destRec.x), screenHeight, rl.GRAY)
	rl.DrawLine(0, math.floor(destRec.y), screenWidth, math.floor(destRec.y), rl.GRAY)

	rl.DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, rl.GRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(scarfy)

rl.CloseWindow()
