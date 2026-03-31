-- raylib [core] example - input virtual controls

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - input virtual controls")

local BUTTON_NONE = -1
local BUTTON_UP = 0
local BUTTON_LEFT = 1
local BUTTON_RIGHT = 2
local BUTTON_DOWN = 3

local padPosition = rl.new("Vector2", 100, 350)
local buttonRadius = 30

local buttonPositions = {
	rl.new("Vector2", padPosition.x, padPosition.y - buttonRadius * 1.5),                     -- Up
	rl.new("Vector2", padPosition.x - buttonRadius * 1.5, padPosition.y),                     -- Left
	rl.new("Vector2", padPosition.x + buttonRadius * 1.5, padPosition.y),                     -- Right
	rl.new("Vector2", padPosition.x, padPosition.y + buttonRadius * 1.5),                     -- Down
}

local arrowTris = {
	-- Up
	{
		rl.new("Vector2", buttonPositions[1].x, buttonPositions[1].y - 12),
		rl.new("Vector2", buttonPositions[1].x - 9, buttonPositions[1].y + 9),
		rl.new("Vector2", buttonPositions[1].x + 9, buttonPositions[1].y + 9),
	},
	-- Left
	{
		rl.new("Vector2", buttonPositions[2].x + 9, buttonPositions[2].y - 9),
		rl.new("Vector2", buttonPositions[2].x - 12, buttonPositions[2].y),
		rl.new("Vector2", buttonPositions[2].x + 9, buttonPositions[2].y + 9),
	},
	-- Right
	{
		rl.new("Vector2", buttonPositions[3].x + 12, buttonPositions[3].y),
		rl.new("Vector2", buttonPositions[3].x - 9, buttonPositions[3].y - 9),
		rl.new("Vector2", buttonPositions[3].x - 9, buttonPositions[3].y + 9),
	},
	-- Down
	{
		rl.new("Vector2", buttonPositions[4].x - 9, buttonPositions[4].y - 9),
		rl.new("Vector2", buttonPositions[4].x, buttonPositions[4].y + 12),
		rl.new("Vector2", buttonPositions[4].x + 9, buttonPositions[4].y - 9),
	},
}

local buttonLabelColors = {
	rl.YELLOW,  -- Up
	rl.BLUE,    -- Left
	rl.RED,     -- Right
	rl.GREEN,   -- Down
}

local pressedButton = BUTTON_NONE
local inputPosition = rl.new("Vector2", 0, 0)

local playerPosition = rl.new("Vector2", screenWidth / 2, screenHeight / 2)
local playerSpeed = 75

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.GetTouchPointCount() > 0 then
		inputPosition = rl.GetTouchPosition(0)
	else
		inputPosition = rl.GetMousePosition()
	end

	-- Reset pressed button to none
	pressedButton = BUTTON_NONE

	-- Make sure user is pressing left mouse button if they're from desktop
	if rl.GetTouchPointCount() > 0 or
		(rl.GetTouchPointCount() == 0 and rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT)) then
		-- Find nearest D-Pad button to the input position
		for i = 1, 4 do
			local distX = math.abs(buttonPositions[i].x - inputPosition.x)
			local distY = math.abs(buttonPositions[i].y - inputPosition.y)

			if (distX + distY) < buttonRadius then
				pressedButton = i - 1
				break
			end
		end
	end

	-- Move player according to pressed button
	if pressedButton == BUTTON_UP then
		playerPosition.y = playerPosition.y - playerSpeed * rl.GetFrameTime()
	elseif pressedButton == BUTTON_LEFT then
		playerPosition.x = playerPosition.x - playerSpeed * rl.GetFrameTime()
	elseif pressedButton == BUTTON_RIGHT then
		playerPosition.x = playerPosition.x + playerSpeed * rl.GetFrameTime()
	elseif pressedButton == BUTTON_DOWN then
		playerPosition.y = playerPosition.y + playerSpeed * rl.GetFrameTime()
	end

	-- Draw
	rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		-- Draw world
		rl.DrawCircleV(playerPosition, 50, rl.MAROON)

		-- Draw GUI
		for i = 1, 4 do
			if i - 1 == pressedButton then
				rl.DrawCircleV(buttonPositions[i], buttonRadius, rl.DARKGRAY)
			else
				rl.DrawCircleV(buttonPositions[i], buttonRadius, rl.BLACK)
			end

			rl.DrawTriangle(arrowTris[i][1], arrowTris[i][2], arrowTris[i][3], buttonLabelColors[i])
		end

		rl.DrawText("move the player with D-Pad buttons", 10, 10, 20, rl.DARKGRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
