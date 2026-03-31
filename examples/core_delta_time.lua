-- raylib [core] example - delta time

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - delta time")

local currentFps = 60

-- Store the position for both circles
local deltaCircle = rl.new("Vector2", 0, screenHeight / 3.0)
local frameCircle = rl.new("Vector2", 0, screenHeight * (2.0 / 3.0))

-- The speed applied to both circles
local speed = 10.0
local circleRadius = 32.0

rl.SetTargetFPS(currentFps)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- Adjust the FPS target based on the mouse wheel
	local mouseWheel = rl.GetMouseWheelMove()
	if mouseWheel ~= 0 then
		currentFps = currentFps + math.floor(mouseWheel)
		if currentFps < 0 then currentFps = 0 end
		rl.SetTargetFPS(currentFps)
	end

	-- GetFrameTime() returns the time it took to draw the last frame, in seconds (usually called delta time)
	-- Uses the delta time to make the circle look like it's moving at a "consistent" speed regardless of FPS

	-- Multiply by 6.0 (an arbitrary value) in order to make the speed
	-- visually closer to the other circle (at 60 fps), for comparison
	deltaCircle.x = deltaCircle.x + rl.GetFrameTime() * 6.0 * speed
	-- This circle can move faster or slower visually depending on the FPS
	frameCircle.x = frameCircle.x + 0.1 * speed

	-- If either circle is off the screen, reset it back to the start
	if deltaCircle.x > screenWidth then deltaCircle.x = 0 end
	if frameCircle.x > screenWidth then frameCircle.x = 0 end

	-- Reset both circles positions
	if rl.IsKeyPressed(rl.KEY_R) then
		deltaCircle.x = 0
		frameCircle.x = 0
	end

	-- Draw
	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		-- Draw both circles to the screen
		rl.DrawCircleV(deltaCircle, circleRadius, rl.RED)
		rl.DrawCircleV(frameCircle, circleRadius, rl.BLUE)

		-- Draw the help text
		local fpsText
		if currentFps <= 0 then
			fpsText = string.format("FPS: unlimited (%i)", rl.GetFPS())
		else
			fpsText = string.format("FPS: %i (target: %i)", rl.GetFPS(), currentFps)
		end
		rl.DrawText(fpsText, 10, 10, 20, rl.DARKGRAY)
		rl.DrawText(string.format("Frame time: %02.02f ms", rl.GetFrameTime()), 10, 30, 20, rl.DARKGRAY)
		rl.DrawText("Use the scroll wheel to change the fps limit, r to reset", 10, 50, 20, rl.DARKGRAY)

		-- Draw the text above the circles
		rl.DrawText("FUNC: x += GetFrameTime()*speed", 10, 90, 20, rl.RED)
		rl.DrawText("FUNC: x += speed", 10, 240, 20, rl.BLUE)
	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
