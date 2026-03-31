--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_window_should_close.c

]]

-- raylib [core] example - window should close

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - window should close")

rl.SetExitKey(rl.KEY_NULL)  -- Disable KEY_ESCAPE to close window, X-button still works

local exitWindowRequested = false   -- Flag to request window to exit
local exitWindow = false            -- Flag to set window to exit

rl.SetTargetFPS(60)

-- Main game loop
while not exitWindow do
	-- Update
	-- Detect if X-button or KEY_ESCAPE have been pressed to close window
	if rl.WindowShouldClose() or rl.IsKeyPressed(rl.KEY_ESCAPE) then exitWindowRequested = true end

	if exitWindowRequested then
		if rl.IsKeyPressed(rl.KEY_Y) then exitWindow = true
		elseif rl.IsKeyPressed(rl.KEY_N) then exitWindowRequested = false
		end
	end

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	if exitWindowRequested then
		rl.DrawRectangle(0, 100, screenWidth, 200, rl.BLACK)
		rl.DrawText("Are you sure you want to exit program? [Y/N]", 40, 180, 30, rl.WHITE)
	else
		rl.DrawText("Try to close the window to get confirmation message!", 120, 200, 20, rl.LIGHTGRAY)
	end

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
