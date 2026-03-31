--[[
    raylib [shapes] example - dashed line

    Example complexity rating: [★☆☆☆] 1/4

    Example originally created with raylib 5.5, last time updated with raylib 5.5

    Example contributed by Luis Almeida (@luis605)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2025 Luis Almeida (@luis605)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - dashed line")

-- Line Properties
local lineStartPosition = rl.new("Vector2", 20.0, 50.0)
local lineEndPosition = rl.new("Vector2", 780.0, 400.0)
local dashLength = 25.0
local blankLength = 15.0

-- Color selection
local lineColors = { rl.RED, rl.ORANGE, rl.GOLD, rl.GREEN, rl.BLUE, rl.VIOLET, rl.PINK, rl.BLACK }
local colorIndex = 1

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	lineEndPosition = rl.GetMousePosition()

	-- Change Dash Length (UP/DOWN arrows)
	if rl.IsKeyDown(rl.KEY_UP) then dashLength = dashLength + 1.0 end
	if rl.IsKeyDown(rl.KEY_DOWN) and dashLength > 1.0 then dashLength = dashLength - 1.0 end

	-- Change Space Length (LEFT/RIGHT arrows)
	if rl.IsKeyDown(rl.KEY_RIGHT) then blankLength = blankLength + 1.0 end
	if rl.IsKeyDown(rl.KEY_LEFT) and blankLength > 1.0 then blankLength = blankLength - 1.0 end

	-- Cycle through colors ('C' key)
	if rl.IsKeyPressed(rl.KEY_C) then
		colorIndex = colorIndex % #lineColors + 1
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	-- Draw the dashed line with the current properties
	rl.DrawLineDashed(lineStartPosition, lineEndPosition, math.floor(dashLength), math.floor(blankLength), lineColors[colorIndex])

	-- Draw UI and Instructions
	rl.DrawRectangle(5, 5, 265, 95, rl.Fade(rl.SKYBLUE, 0.5))
	rl.DrawRectangleLines(5, 5, 265, 95, rl.BLUE)

	rl.DrawText("CONTROLS:", 15, 15, 10, rl.BLACK)
	rl.DrawText("UP/DOWN: Change Dash Length", 15, 35, 10, rl.BLACK)
	rl.DrawText("LEFT/RIGHT: Change Space Length", 15, 55, 10, rl.BLACK)
	rl.DrawText("C: Cycle Color", 15, 75, 10, rl.BLACK)

	rl.DrawText(string.format("Dash: %.0f | Space: %.0f", dashLength, blankLength), 15, 115, 10, rl.DARKGRAY)

	rl.DrawFPS(screenWidth - 80, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
