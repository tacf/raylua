-- raylib [core] example - input mouse wheel

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - input mouse wheel")

local boxPositionY = screenHeight / 2 - 40
local scrollSpeed = 4

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	boxPositionY = boxPositionY - math.floor(rl.GetMouseWheelMove() * scrollSpeed)

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawRectangle(screenWidth / 2 - 40, boxPositionY, 80, 80, rl.MAROON)

	rl.DrawText("Use mouse wheel to move the cube up and down!", 10, 10, 20, rl.GRAY)
	rl.DrawText(string.format("Box position Y: %03i", boxPositionY), 10, 40, 20, rl.LIGHTGRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
