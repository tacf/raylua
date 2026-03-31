--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_kaleidoscope.c

]]

--[[
    raylib [shapes] example - kaleidoscope

    Example complexity rating: [★★☆☆] 2/4

    Example originally created with raylib 5.5, last time updated with raylib 5.6

    Example contributed by Hugo ARNAL (@hugoarnal) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2025 Hugo ARNAL (@hugoarnal) and Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - kaleidoscope")

local MAX_DRAW_LINES = 8192

-- Line drawing properties
local symmetry = 6
local angle = 360.0 / symmetry
local thickness = 3.0

local resetButtonRec = rl.new("Rectangle", screenWidth - 55.0, 5.0, 50, 25)
local backButtonRec = rl.new("Rectangle", screenWidth - 55.0, screenHeight - 30.0, 25, 25)
local nextButtonRec = rl.new("Rectangle", screenWidth - 30.0, screenHeight - 30.0, 25, 25)

local mousePos = rl.new("Vector2", 0, 0)
local prevMousePos = rl.new("Vector2", 0, 0)
local scaleVector = rl.new("Vector2", 1.0, -1.0)
local offset = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0)

local camera = rl.new("Camera2D", {
	target = rl.new("Vector2", 0, 0),
	offset = offset,
	rotation = 0.0,
	zoom = 1.0,
})

-- Lines storage (each entry has start and end)
local lineStarts = {}
local lineEnds = {}
for i = 0, MAX_DRAW_LINES - 1 do
	lineStarts[i] = rl.new("Vector2", 0, 0)
	lineEnds[i] = rl.new("Vector2", 0, 0)
end

local currentLineCounter = 0
local totalLineCounter = 0

-- Helper: rotate a Vector2 by angle (in radians)
local function Vector2Rotate(v, radAngle)
	local cosA = math.cos(radAngle)
	local sinA = math.sin(radAngle)
	return rl.new("Vector2", v.x * cosA - v.y * sinA, v.x * sinA + v.y * cosA)
end

rl.SetTargetFPS(20)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	prevMousePos = mousePos
	mousePos = rl.GetMousePosition()

	local lineStart = rl.new("Vector2", mousePos.x - offset.x, mousePos.y - offset.y)
	local lineEnd = rl.new("Vector2", prevMousePos.x - offset.x, prevMousePos.y - offset.y)

	if rl.IsMouseButtonDown(rl.MOUSE_LEFT_BUTTON)
		and not rl.CheckCollisionPointRec(mousePos, resetButtonRec)
		and not rl.CheckCollisionPointRec(mousePos, backButtonRec)
		and not rl.CheckCollisionPointRec(mousePos, nextButtonRec) then

		for s = 0, symmetry - 1 do
			if totalLineCounter >= MAX_DRAW_LINES - 1 then break end

			lineStart = Vector2Rotate(lineStart, math.rad(angle))
			lineEnd = Vector2Rotate(lineEnd, math.rad(angle))

			-- Store mouse line
			lineStarts[totalLineCounter] = rl.new("Vector2", lineStart.x, lineStart.y)
			lineEnds[totalLineCounter] = rl.new("Vector2", lineEnd.x, lineEnd.y)

			-- Store reflective line
			lineStarts[totalLineCounter + 1] = rl.new("Vector2", lineStart.x * scaleVector.x, lineStart.y * scaleVector.y)
			lineEnds[totalLineCounter + 1] = rl.new("Vector2", lineEnd.x * scaleVector.x, lineEnd.y * scaleVector.y)

			totalLineCounter = totalLineCounter + 2
			currentLineCounter = totalLineCounter
		end
	end

	local resetButtonClicked = false
	local backButtonClicked = false
	local nextButtonClicked = false

	local mx, my = mousePos.x, mousePos.y
	-- Reset button
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then
		if mx >= resetButtonRec.x and mx <= resetButtonRec.x + resetButtonRec.width
			and my >= resetButtonRec.y and my <= resetButtonRec.y + resetButtonRec.height then
			resetButtonClicked = true
		end
		if mx >= backButtonRec.x and mx <= backButtonRec.x + backButtonRec.width
			and my >= backButtonRec.y and my <= backButtonRec.y + backButtonRec.height then
			backButtonClicked = true
		end
		if mx >= nextButtonRec.x and mx <= nextButtonRec.x + nextButtonRec.width
			and my >= nextButtonRec.y and my <= nextButtonRec.y + nextButtonRec.height then
			nextButtonClicked = true
		end
	end

	if resetButtonClicked then
		for i = 0, MAX_DRAW_LINES - 1 do
			lineStarts[i] = rl.new("Vector2", 0, 0)
			lineEnds[i] = rl.new("Vector2", 0, 0)
		end
		currentLineCounter = 0
		totalLineCounter = 0
	end

	if backButtonClicked and (currentLineCounter > 0) then
		currentLineCounter = currentLineCounter - 1
	end

	if nextButtonClicked and (currentLineCounter < MAX_DRAW_LINES) and ((currentLineCounter + 1) <= totalLineCounter) then
		currentLineCounter = currentLineCounter + 1
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)
	rl.BeginMode2D(camera)

	for s = 0, symmetry - 1 do
		for i = 0, currentLineCounter - 1, 2 do
			rl.DrawLineEx(lineStarts[i], lineEnds[i], thickness, rl.BLACK)
			rl.DrawLineEx(lineStarts[i + 1], lineEnds[i + 1], thickness, rl.BLACK)
		end
	end

	rl.EndMode2D()

	-- Back button
	if currentLineCounter - 1 < 0 then
		-- Disabled state
		rl.DrawRectangle(backButtonRec.x, backButtonRec.y, backButtonRec.width, backButtonRec.height, rl.LIGHTGRAY)
		rl.DrawText("<", backButtonRec.x + 5, backButtonRec.y + 3, 14, rl.GRAY)
	else
		rl.DrawRectangle(backButtonRec.x, backButtonRec.y, backButtonRec.width, backButtonRec.height, rl.MAROON)
		rl.DrawText("<", backButtonRec.x + 5, backButtonRec.y + 3, 14, rl.WHITE)
	end

	-- Next button
	if currentLineCounter + 1 > totalLineCounter then
		rl.DrawRectangle(nextButtonRec.x, nextButtonRec.y, nextButtonRec.width, nextButtonRec.height, rl.LIGHTGRAY)
		rl.DrawText(">", nextButtonRec.x + 5, nextButtonRec.y + 3, 14, rl.GRAY)
	else
		rl.DrawRectangle(nextButtonRec.x, nextButtonRec.y, nextButtonRec.width, nextButtonRec.height, rl.MAROON)
		rl.DrawText(">", nextButtonRec.x + 5, nextButtonRec.y + 3, 14, rl.WHITE)
	end

	-- Reset button
	rl.DrawRectangle(resetButtonRec.x, resetButtonRec.y, resetButtonRec.width, resetButtonRec.height, rl.MAROON)
	rl.DrawText("Reset", resetButtonRec.x + 5, resetButtonRec.y + 5, 12, rl.WHITE)

	rl.DrawText(string.format("LINES: %i/%i", currentLineCounter, MAX_DRAW_LINES), 10, screenHeight - 30, 20, rl.MAROON)
	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
