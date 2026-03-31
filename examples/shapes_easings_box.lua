--[[
    raylib [shapes] example - easings box

    Example complexity rating: [★★☆☆] 2/4

    Example originally created with raylib 2.5, last time updated with raylib 2.5

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2014-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - easings box")

-- Box variables to be animated with easings
local rec = rl.new("Rectangle", rl.GetScreenWidth()/2.0, -100, 100, 100)
local rotation = 0.0
local alpha = 1.0

local state = 0
local framesCounter = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if state == 0 then
		-- Move box down to center of screen
		framesCounter = framesCounter + 1
		rec.y = rl.EaseElasticOut(framesCounter, -100, rl.GetScreenHeight()/2.0 + 100, 120)

		if framesCounter >= 120 then
			framesCounter = 0
			state = 1
		end
	elseif state == 1 then
		-- Scale box to an horizontal bar
		framesCounter = framesCounter + 1
		rec.height = rl.EaseBounceOut(framesCounter, 100, -90, 120)
		rec.width = rl.EaseBounceOut(framesCounter, 100, rl.GetScreenWidth(), 120)

		if framesCounter >= 120 then
			framesCounter = 0
			state = 2
		end
	elseif state == 2 then
		-- Rotate horizontal bar rectangle
		framesCounter = framesCounter + 1
		rotation = rl.EaseQuadOut(framesCounter, 0.0, 270.0, 240)

		if framesCounter >= 240 then
			framesCounter = 0
			state = 3
		end
	elseif state == 3 then
		-- Increase bar size to fill all screen
		framesCounter = framesCounter + 1
		rec.height = rl.EaseCircOut(framesCounter, 10, rl.GetScreenWidth(), 120)

		if framesCounter >= 120 then
			framesCounter = 0
			state = 4
		end
	elseif state == 4 then
		-- Fade out animation
		framesCounter = framesCounter + 1
		alpha = rl.EaseSineOut(framesCounter, 1.0, -1.0, 160)

		if framesCounter >= 160 then
			framesCounter = 0
			state = 5
		end
	end

	-- Reset animation at any moment
	if rl.IsKeyPressed(rl.KEY_SPACE) then
		rec = rl.new("Rectangle", rl.GetScreenWidth()/2.0, -100, 100, 100)
		rotation = 0.0
		alpha = 1.0
		state = 0
		framesCounter = 0
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawRectanglePro(rec, rl.new("Vector2", rec.width/2, rec.height/2), rotation, rl.Fade(rl.BLACK, alpha))

	rl.DrawText("PRESS [SPACE] TO RESET BOX ANIMATION!", 10, rl.GetScreenHeight() - 25, 20, rl.LIGHTGRAY)

	rl.EndDrawing()
end

rl.CloseWindow()
