--[[
    raylib [shapes] example - basic shapes

    Example complexity rating: [★☆☆☆] 1/4

    Example originally created with raylib 1.0, last time updated with raylib 4.2

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2014-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - basic shapes")

local rotation = 0.0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	rotation = rotation + 0.2

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawText("some basic shapes available on raylib", 20, 20, 20, rl.DARKGRAY)

	-- Circle shapes and lines
	rl.DrawCircle(math.floor(screenWidth/5), 120, 35, rl.DARKBLUE)
	rl.DrawCircleGradient(math.floor(screenWidth/5), 220, 60, rl.GREEN, rl.SKYBLUE)
	rl.DrawCircleLines(math.floor(screenWidth/5), 340, 80, rl.DARKBLUE)
	rl.DrawEllipse(math.floor(screenWidth/5), 120, 25, 20, rl.YELLOW)
	rl.DrawEllipseLines(math.floor(screenWidth/5), 120, 30, 25, rl.YELLOW)

	-- Rectangle shapes and lines
	rl.DrawRectangle(math.floor(screenWidth/4)*2 - 60, 100, 120, 60, rl.RED)
	rl.DrawRectangleGradientH(math.floor(screenWidth/4)*2 - 90, 170, 180, 130, rl.MAROON, rl.GOLD)
	rl.DrawRectangleLines(math.floor(screenWidth/4)*2 - 40, 320, 80, 60, rl.ORANGE)

	-- Triangle shapes and lines
	rl.DrawTriangle(
		rl.new("Vector2", screenWidth/4.0*3.0, 80.0),
		rl.new("Vector2", screenWidth/4.0*3.0 - 60.0, 150.0),
		rl.new("Vector2", screenWidth/4.0*3.0 + 60.0, 150.0),
		rl.VIOLET
	)

	rl.DrawTriangleLines(
		rl.new("Vector2", screenWidth/4.0*3.0, 160.0),
		rl.new("Vector2", screenWidth/4.0*3.0 - 20.0, 230.0),
		rl.new("Vector2", screenWidth/4.0*3.0 + 20.0, 230.0),
		rl.DARKBLUE
	)

	-- Polygon shapes and lines
	rl.DrawPoly(rl.new("Vector2", screenWidth/4.0*3, 330), 6, 80, rotation, rl.BROWN)
	rl.DrawPolyLines(rl.new("Vector2", screenWidth/4.0*3, 330), 6, 90, rotation, rl.BROWN)
	rl.DrawPolyLinesEx(rl.new("Vector2", screenWidth/4.0*3, 330), 6, 85, rotation, 6, rl.BEIGE)

	-- Draw separator line
	rl.DrawLine(18, 42, screenWidth - 18, 42, rl.BLACK)

	rl.EndDrawing()
end

rl.CloseWindow()
