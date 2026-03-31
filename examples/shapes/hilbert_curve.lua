--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_hilbert_curve.c

]]

--[[
    raylib [shapes] example - hilbert curve

    Example complexity rating: [★★★☆] 3/4

    Example originally created with raylib 5.6, last time updated with raylib 5.6

    Example contributed by Hamza RAHAL (@hmz-rhl) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2025 Hamza RAHAL (@hmz-rhl)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - hilbert curve")

-- Hilbert points base pattern
local hilbertBase = {
	rl.new("Vector2", 0, 0),
	rl.new("Vector2", 0, 1),
	rl.new("Vector2", 1, 1),
	rl.new("Vector2", 1, 0),
}

-- Compute Hilbert path U positions
local function ComputeHilbertStep(order, index)
	local hilbertIndex = bit.band(index, 3)
	local vect = rl.new("Vector2", hilbertBase[hilbertIndex + 1].x, hilbertBase[hilbertIndex + 1].y)
	local temp = 0.0
	local len = 0

	for j = 1, order - 1 do
		index = bit.rshift(index, 2)
		hilbertIndex = bit.band(index, 3)
		len = bit.lshift(1, j)

		if hilbertIndex == 0 then
			temp = vect.x
			vect = rl.new("Vector2", vect.y, temp)
		elseif hilbertIndex == 1 then
			vect = rl.new("Vector2", vect.x, vect.y + len)
		elseif hilbertIndex == 2 then
			vect = rl.new("Vector2", vect.x + len, vect.y + len)
		elseif hilbertIndex == 3 then
			temp = len - 1 - vect.x
			vect = rl.new("Vector2", 2*len - 1 - vect.y, temp)
		end
	end

	return vect
end

-- Load the whole Hilbert Path
local function LoadHilbertPath(order, size)
	local N = bit.lshift(1, order)
	local len = size / N
	local strokeCount = N * N

	local hilbertPath = {}
	for i = 0, strokeCount - 1 do
		hilbertPath[i] = ComputeHilbertStep(order, i)
		hilbertPath[i] = rl.new("Vector2",
			hilbertPath[i].x * len + len / 2.0,
			hilbertPath[i].y * len + len / 2.0
		)
	end

	return hilbertPath, strokeCount
end

local order = 2
local size = rl.GetScreenHeight()
local hilbertPath, strokeCount = LoadHilbertPath(order, size)

local prevOrder = order
local prevSize = math.floor(size)
local counter = 0
local thick = 2.0
local animate = true

-- Manual spinner control
local function GuiSpinner(bx, by, bw, bh, label, value, minVal, maxVal)
	local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
	local arrowW = 20

	-- Draw label and value
	rl.DrawText(string.format("%s%d", label, value), bx, by - 16, 10, rl.DARKGRAY)
	rl.DrawRectangle(bx, by, bw - 2*arrowW, bh, rl.LIGHTGRAY)
	rl.DrawRectangleLines(bx, by, bw - 2*arrowW, bh, rl.DARKGRAY)

	-- Minus button
	rl.DrawRectangle(bx + bw - 2*arrowW, by, arrowW, bh, rl.MAROON)
	rl.DrawText("-", bx + bw - 2*arrowW + 6, by + 4, 14, rl.WHITE)
	-- Plus button
	rl.DrawRectangle(bx + bw - arrowW, by, arrowW, bh, rl.MAROON)
	rl.DrawText("+", bx + bw - arrowW + 6, by + 4, 14, rl.WHITE)

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then
		if mx >= bx + bw - 2*arrowW and mx <= bx + bw - arrowW and my >= by and my <= by + bh then
			value = math.max(minVal, value - 1)
		elseif mx >= bx + bw - arrowW and mx <= bx + bw and my >= by and my <= by + bh then
			value = math.min(maxVal, value + 1)
		end
	end
	return value
end

-- Manual slider control
local function GuiSlider(bx, by, bw, bh, label, value, minVal, maxVal)
	local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
	if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
		value = minVal + (maxVal - minVal) * (mx - bx) / bw
	end
	value = math.max(minVal, math.min(maxVal, value))
	rl.DrawRectangle(bx, by, bw, bh, rl.LIGHTGRAY)
	local fillW = (value - minVal) / (maxVal - minVal) * bw
	rl.DrawRectangle(bx, by, fillW, bh, rl.MAROON)
	rl.DrawRectangleLines(bx, by, bw, bh, rl.DARKGRAY)
	rl.DrawText(string.format("%s %.2f", label, value), bx, by - 16, 10, rl.DARKGRAY)
	return value
end

-- Manual checkbox control
local function GuiCheckBox(bx, by, size, label, checked)
	rl.DrawRectangle(bx, by, size, size, checked and rl.MAROON or rl.LIGHTGRAY)
	rl.DrawRectangleLines(bx, by, size, size, rl.DARKGRAY)
	rl.DrawText(label, bx + size + 4, by + 2, 10, rl.DARKGRAY)
	local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + size and my >= by and my <= by + size then
		return not checked
	end
	return checked
end

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- Check if order or size have changed to regenerate
	if (prevOrder ~= order) or (prevSize ~= math.floor(size)) then
		hilbertPath, strokeCount = LoadHilbertPath(order, size)

		if animate then counter = 0
		else counter = strokeCount end

		prevOrder = order
		prevSize = math.floor(size)
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	if counter < strokeCount then
		-- Draw Hilbert path animation, one stroke every frame
		for i = 1, counter do
			rl.DrawLineEx(hilbertPath[i], hilbertPath[i - 1], thick,
				rl.ColorFromHSV((i / strokeCount) * 360.0, 1.0, 1.0))
		end
		counter = counter + 1
	else
		-- Draw full Hilbert path
		for i = 1, strokeCount - 1 do
			rl.DrawLineEx(hilbertPath[i], hilbertPath[i - 1], thick,
				rl.ColorFromHSV((i / strokeCount) * 360.0, 1.0, 1.0))
		end
	end

	-- Draw UI
	animate = GuiCheckBox(450, 50, 20, "ANIMATE GENERATION ON CHANGE", animate)
	order = GuiSpinner(585, 100, 180, 30, "HILBERT CURVE ORDER:  ", order, 2, 8)
	thick = GuiSlider(524, 150, 240, 24, "THICKNESS:  ", thick, 1.0, 10.0)
	size = GuiSlider(524, 190, 240, 24, "TOTAL SIZE: ", size, 10.0, rl.GetScreenHeight() * 1.5)

	rl.EndDrawing()
end

rl.CloseWindow()
