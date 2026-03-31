-- raylib [shapes] example - rlgl triangle

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - rlgl triangle")

local startingPositions = {
	rl.new("Vector2", 400.0, 150.0),
	rl.new("Vector2", 300.0, 300.0),
	rl.new("Vector2", 500.0, 300.0),
}
local trianglePositions = {
	rl.new("Vector2", startingPositions[1].x, startingPositions[1].y),
	rl.new("Vector2", startingPositions[2].x, startingPositions[2].y),
	rl.new("Vector2", startingPositions[3].x, startingPositions[3].y),
}

local triangleIndex = -1
local linesMode = false
local handleRadius = 8.0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsKeyPressed(rl.KEY_SPACE) then linesMode = not linesMode end

	for i = 0, 2 do
		if rl.CheckCollisionPointCircle(rl.GetMousePosition(), trianglePositions[i + 1], handleRadius) and
			rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) then
			triangleIndex = i
			break
		end
	end

	if triangleIndex ~= -1 then
		local mouseDelta = rl.GetMouseDelta()
		trianglePositions[triangleIndex + 1].x = trianglePositions[triangleIndex + 1].x + mouseDelta.x
		trianglePositions[triangleIndex + 1].y = trianglePositions[triangleIndex + 1].y + mouseDelta.y
	end

	if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then triangleIndex = -1 end

	if rl.IsKeyPressed(rl.KEY_LEFT) then rl.rlEnableBackfaceCulling() end
	if rl.IsKeyPressed(rl.KEY_RIGHT) then rl.rlDisableBackfaceCulling() end

	if rl.IsKeyPressed(rl.KEY_R) then
		for i = 1, 3 do
			trianglePositions[i].x = startingPositions[i].x
			trianglePositions[i].y = startingPositions[i].y
		end
		rl.rlEnableBackfaceCulling()
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		if linesMode then
			rl.rlBegin(rl.RL_LINES)
				rl.rlColor4ub(255, 0, 0, 255)
				rl.rlVertex2f(trianglePositions[1].x, trianglePositions[1].y)
				rl.rlColor4ub(0, 255, 0, 255)
				rl.rlVertex2f(trianglePositions[2].x, trianglePositions[2].y)

				rl.rlColor4ub(0, 255, 0, 255)
				rl.rlVertex2f(trianglePositions[2].x, trianglePositions[2].y)
				rl.rlColor4ub(0, 0, 255, 255)
				rl.rlVertex2f(trianglePositions[3].x, trianglePositions[3].y)

				rl.rlColor4ub(0, 0, 255, 255)
				rl.rlVertex2f(trianglePositions[3].x, trianglePositions[3].y)
				rl.rlColor4ub(255, 0, 0, 255)
				rl.rlVertex2f(trianglePositions[1].x, trianglePositions[1].y)
			rl.rlEnd()
		else
			rl.rlBegin(rl.RL_TRIANGLES)
				rl.rlColor4ub(255, 0, 0, 255)
				rl.rlVertex2f(trianglePositions[1].x, trianglePositions[1].y)
				rl.rlColor4ub(0, 255, 0, 255)
				rl.rlVertex2f(trianglePositions[2].x, trianglePositions[2].y)
				rl.rlColor4ub(0, 0, 255, 255)
				rl.rlVertex2f(trianglePositions[3].x, trianglePositions[3].y)
			rl.rlEnd()
		end

		for i = 0, 2 do
			if rl.CheckCollisionPointCircle(rl.GetMousePosition(), trianglePositions[i + 1], handleRadius) then
				rl.DrawCircleV(trianglePositions[i + 1], handleRadius, rl.Fade(rl.DARKGRAY, 0.5))
			end

			if i == triangleIndex then rl.DrawCircleV(trianglePositions[i + 1], handleRadius, rl.DARKGRAY) end

			rl.DrawCircleLinesV(trianglePositions[i + 1], handleRadius, rl.BLACK)
		end

		rl.DrawText("SPACE: Toggle lines mode", 10, 10, 20, rl.DARKGRAY)
		rl.DrawText("LEFT-RIGHT: Toggle backface culling", 10, 40, 20, rl.DARKGRAY)
		rl.DrawText("MOUSE: Click and drag vertex points", 10, 70, 20, rl.DARKGRAY)
		rl.DrawText("R: Reset triangle to start positions", 10, 100, 20, rl.DARKGRAY)
	rl.EndDrawing()
end

rl.CloseWindow()
