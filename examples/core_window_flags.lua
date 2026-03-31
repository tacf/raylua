-- raylib [core] example - window flags

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - window flags")

local ballPosition = rl.new("Vector2", rl.GetScreenWidth() / 2.0, rl.GetScreenHeight() / 2.0)
local ballSpeed = rl.new("Vector2", 5.0, 4.0)
local ballRadius = 20

local framesCounter = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyPressed(rl.KEY_F) then rl.ToggleFullscreen() end

	if rl.IsKeyPressed(rl.KEY_R) then
		if rl.IsWindowState(rl.FLAG_WINDOW_RESIZABLE) then rl.ClearWindowState(rl.FLAG_WINDOW_RESIZABLE)
		else rl.SetWindowState(rl.FLAG_WINDOW_RESIZABLE)
		end
	end

	if rl.IsKeyPressed(rl.KEY_D) then
		if rl.IsWindowState(rl.FLAG_WINDOW_UNDECORATED) then rl.ClearWindowState(rl.FLAG_WINDOW_UNDECORATED)
		else rl.SetWindowState(rl.FLAG_WINDOW_UNDECORATED)
		end
	end

	if rl.IsKeyPressed(rl.KEY_H) then
		if not rl.IsWindowState(rl.FLAG_WINDOW_HIDDEN) then rl.SetWindowState(rl.FLAG_WINDOW_HIDDEN) end
		framesCounter = 0
	end

	if rl.IsWindowState(rl.FLAG_WINDOW_HIDDEN) then
		framesCounter = framesCounter + 1
		if framesCounter >= 240 then rl.ClearWindowState(rl.FLAG_WINDOW_HIDDEN) end
	end

	if rl.IsKeyPressed(rl.KEY_N) then
		if not rl.IsWindowState(rl.FLAG_WINDOW_MINIMIZED) then rl.MinimizeWindow() end
		framesCounter = 0
	end

	if rl.IsWindowState(rl.FLAG_WINDOW_MINIMIZED) then
		framesCounter = framesCounter + 1
		if framesCounter >= 240 then
			rl.RestoreWindow()
			framesCounter = 0
		end
	end

	if rl.IsKeyPressed(rl.KEY_M) then
		if rl.IsWindowState(rl.FLAG_WINDOW_MAXIMIZED) then rl.RestoreWindow()
		else rl.MaximizeWindow()
		end
	end

	if rl.IsKeyPressed(rl.KEY_U) then
		if rl.IsWindowState(rl.FLAG_WINDOW_UNFOCUSED) then rl.ClearWindowState(rl.FLAG_WINDOW_UNFOCUSED)
		else rl.SetWindowState(rl.FLAG_WINDOW_UNFOCUSED)
		end
	end

	if rl.IsKeyPressed(rl.KEY_T) then
		if rl.IsWindowState(rl.FLAG_WINDOW_TOPMOST) then rl.ClearWindowState(rl.FLAG_WINDOW_TOPMOST)
		else rl.SetWindowState(rl.FLAG_WINDOW_TOPMOST)
		end
	end

	if rl.IsKeyPressed(rl.KEY_A) then
		if rl.IsWindowState(rl.FLAG_WINDOW_ALWAYS_RUN) then rl.ClearWindowState(rl.FLAG_WINDOW_ALWAYS_RUN)
		else rl.SetWindowState(rl.FLAG_WINDOW_ALWAYS_RUN)
		end
	end

	if rl.IsKeyPressed(rl.KEY_V) then
		if rl.IsWindowState(rl.FLAG_VSYNC_HINT) then rl.ClearWindowState(rl.FLAG_VSYNC_HINT)
		else rl.SetWindowState(rl.FLAG_VSYNC_HINT)
		end
	end

	if rl.IsKeyPressed(rl.KEY_B) then rl.ToggleBorderlessWindowed() end

	-- Bouncing ball logic
	ballPosition.x = ballPosition.x + ballSpeed.x
	ballPosition.y = ballPosition.y + ballSpeed.y
	if (ballPosition.x >= (rl.GetScreenWidth() - ballRadius)) or (ballPosition.x <= ballRadius) then ballSpeed.x = ballSpeed.x * -1.0 end
	if (ballPosition.y >= (rl.GetScreenHeight() - ballRadius)) or (ballPosition.y <= ballRadius) then ballSpeed.y = ballSpeed.y * -1.0 end

	-- Draw
	rl.BeginDrawing()

	if rl.IsWindowState(rl.FLAG_WINDOW_TRANSPARENT) then rl.ClearBackground(rl.BLANK)
	else rl.ClearBackground(rl.RAYWHITE)
	end

	rl.DrawCircleV(ballPosition, ballRadius, rl.MAROON)
	rl.DrawRectangleLinesEx(rl.new("Rectangle", 0, 0, rl.GetScreenWidth(), rl.GetScreenHeight()), 4, rl.RAYWHITE)

	rl.DrawCircleV(rl.GetMousePosition(), 10, rl.DARKBLUE)

	rl.DrawFPS(10, 10)

	rl.DrawText(string.format("Screen Size: [%i, %i]", rl.GetScreenWidth(), rl.GetScreenHeight()), 10, 40, 10, rl.GREEN)

	-- Draw window state info
	rl.DrawText("Following flags can be set after window creation:", 10, 60, 10, rl.GRAY)
	if rl.IsWindowState(rl.FLAG_FULLSCREEN_MODE) then rl.DrawText("[F] FLAG_FULLSCREEN_MODE: on", 10, 80, 10, rl.LIME)
	else rl.DrawText("[F] FLAG_FULLSCREEN_MODE: off", 10, 80, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_WINDOW_RESIZABLE) then rl.DrawText("[R] FLAG_WINDOW_RESIZABLE: on", 10, 100, 10, rl.LIME)
	else rl.DrawText("[R] FLAG_WINDOW_RESIZABLE: off", 10, 100, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_WINDOW_UNDECORATED) then rl.DrawText("[D] FLAG_WINDOW_UNDECORATED: on", 10, 120, 10, rl.LIME)
	else rl.DrawText("[D] FLAG_WINDOW_UNDECORATED: off", 10, 120, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_WINDOW_HIDDEN) then rl.DrawText("[H] FLAG_WINDOW_HIDDEN: on", 10, 140, 10, rl.LIME)
	else rl.DrawText("[H] FLAG_WINDOW_HIDDEN: off (hides for 3 seconds)", 10, 140, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_WINDOW_MINIMIZED) then rl.DrawText("[N] FLAG_WINDOW_MINIMIZED: on", 10, 160, 10, rl.LIME)
	else rl.DrawText("[N] FLAG_WINDOW_MINIMIZED: off (restores after 3 seconds)", 10, 160, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_WINDOW_MAXIMIZED) then rl.DrawText("[M] FLAG_WINDOW_MAXIMIZED: on", 10, 180, 10, rl.LIME)
	else rl.DrawText("[M] FLAG_WINDOW_MAXIMIZED: off", 10, 180, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_WINDOW_UNFOCUSED) then rl.DrawText("[U] FLAG_WINDOW_UNFOCUSED: on", 10, 200, 10, rl.LIME)
	else rl.DrawText("[U] FLAG_WINDOW_UNFOCUSED: off", 10, 200, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_WINDOW_TOPMOST) then rl.DrawText("[T] FLAG_WINDOW_TOPMOST: on", 10, 220, 10, rl.LIME)
	else rl.DrawText("[T] FLAG_WINDOW_TOPMOST: off", 10, 220, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_WINDOW_ALWAYS_RUN) then rl.DrawText("[A] FLAG_WINDOW_ALWAYS_RUN: on", 10, 240, 10, rl.LIME)
	else rl.DrawText("[A] FLAG_WINDOW_ALWAYS_RUN: off", 10, 240, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_VSYNC_HINT) then rl.DrawText("[V] FLAG_VSYNC_HINT: on", 10, 260, 10, rl.LIME)
	else rl.DrawText("[V] FLAG_VSYNC_HINT: off", 10, 260, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_BORDERLESS_WINDOWED_MODE) then rl.DrawText("[B] FLAG_BORDERLESS_WINDOWED_MODE: on", 10, 280, 10, rl.LIME)
	else rl.DrawText("[B] FLAG_BORDERLESS_WINDOWED_MODE: off", 10, 280, 10, rl.MAROON)
	end

	rl.DrawText("Following flags can only be set before window creation:", 10, 320, 10, rl.GRAY)
	if rl.IsWindowState(rl.FLAG_WINDOW_HIGHDPI) then rl.DrawText("FLAG_WINDOW_HIGHDPI: on", 10, 340, 10, rl.LIME)
	else rl.DrawText("FLAG_WINDOW_HIGHDPI: off", 10, 340, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_WINDOW_TRANSPARENT) then rl.DrawText("FLAG_WINDOW_TRANSPARENT: on", 10, 360, 10, rl.LIME)
	else rl.DrawText("FLAG_WINDOW_TRANSPARENT: off", 10, 360, 10, rl.MAROON)
	end
	if rl.IsWindowState(rl.FLAG_MSAA_4X_HINT) then rl.DrawText("FLAG_MSAA_4X_HINT: on", 10, 380, 10, rl.LIME)
	else rl.DrawText("FLAG_MSAA_4X_HINT: off", 10, 380, 10, rl.MAROON)
	end

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
