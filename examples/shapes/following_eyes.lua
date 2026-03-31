--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_following_eyes.c

]]

--[[
    raylib [shapes] example - following eyes

    Example complexity rating: [★★☆☆] 2/4

    Example originally created with raylib 2.5, last time updated with raylib 2.5

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2013-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - following eyes")

local scleraLeftPosition = rl.new("Vector2", screenWidth/2.0 - 100.0, screenHeight/2.0)
local scleraRightPosition = rl.new("Vector2", screenWidth/2.0 + 100.0, screenHeight/2.0)
local scleraRadius = 80

local irisLeftPosition = rl.new("Vector2", screenWidth/2.0 - 100.0, screenHeight/2.0)
local irisRightPosition = rl.new("Vector2", screenWidth/2.0 + 100.0, screenHeight/2.0)
local irisRadius = 24

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	irisLeftPosition = rl.GetMousePosition()
	irisRightPosition = rl.GetMousePosition()

	-- Check not inside the left eye sclera
	if not rl.CheckCollisionPointCircle(irisLeftPosition, scleraLeftPosition, scleraRadius - irisRadius) then
		local dx = irisLeftPosition.x - scleraLeftPosition.x
		local dy = irisLeftPosition.y - scleraLeftPosition.y

		local angle = math.atan(dy, dx)

		local dxx = (scleraRadius - irisRadius)*math.cos(angle)
		local dyy = (scleraRadius - irisRadius)*math.sin(angle)

		irisLeftPosition = rl.new("Vector2", scleraLeftPosition.x + dxx, scleraLeftPosition.y + dyy)
	end

	-- Check not inside the right eye sclera
	if not rl.CheckCollisionPointCircle(irisRightPosition, scleraRightPosition, scleraRadius - irisRadius) then
		local dx = irisRightPosition.x - scleraRightPosition.x
		local dy = irisRightPosition.y - scleraRightPosition.y

		local angle = math.atan(dy, dx)

		local dxx = (scleraRadius - irisRadius)*math.cos(angle)
		local dyy = (scleraRadius - irisRadius)*math.sin(angle)

		irisRightPosition = rl.new("Vector2", scleraRightPosition.x + dxx, scleraRightPosition.y + dyy)
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawCircleV(scleraLeftPosition, scleraRadius, rl.LIGHTGRAY)
	rl.DrawCircleV(irisLeftPosition, irisRadius, rl.BROWN)
	rl.DrawCircleV(irisLeftPosition, 10, rl.BLACK)

	rl.DrawCircleV(scleraRightPosition, scleraRadius, rl.LIGHTGRAY)
	rl.DrawCircleV(irisRightPosition, irisRadius, rl.DARKGREEN)
	rl.DrawCircleV(irisRightPosition, 10, rl.BLACK)

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
