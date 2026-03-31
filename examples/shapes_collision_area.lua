--[[
    raylib [shapes] example - collision area

    Example complexity rating: [★★☆☆] 2/4

    Example originally created with raylib 2.5, last time updated with raylib 2.5

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2013-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - collision area")

-- Box A: Moving box
local boxA = rl.new("Rectangle", 10, screenHeight/2.0 - 50, 200, 100)
local boxASpeedX = 4

-- Box B: Mouse moved box
local boxB = rl.new("Rectangle", screenWidth/2.0 - 30, screenHeight/2.0 - 30, 60, 60)

local boxCollision = rl.new("Rectangle", 0, 0, 0, 0)

local screenUpperLimit = 40

local pause = false
local collision = false

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if not pause then boxA.x = boxA.x + boxASpeedX end

	-- Bounce box on x screen limits
	if (boxA.x + boxA.width) >= rl.GetScreenWidth() or boxA.x <= 0 then
		boxASpeedX = boxASpeedX * -1
	end

	-- Update player-controlled-box (boxB)
	boxB.x = rl.GetMouseX() - boxB.width/2
	boxB.y = rl.GetMouseY() - boxB.height/2

	-- Make sure Box B does not go out of move area limits
	if (boxB.x + boxB.width) >= rl.GetScreenWidth() then
		boxB.x = rl.GetScreenWidth() - boxB.width
	elseif boxB.x <= 0 then
		boxB.x = 0
	end

	if (boxB.y + boxB.height) >= rl.GetScreenHeight() then
		boxB.y = rl.GetScreenHeight() - boxB.height
	elseif boxB.y <= screenUpperLimit then
		boxB.y = screenUpperLimit
	end

	-- Check boxes collision
	collision = rl.CheckCollisionRecs(boxA, boxB)

	-- Get collision rectangle (only on collision)
	if collision then boxCollision = rl.GetCollisionRec(boxA, boxB) end

	-- Pause Box A movement
	if rl.IsKeyPressed(rl.KEY_SPACE) then pause = not pause end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	if collision then
		rl.DrawRectangle(0, 0, screenWidth, screenUpperLimit, rl.RED)
	else
		rl.DrawRectangle(0, 0, screenWidth, screenUpperLimit, rl.BLACK)
	end

	rl.DrawRectangleRec(boxA, rl.GOLD)
	rl.DrawRectangleRec(boxB, rl.BLUE)

	if collision then
		-- Draw collision area
		rl.DrawRectangleRec(boxCollision, rl.LIME)

		-- Draw collision message
		local msg = "COLLISION!"
		rl.DrawText(msg, math.floor(rl.GetScreenWidth()/2 - rl.MeasureText(msg, 20)/2), math.floor(screenUpperLimit/2 - 10), 20, rl.BLACK)

		-- Draw collision area
		local area = math.floor(boxCollision.width) * math.floor(boxCollision.height)
		rl.DrawText("Collision Area: " .. area, rl.GetScreenWidth()/2 - 100, screenUpperLimit + 10, 20, rl.BLACK)
	end

	-- Draw help instructions
	rl.DrawText("Press SPACE to PAUSE/RESUME", 20, screenHeight - 35, 20, rl.LIGHTGRAY)

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
