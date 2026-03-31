--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_mouse_trail.c

]]

-- raylib [shapes] example - mouse trail

local MAX_TRAIL_LENGTH = 30

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - mouse trail")

local trailPositions = {}
for i = 1, MAX_TRAIL_LENGTH do
	trailPositions[i] = rl.new("Vector2", 0.0, 0.0)
end

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	local mousePosition = rl.GetMousePosition()

	for i = MAX_TRAIL_LENGTH, 2, -1 do
		trailPositions[i] = rl.new("Vector2", trailPositions[i - 1].x, trailPositions[i - 1].y)
	end
	trailPositions[1] = mousePosition

	rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		for i = 1, MAX_TRAIL_LENGTH do
			local pos = trailPositions[i]
			if pos.x ~= 0.0 or pos.y ~= 0.0 then
				local ratio = (MAX_TRAIL_LENGTH - i + 1) / MAX_TRAIL_LENGTH
				local trailColor = rl.Fade(rl.SKYBLUE, ratio * 0.5 + 0.5)
				local trailRadius = 15.0 * ratio
				rl.DrawCircleV(pos, trailRadius, trailColor)
			end
		end

		rl.DrawCircleV(mousePosition, 15.0, rl.WHITE)

		rl.DrawText("Move the mouse to see the trail effect!", 10, screenHeight - 30, 20, rl.LIGHTGRAY)

	rl.EndDrawing()
end

rl.CloseWindow()
