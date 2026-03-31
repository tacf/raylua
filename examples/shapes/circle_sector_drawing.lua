--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_circle_sector_drawing.c

]]

--[[
    raylib [shapes] example - circle sector drawing

    Example complexity rating: [★★★☆] 3/4

    Example originally created with raylib 2.5, last time updated with raylib 2.5

    Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2018-2025 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - circle sector drawing")

local center = rl.new("Vector2", (rl.GetScreenWidth() - 300) / 2.0, rl.GetScreenHeight() / 2.0)

local outerRadius = 180.0
local startAngle = 0.0
local endAngle = 180.0
local segments = 10.0

-- Manual slider since raygui isn't available in binding
local function SliderBar(bx, by, bw, bh, label, value, minVal, maxVal)
	local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
	if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
		value = minVal + (maxVal - minVal) * (mx - bx) / bw
	end
	value = math.max(minVal, math.min(maxVal, value))
	rl.DrawRectangle(bx, by, bw, bh, rl.LIGHTGRAY)
	local fillW = (value - minVal) / (maxVal - minVal) * bw
	rl.DrawRectangle(bx, by, fillW, bh, rl.MAROON)
	rl.DrawRectangleLines(bx, by, bw, bh, rl.DARKGRAY)
	rl.DrawText(string.format("%s: %.2f", label, value), bx, by - 16, 10, rl.DARKGRAY)
	return value
end

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- NOTE: All variables update happens inside GUI control functions

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawLine(500, 0, 500, rl.GetScreenHeight(), rl.Fade(rl.LIGHTGRAY, 0.6))
	rl.DrawRectangle(500, 0, rl.GetScreenWidth() - 500, rl.GetScreenHeight(), rl.Fade(rl.LIGHTGRAY, 0.3))

	rl.DrawCircleSector(center, outerRadius, startAngle, endAngle, math.floor(segments), rl.Fade(rl.MAROON, 0.3))
	rl.DrawCircleSectorLines(center, outerRadius, startAngle, endAngle, math.floor(segments), rl.Fade(rl.MAROON, 0.6))

	startAngle = SliderBar(600, 40, 120, 20, "StartAngle", startAngle, 0, 720)
	endAngle = SliderBar(600, 70, 120, 20, "EndAngle", endAngle, 0, 720)

	outerRadius = SliderBar(600, 140, 120, 20, "Radius", outerRadius, 0, 200)
	segments = SliderBar(600, 170, 120, 20, "Segments", segments, 0, 100)

	local minSegments = math.floor(math.ceil((endAngle - startAngle) / 90))
	if segments >= minSegments then
		rl.DrawText("MODE: MANUAL", 600, 200, 10, rl.MAROON)
	else
		rl.DrawText("MODE: AUTO", 600, 200, 10, rl.DARKGRAY)
	end

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
