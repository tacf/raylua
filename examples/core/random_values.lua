--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_random_values.c

]]

-- raylib [core] example - random values

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - random values")

-- rl.SetRandomSeed(0xaabbccff)   -- Set a custom random seed if desired, by default: "time(NULL)"

local randValue = rl.GetRandomValue(-8, 5)

local framesCounter = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	framesCounter = framesCounter + 1

	-- Every two seconds (120 frames) a new random value is generated
	if math.floor(framesCounter / 120) % 2 == 1 then
		randValue = rl.GetRandomValue(-8, 5)
		framesCounter = 0
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawText("Every 2 seconds a new random value is generated:", 130, 100, 20, rl.MAROON)

	rl.DrawText(string.format("%i", randValue), 360, 180, 80, rl.LIGHTGRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
