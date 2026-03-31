-- raylib [core] example - screen recording
-- NOTE: GIF recording via msf_gif is not available in the Lua bindings.
-- This example demonstrates the animation without the GIF recording feature.
-- Use CTRL+R to take a screenshot instead.

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - screen recording")

local MAX_SINEWAVE_POINTS = 256

local circlePosition = rl.new("Vector2", 0, screenHeight / 2.0)
local timeCounter = 0.0

-- Get sine wave points for line drawing
local sinePoints = {}
for i = 0, MAX_SINEWAVE_POINTS - 1 do
	sinePoints[i] = rl.new("Vector2",
		i * screenWidth / 180.0,
		screenHeight / 2.0 + 150 * math.sin((2 * math.pi / 1.5) * (1.0 / 60.0) * i))
end

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	timeCounter = timeCounter + rl.GetFrameTime()
	circlePosition.x = circlePosition.x + screenWidth / 180.0
	circlePosition.y = screenHeight / 2.0 + 150 * math.sin((2 * math.pi / 1.5) * timeCounter)
	if circlePosition.x > screenWidth then
		circlePosition.x = 0.0
		circlePosition.y = screenHeight / 2.0
		timeCounter = 0.0
	end

	-- Take screenshot on CTRL+R
	if rl.IsKeyDown(rl.KEY_LEFT_CONTROL) and rl.IsKeyPressed(rl.KEY_R) then
		rl.TakeScreenshot(string.format("%s/screenshot.png", rl.GetApplicationDirectory()))
		rl.TraceLog(rl.LOG_INFO, "Screenshot saved")
	end

	-- Draw
	rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		for i = 0, MAX_SINEWAVE_POINTS - 2 do
			rl.DrawLineV(sinePoints[i], sinePoints[i + 1], rl.MAROON)
			rl.DrawCircleV(sinePoints[i], 3, rl.MAROON)
		end

		rl.DrawCircleV(circlePosition, 30, rl.RED)

		rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
