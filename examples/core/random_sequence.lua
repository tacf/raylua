--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_random_sequence.c

]]

-- raylib [core] example - random sequence

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - random sequence")

local rectCount = 20
local rectSize = screenWidth / rectCount

local function GenerateRandomColor()
	return rl.new("Color",
		rl.GetRandomValue(0, 255),
		rl.GetRandomValue(0, 255),
		rl.GetRandomValue(0, 255),
		255)
end

local function GenerateRandomColorRectSequence(count, width, scrWidth, scrHeight)
	local rectangles = {}
	local seq = rl.LoadRandomSequence(count, 0, count - 1)
	local rectSeqWidth = count * width
	local startX = (scrWidth - rectSeqWidth) * 0.5

	for i = 0, count - 1 do
		local rectHeight = math.floor(rl.Remap(seq[i], 0, count - 1, 0, scrHeight))
		rectangles[i] = {
			color = GenerateRandomColor(),
			rect = rl.new("Rectangle", startX + i * width, scrHeight - rectHeight, width, rectHeight),
		}
	end

	rl.UnloadRandomSequence(seq)
	return rectangles
end

local function ShuffleColorRectSequence(rectangles, count)
	local seq = rl.LoadRandomSequence(count, 0, count - 1)

	for i1 = 0, count - 1 do
		local r1 = rectangles[i1]
		local r2 = rectangles[seq[i1]]

		-- Swap only the color and height
		local tmpColor = r1.color
		local tmpHeight = r1.rect.height
		local tmpY = r1.rect.y

		r1.color = r2.color
		r1.rect = rl.new("Rectangle", r1.rect.x, r2.rect.y, r1.rect.width, r2.rect.height)

		r2.color = tmpColor
		r2.rect = rl.new("Rectangle", r2.rect.x, tmpY, r2.rect.width, tmpHeight)
	end

	rl.UnloadRandomSequence(seq)
end

local rectangles = GenerateRandomColorRectSequence(rectCount, rectSize, screenWidth, 0.75 * screenHeight)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyPressed(rl.KEY_SPACE) then
		ShuffleColorRectSequence(rectangles, rectCount)
	end

	if rl.IsKeyPressed(rl.KEY_UP) then
		rectCount = rectCount + 1
		rectSize = screenWidth / rectCount
		rectangles = GenerateRandomColorRectSequence(rectCount, rectSize, screenWidth, 0.75 * screenHeight)
	end

	if rl.IsKeyPressed(rl.KEY_DOWN) then
		if rectCount >= 4 then
			rectCount = rectCount - 1
			rectSize = screenWidth / rectCount
			rectangles = GenerateRandomColorRectSequence(rectCount, rectSize, screenWidth, 0.75 * screenHeight)
		end
	end

	-- Draw
	rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		for i = 0, rectCount - 1 do
			rl.DrawRectangleRec(rectangles[i].rect, rectangles[i].color)
		end

		rl.DrawText("Press SPACE to shuffle the current sequence", 10, screenHeight - 96, 20, rl.BLACK)
		rl.DrawText("Press UP to add a rectangle and generate a new sequence", 10, screenHeight - 64, 20, rl.BLACK)
		rl.DrawText("Press DOWN to remove a rectangle and generate a new sequence", 10, screenHeight - 32, 20, rl.BLACK)

		rl.DrawText(string.format("Count: %d rectangles", rectCount), 10, 10, 20, rl.MAROON)

		rl.DrawFPS(screenWidth - 80, 10)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
