--[[
    raylib [shapes] example - easings rectangles

    Example complexity rating: [★★★☆] 3/4

    Example originally created with raylib 2.0, last time updated with raylib 2.5

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2014-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - easings rectangles")

local RECS_WIDTH = 50
local RECS_HEIGHT = 50

local MAX_RECS_X = math.floor(800/RECS_WIDTH)
local MAX_RECS_Y = math.floor(450/RECS_HEIGHT)

local PLAY_TIME_IN_FRAMES = 240

local recs = {}
for y = 0, MAX_RECS_Y - 1 do
	for x = 0, MAX_RECS_X - 1 do
		local idx = y*MAX_RECS_X + x
		recs[idx] = rl.new("Rectangle",
			RECS_WIDTH/2.0 + RECS_WIDTH*x,
			RECS_HEIGHT/2.0 + RECS_HEIGHT*y,
			RECS_WIDTH,
			RECS_HEIGHT
		)
	end
end

local rotation = 0.0
local framesCounter = 0
local state = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if state == 0 then
		framesCounter = framesCounter + 1

		for i = 0, MAX_RECS_X*MAX_RECS_Y - 1 do
			recs[i].height = rl.EaseCircOut(framesCounter, RECS_HEIGHT, -RECS_HEIGHT, PLAY_TIME_IN_FRAMES)
			recs[i].width = rl.EaseCircOut(framesCounter, RECS_WIDTH, -RECS_WIDTH, PLAY_TIME_IN_FRAMES)

			if recs[i].height < 0 then recs[i].height = 0 end
			if recs[i].width < 0 then recs[i].width = 0 end

			if recs[i].height == 0 and recs[i].width == 0 then state = 1 end

			rotation = rl.EaseLinearIn(framesCounter, 0.0, 360.0, PLAY_TIME_IN_FRAMES)
		end
	elseif state == 1 and rl.IsKeyPressed(rl.KEY_SPACE) then
		framesCounter = 0

		for i = 0, MAX_RECS_X*MAX_RECS_Y - 1 do
			recs[i].height = RECS_HEIGHT
			recs[i].width = RECS_WIDTH
		end

		state = 0
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	if state == 0 then
		for i = 0, MAX_RECS_X*MAX_RECS_Y - 1 do
			rl.DrawRectanglePro(recs[i], rl.new("Vector2", recs[i].width/2, recs[i].height/2), rotation, rl.RED)
		end
	elseif state == 1 then
		rl.DrawText("PRESS [SPACE] TO PLAY AGAIN!", 240, 200, 20, rl.GRAY)
	end

	rl.EndDrawing()
end

rl.CloseWindow()
