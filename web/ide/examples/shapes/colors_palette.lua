--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_colors_palette.c

]]

--[[
    raylib [shapes] example - colors palette

    Example complexity rating: [★★☆☆] 2/4

    Example originally created with raylib 1.0, last time updated with raylib 2.5

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2014-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - colors palette")

local MAX_COLORS_COUNT = 21

local colors = {
	rl.DARKGRAY, rl.MAROON, rl.ORANGE, rl.DARKGREEN, rl.DARKBLUE, rl.DARKPURPLE, rl.DARKBROWN,
	rl.GRAY, rl.RED, rl.GOLD, rl.LIME, rl.BLUE, rl.VIOLET, rl.BROWN, rl.LIGHTGRAY, rl.PINK, rl.YELLOW,
	rl.GREEN, rl.SKYBLUE, rl.PURPLE, rl.BEIGE
}

local colorNames = {
	"DARKGRAY", "MAROON", "ORANGE", "DARKGREEN", "DARKBLUE", "DARKPURPLE",
	"DARKBROWN", "GRAY", "RED", "GOLD", "LIME", "BLUE", "VIOLET", "BROWN",
	"LIGHTGRAY", "PINK", "YELLOW", "GREEN", "SKYBLUE", "PURPLE", "BEIGE"
}

local colorsRecs = {}
local colorState = {}

for i = 0, MAX_COLORS_COUNT - 1 do
	colorsRecs[i] = rl.new("Rectangle",
		20.0 + 100.0*(i%7) + 10.0*(i%7),
		80.0 + 100.0*math.floor(i/7) + 10.0*math.floor(i/7),
		100.0,
		100.0
	)
	colorState[i] = 0
end

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	local mousePoint = rl.GetMousePosition()

	for i = 0, MAX_COLORS_COUNT - 1 do
		if rl.CheckCollisionPointRec(mousePoint, colorsRecs[i]) then
			colorState[i] = 1
		else
			colorState[i] = 0
		end
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawText("raylib colors palette", 28, 42, 20, rl.BLACK)
	rl.DrawText("press SPACE to see all colors", rl.GetScreenWidth() - 180, rl.GetScreenHeight() - 40, 10, rl.GRAY)

	for i = 0, MAX_COLORS_COUNT - 1 do
		if colorState[i] == 1 then
			rl.DrawRectangleRec(colorsRecs[i], rl.Fade(colors[i], 0.6))
		else
			rl.DrawRectangleRec(colorsRecs[i], rl.Fade(colors[i], 1.0))
		end

		if rl.IsKeyDown(rl.KEY_SPACE) or colorState[i] == 1 then
			rl.DrawRectangle(
				math.floor(colorsRecs[i].x),
				math.floor(colorsRecs[i].y + colorsRecs[i].height - 26),
				math.floor(colorsRecs[i].width),
				20,
				rl.BLACK
			)
			rl.DrawRectangleLinesEx(colorsRecs[i], 6, rl.Fade(rl.BLACK, 0.3))
			rl.DrawText(colorNames[i],
				math.floor(colorsRecs[i].x + colorsRecs[i].width - rl.MeasureText(colorNames[i], 10) - 12),
				math.floor(colorsRecs[i].y + colorsRecs[i].height - 20),
				10,
				colors[i]
			)
		end
	end

	rl.EndDrawing()
end

rl.CloseWindow()
