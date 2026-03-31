-- raylib [core] example - input keys

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - input keys")

local ballPosition = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyDown(rl.KEY_RIGHT) then ballPosition.x = ballPosition.x + 2.0 end
	if rl.IsKeyDown(rl.KEY_LEFT) then ballPosition.x = ballPosition.x - 2.0 end
	if rl.IsKeyDown(rl.KEY_UP) then ballPosition.y = ballPosition.y - 2.0 end
	if rl.IsKeyDown(rl.KEY_DOWN) then ballPosition.y = ballPosition.y + 2.0 end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawText("move the ball with arrow keys", 10, 10, 20, rl.DARKGRAY)

	rl.DrawCircleV(ballPosition, 50, rl.MAROON)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
