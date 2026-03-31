-- raylib [core] example - custom frame control

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - custom frame control")

-- Custom timing variables
local previousTime = rl.GetTime()
local currentTime = 0.0
local updateDrawTime = 0.0
local waitTime = 0.0
local deltaTime = 0.0

local timeCounter = 0.0
local position = 0.0
local pause = false

local targetFPS = 60

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	rl.PollInputEvents()

	if rl.IsKeyPressed(rl.KEY_SPACE) then pause = not pause end

	if rl.IsKeyPressed(rl.KEY_UP) then
		targetFPS = targetFPS + 20
	elseif rl.IsKeyPressed(rl.KEY_DOWN) then
		targetFPS = targetFPS - 20
	end

	if targetFPS < 0 then targetFPS = 0 end

	if not pause then
		position = position + 200 * deltaTime
		if position >= rl.GetScreenWidth() then position = 0 end
		timeCounter = timeCounter + deltaTime
	end

	-- Draw
	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		for i = 0, math.floor(rl.GetScreenWidth() / 200) - 1 do
			rl.DrawRectangle(200 * i, 0, 1, rl.GetScreenHeight(), rl.SKYBLUE)
		end

		rl.DrawCircle(math.floor(position), rl.GetScreenHeight() / 2 - 25, 50, rl.RED)

		rl.DrawText(string.format("%03.0f ms", timeCounter * 1000.0), math.floor(position) - 40, rl.GetScreenHeight() / 2 - 100, 20, rl.MAROON)
		rl.DrawText(string.format("PosX: %03.0f", position), math.floor(position) - 50, rl.GetScreenHeight() / 2 + 40, 20, rl.BLACK)

		rl.DrawText("Circle is moving at a constant 200 pixels/sec,\nindependently of the frame rate.", 10, 10, 20, rl.DARKGRAY)
		rl.DrawText("PRESS SPACE to PAUSE MOVEMENT", 10, rl.GetScreenHeight() - 60, 20, rl.GRAY)
		rl.DrawText("PRESS UP | DOWN to CHANGE TARGET FPS", 10, rl.GetScreenHeight() - 30, 20, rl.GRAY)
		rl.DrawText(string.format("TARGET FPS: %i", targetFPS), rl.GetScreenWidth() - 220, 10, 20, rl.LIME)
		if deltaTime ~= 0 then
			rl.DrawText(string.format("CURRENT FPS: %i", math.floor(1.0 / deltaTime)), rl.GetScreenWidth() - 220, 40, 20, rl.GREEN)
		end
	rl.EndDrawing()

	-- Custom frame control
	rl.SwapScreenBuffer()

	currentTime = rl.GetTime()
	updateDrawTime = currentTime - previousTime

	if targetFPS > 0 then
		waitTime = (1.0 / targetFPS) - updateDrawTime
		if waitTime > 0.0 then
			rl.WaitTime(waitTime)
			currentTime = rl.GetTime()
			deltaTime = currentTime - previousTime
		end
	else
		deltaTime = updateDrawTime
	end

	previousTime = currentTime
end

-- De-Initialization
rl.CloseWindow()
