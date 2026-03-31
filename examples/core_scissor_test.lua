-- raylib [core] example - scissor test

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - scissor test")

local scissorArea = rl.new("Rectangle", 0, 0, 300, 300)
local scissorMode = true

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyPressed(rl.KEY_S) then scissorMode = not scissorMode end

	-- Centre the scissor area around the mouse position
	scissorArea.x = rl.GetMouseX() - scissorArea.width / 2
	scissorArea.y = rl.GetMouseY() - scissorArea.height / 2

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	if scissorMode then rl.BeginScissorMode(scissorArea.x, scissorArea.y, scissorArea.width, scissorArea.height) end

	-- Draw full screen rectangle and some text
	-- NOTE: Only part defined by scissor area will be rendered
	rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.RED)
	rl.DrawText("Move the mouse around to reveal this text!", 190, 200, 20, rl.LIGHTGRAY)

	if scissorMode then rl.EndScissorMode() end

	rl.DrawRectangleLinesEx(scissorArea, 1, rl.BLACK)
	rl.DrawText("Press S to toggle scissor test", 10, 10, 20, rl.BLACK)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
