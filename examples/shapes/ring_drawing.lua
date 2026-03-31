--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_ring_drawing.c

]]

-- raylib [shapes] example - ring drawing

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - ring drawing")

local center = rl.new("Vector2", (rl.GetScreenWidth() - 300) / 2.0, rl.GetScreenHeight() / 2.0)

local innerRadius = 80.0
local outerRadius = 190.0

local startAngle = 0.0
local endAngle = 360.0
local segments = 0.0

local drawRing = true
local drawRingLines = false
local drawCircleLines = false

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawLine(500, 0, 500, rl.GetScreenHeight(), rl.Fade(rl.LIGHTGRAY, 0.6))
		rl.DrawRectangle(500, 0, rl.GetScreenWidth() - 500, rl.GetScreenHeight(), rl.Fade(rl.LIGHTGRAY, 0.3))

		if drawRing then rl.DrawRing(center, innerRadius, outerRadius, startAngle, endAngle, math.floor(segments), rl.Fade(rl.MAROON, 0.3)) end
		if drawRingLines then rl.DrawRingLines(center, innerRadius, outerRadius, startAngle, endAngle, math.floor(segments), rl.Fade(rl.BLACK, 0.4)) end
		if drawCircleLines then rl.DrawCircleSectorLines(center, outerRadius, startAngle, endAngle, math.floor(segments), rl.Fade(rl.BLACK, 0.4)) end

		-- Manual sliders since raygui isn't available in binding
		local function SliderBar(bx, by, bw, bh, label, value, minVal, maxVal)
			local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
			if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
				value = minVal + (maxVal - minVal) * (mx - bx) / bw
			end
			value = math.max(minVal, math.min(maxVal, value))
			rl.DrawRectangle(bx, by, bw, bh, rl.LIGHTGRAY)
			local fillW = (value - minVal) / (maxVal - minVal) * bw
			rl.DrawRectangle(bx, by, fillW, bh, rl.MAROON)
			rl.DrawRectangleLines(bx, by, bw, bh, rl.DARKGRAY)
			rl.DrawText(string.format("%s: %.2f", label, value), bx, by - 16, 10, rl.DARKGRAY)
			return value
		end

		startAngle = SliderBar(600, 40, 120, 20, "StartAngle", startAngle, -450, 450)
		endAngle = SliderBar(600, 70, 120, 20, "EndAngle", endAngle, -450, 450)
		innerRadius = SliderBar(600, 140, 120, 20, "InnerRadius", innerRadius, 0, 100)
		outerRadius = SliderBar(600, 170, 120, 20, "OuterRadius", outerRadius, 0, 200)
		segments = SliderBar(600, 240, 120, 20, "Segments", segments, 0, 100)

		-- Checkboxes
		local function CheckBox(bx, by, size, label, checked)
			rl.DrawRectangle(bx, by, size, size, checked and rl.MAROON or rl.LIGHTGRAY)
			rl.DrawRectangleLines(bx, by, size, size, rl.DARKGRAY)
			rl.DrawText(label, bx + size + 4, by + 2, 10, rl.DARKGRAY)
			local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
			if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + size and my >= by and my <= by + size then
				return not checked
			end
			return checked
		end

		drawRing = CheckBox(600, 320, 20, "Draw Ring", drawRing)
		drawRingLines = CheckBox(600, 350, 20, "Draw RingLines", drawRingLines)
		drawCircleLines = CheckBox(600, 380, 20, "Draw CircleLines", drawCircleLines)

		local minSegments = math.ceil((endAngle - startAngle) / 90)
		if segments >= minSegments then
			rl.DrawText("MODE: MANUAL", 600, 270, 10, rl.MAROON)
		else
			rl.DrawText("MODE: AUTO", 600, 270, 10, rl.DARKGRAY)
		end

		rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.CloseWindow()
