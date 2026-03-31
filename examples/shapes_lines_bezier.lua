--[[
    raylib [shapes] example - lines bezier

    Example complexity rating: [★☆☆☆] 1/4

    Example originally created with raylib 1.7, last time updated with raylib 1.7

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2017-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - lines bezier")

local startPoint = rl.new("Vector2", 30, 30)
local endPoint = rl.new("Vector2", screenWidth - 30, screenHeight - 30)
local moveStartPoint = false
local moveEndPoint = false

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	local mouse = rl.GetMousePosition()

	if rl.CheckCollisionPointCircle(mouse, startPoint, 10.0) and rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) then
		moveStartPoint = true
	elseif rl.CheckCollisionPointCircle(mouse, endPoint, 10.0) and rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) then
		moveEndPoint = true
	end

	if moveStartPoint then
		startPoint = mouse
		if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then moveStartPoint = false end
	end

	if moveEndPoint then
		endPoint = mouse
		if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then moveEndPoint = false end
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawText("MOVE START-END POINTS WITH MOUSE", 15, 20, 20, rl.GRAY)

	-- Draw line Cubic Bezier, in-out interpolation (easing), no control points
	rl.DrawLineBezier(startPoint, endPoint, 4.0, rl.BLUE)

	-- Draw start-end spline circles with some details
	if rl.CheckCollisionPointCircle(mouse, startPoint, 10.0) then
		if moveStartPoint then
			rl.DrawCircleV(startPoint, 14.0, rl.RED)
		else
			rl.DrawCircleV(startPoint, 14.0, rl.BLUE)
		end
	else
		if moveStartPoint then
			rl.DrawCircleV(startPoint, 8.0, rl.RED)
		else
			rl.DrawCircleV(startPoint, 8.0, rl.BLUE)
		end
	end

	if rl.CheckCollisionPointCircle(mouse, endPoint, 10.0) then
		if moveEndPoint then
			rl.DrawCircleV(endPoint, 14.0, rl.RED)
		else
			rl.DrawCircleV(endPoint, 14.0, rl.BLUE)
		end
	else
		if moveEndPoint then
			rl.DrawCircleV(endPoint, 8.0, rl.RED)
		else
			rl.DrawCircleV(endPoint, 8.0, rl.BLUE)
		end
	end

	rl.EndDrawing()
end

rl.CloseWindow()
