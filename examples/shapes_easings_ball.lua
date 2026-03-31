--[[
    raylib [shapes] example - easings ball

    Example complexity rating: [★★☆☆] 2/4

    Example originally created with raylib 2.5, last time updated with raylib 2.5

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2014-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - easings ball")

-- Ball variable value to be animated with easings
local ballPositionX = -100
local ballRadius = 20
local ballAlpha = 0.0

local state = 0
local framesCounter = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if state == 0 then
		-- Move ball position X with easing
		framesCounter = framesCounter + 1
		ballPositionX = math.floor(rl.EaseElasticOut(framesCounter, -100, screenWidth/2.0 + 100, 120))

		if framesCounter >= 120 then
			framesCounter = 0
			state = 1
		end
	elseif state == 1 then
		-- Increase ball radius with easing
		framesCounter = framesCounter + 1
		ballRadius = math.floor(rl.EaseElasticIn(framesCounter, 20, 500, 200))

		if framesCounter >= 200 then
			framesCounter = 0
			state = 2
		end
	elseif state == 2 then
		-- Change ball alpha with easing (background color blending)
		framesCounter = framesCounter + 1
		ballAlpha = rl.EaseCubicOut(framesCounter, 0.0, 1.0, 200)

		if framesCounter >= 200 then
			framesCounter = 0
			state = 3
		end
	elseif state == 3 then
		-- Reset state to play again
		if rl.IsKeyPressed(rl.KEY_ENTER) then
			ballPositionX = -100
			ballRadius = 20
			ballAlpha = 0.0
			state = 0
		end
	end

	if rl.IsKeyPressed(rl.KEY_R) then framesCounter = 0 end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	if state >= 2 then rl.DrawRectangle(0, 0, screenWidth, screenHeight, rl.GREEN) end
	rl.DrawCircle(ballPositionX, 200, ballRadius, rl.Fade(rl.RED, 1.0 - ballAlpha))

	if state == 3 then
		rl.DrawText("PRESS [ENTER] TO PLAY AGAIN!", 240, 200, 20, rl.BLACK)
	end

	rl.EndDrawing()
end

rl.CloseWindow()
