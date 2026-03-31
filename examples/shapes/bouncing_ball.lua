--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_bouncing_ball.c

]]

--[[
    raylib [shapes] example - bouncing ball

    Example complexity rating: [★☆☆☆] 1/4

    Example originally created with raylib 2.5, last time updated with raylib 2.5

    Example contributed by Ramon Santamaria (@raysan5), reviewed by Jopestpe (@jopestpe)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2013-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - bouncing ball")

local ballPositionX = screenWidth/2.0
local ballPositionY = screenHeight/2.0
local ballSpeedX = 5.0
local ballSpeedY = 4.0
local ballRadius = 20
local gravity = 0.2

local useGravity = true
local pause = false
local framesCounter = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyPressed(rl.KEY_G) then useGravity = not useGravity end
	if rl.IsKeyPressed(rl.KEY_SPACE) then pause = not pause end

	if not pause then
		ballPositionX = ballPositionX + ballSpeedX
		ballPositionY = ballPositionY + ballSpeedY

		if useGravity then ballSpeedY = ballSpeedY + gravity end

		-- Check walls collision for bouncing
		if ballPositionX >= (rl.GetScreenWidth() - ballRadius) or ballPositionX <= ballRadius then
			ballSpeedX = ballSpeedX * -1.0
		end
		if ballPositionY >= (rl.GetScreenHeight() - ballRadius) or ballPositionY <= ballRadius then
			ballSpeedY = ballSpeedY * -0.95
		end
	else
		framesCounter = framesCounter + 1
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawCircleV(rl.new("Vector2", ballPositionX, ballPositionY), ballRadius, rl.MAROON)
	rl.DrawText("PRESS SPACE to PAUSE BALL MOVEMENT", 10, rl.GetScreenHeight() - 25, 20, rl.LIGHTGRAY)

	if useGravity then
		rl.DrawText("GRAVITY: ON (Press G to disable)", 10, rl.GetScreenHeight() - 50, 20, rl.DARKGREEN)
	else
		rl.DrawText("GRAVITY: OFF (Press G to enable)", 10, rl.GetScreenHeight() - 50, 20, rl.RED)
	end

	-- On pause, we draw a blinking message
	if pause and (math.floor(framesCounter/30)%2 == 1) then
		rl.DrawText("PAUSED", 350, 200, 30, rl.GRAY)
	end

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
