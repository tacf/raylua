-- raylib [core] example - input multitouch

local MAX_TOUCH_POINTS = 10

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - input multitouch")

local touchPositions = {}
for i = 0, MAX_TOUCH_POINTS - 1 do
	touchPositions[i] = rl.new("Vector2", 0, 0)
end

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- Get the touch point count (how many fingers are touching the screen)
	local tCount = rl.GetTouchPointCount()
	-- Clamp touch points available (set the maximum touch points allowed)
	if tCount > MAX_TOUCH_POINTS then tCount = MAX_TOUCH_POINTS end
	-- Get touch points positions
	for i = 0, tCount - 1 do
		touchPositions[i] = rl.GetTouchPosition(i)
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	for i = 0, tCount - 1 do
		-- Make sure point is not (0, 0) as this means there is no touch for it
		if (touchPositions[i].x > 0) and (touchPositions[i].y > 0) then
			-- Draw circle and touch index number
			rl.DrawCircleV(touchPositions[i], 34, rl.ORANGE)
			rl.DrawText(string.format("%d", i), math.floor(touchPositions[i].x) - 10, math.floor(touchPositions[i].y) - 70, 40, rl.BLACK)
		end
	end

	rl.DrawText("touch the screen at multiple locations to get multiple balls", 10, 10, 20, rl.DARKGRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
