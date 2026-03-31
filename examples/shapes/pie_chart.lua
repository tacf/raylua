--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_pie_chart.c

]]

-- raylib [shapes] example - pie chart

local MAX_PIE_SLICES = 10

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - pie chart")

local sliceCount = 7
local donutInnerRadius = 25.0
local values = { 300.0, 100.0, 450.0, 350.0, 600.0, 380.0, 750.0, 0.0, 0.0, 0.0 }
local labels = {}
for i = 1, MAX_PIE_SLICES do
	labels[i] = string.format("Slice %02d", i)
end

local showValues = true
local showPercentages = false
local showDonut = false
local hoveredSlice = -1

local panelWidth = 270
local panelMargin = 5
local panelPos = rl.new("Vector2", screenWidth - panelMargin - panelWidth, panelMargin)
local panelRect = rl.new("Rectangle", panelPos.x, panelPos.y, panelWidth, screenHeight - 2 * panelMargin)

local canvas = rl.new("Rectangle", 0, 0, panelPos.x, screenHeight)
local center = rl.new("Vector2", canvas.width / 2.0, canvas.height / 2.0)
local radius = 205.0

local totalValue = 0.0

local function SliderBar(bx, by, bw, bh, value, minVal, maxVal)
	local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
	if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
		value = minVal + (maxVal - minVal) * (mx - bx) / bw
	end
	value = math.max(minVal, math.min(maxVal, value))
	rl.DrawRectangle(bx, by, bw, bh, rl.LIGHTGRAY)
	local fillW = (value - minVal) / (maxVal - minVal) * bw
	rl.DrawRectangle(bx, by, fillW, bh, rl.SKYBLUE)
	rl.DrawRectangleLines(bx, by, bw, bh, rl.DARKGRAY)
	return value
end

local function CheckBox(bx, by, size, label, checked)
	rl.DrawRectangle(bx, by, size, size, checked and rl.SKYBLUE or rl.LIGHTGRAY)
	rl.DrawRectangleLines(bx, by, size, size, rl.DARKGRAY)
	rl.DrawText(label, bx + size + 4, by + 2, 10, rl.DARKGRAY)
	local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + size and my >= by and my <= by + size then
		return not checked
	end
	return checked
end

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	totalValue = 0.0
	for i = 1, sliceCount do totalValue = totalValue + values[i] end

	hoveredSlice = -1
	local mousePos = rl.GetMousePosition()
	if rl.CheckCollisionPointRec(mousePos, canvas) then
		local dx = mousePos.x - center.x
		local dy = mousePos.y - center.y
		local distance = math.sqrt(dx * dx + dy * dy)

		if distance <= radius then
			local a = math.atan(dy, dx) * rl.RAD2DEG
			if a < 0 then a = a + 360 end

			local currentAngle = 0.0
			for i = 1, sliceCount do
				local sweep = (totalValue > 0) and (values[i] / totalValue) * 360.0 or 0.0
				if a >= currentAngle and a < currentAngle + sweep then
					hoveredSlice = i - 1
					break
				end
				currentAngle = currentAngle + sweep
			end
		end
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		local startAngle = 0.0
		for i = 1, sliceCount do
			local sweepAngle = (totalValue > 0) and (values[i] / totalValue) * 360.0 or 0.0
			local midAngle = startAngle + sweepAngle / 2.0

			local color = rl.ColorFromHSV((i - 1) / sliceCount * 360.0, 0.75, 0.9)
			local currentRadius = radius
			if (i - 1) == hoveredSlice then currentRadius = currentRadius + 20.0 end

			rl.DrawCircleSector(center, currentRadius, startAngle, startAngle + sweepAngle, 120, color)

			if values[i] > 0 then
				local labelText
				if showValues and showPercentages then
					labelText = string.format("%.1f (%.0f%%)", values[i], (values[i] / totalValue) * 100.0)
				elseif showValues then
					labelText = string.format("%.1f", values[i])
				elseif showPercentages then
					labelText = string.format("%.0f%%", (values[i] / totalValue) * 100.0)
				else
					labelText = ""
				end

				if #labelText > 0 then
					local textSize = rl.MeasureTextEx(rl.GetFontDefault(), labelText, 20, 1)
					local labelR = radius * 0.7
					local labelPos = rl.new("Vector2",
						center.x + math.cos(math.rad(midAngle)) * labelR - textSize.x / 2.0,
						center.y + math.sin(math.rad(midAngle)) * labelR - textSize.y / 2.0)
					rl.DrawText(labelText, math.floor(labelPos.x), math.floor(labelPos.y), 20, rl.WHITE)
				end
			end

			if showDonut then rl.DrawCircleV(center, donutInnerRadius, rl.RAYWHITE) end

			startAngle = startAngle + sweepAngle
		end

		-- UI control panel
		rl.DrawRectangleRec(panelRect, rl.Fade(rl.LIGHTGRAY, 0.5))
		rl.DrawRectangleLinesEx(panelRect, 1.0, rl.GRAY)

		rl.DrawText(string.format("Slices: %d", sliceCount), panelPos.x + 10, panelPos.y + 15, 10, rl.DARKGRAY)
		sliceCount = math.floor(SliderBar(panelPos.x + 95, panelPos.y + 12, 125, 25, sliceCount, 1, MAX_PIE_SLICES) + 0.5)

		showValues = CheckBox(panelPos.x + 20, panelPos.y + 12 + 40, 20, "Show Values", showValues)
		showPercentages = CheckBox(panelPos.x + 20, panelPos.y + 12 + 70, 20, "Show Percentages", showPercentages)
		showDonut = CheckBox(panelPos.x + 20, panelPos.y + 12 + 100, 20, "Make Donut", showDonut)

		if not showDonut then
			rl.DrawText("Inner Radius", panelPos.x + 10, panelPos.y + 12 + 130, 10, rl.DARKGRAY)
			donutInnerRadius = SliderBar(panelPos.x + 80, panelPos.y + 12 + 145, panelRect.width - 100, 15, donutInnerRadius, 5.0, radius - 10.0)
		end

		-- Separator line
		rl.DrawLine(panelPos.x + 10, panelPos.y + 175, panelPos.x + panelRect.width - 10, panelPos.y + 175, rl.GRAY)

		-- Slice value editors
		for i = 1, sliceCount do
			local rowY = panelPos.y + 190 + (i - 1) * 35
			local color = rl.ColorFromHSV((i - 1) / sliceCount * 360.0, 0.75, 0.9)
			rl.DrawRectangle(panelPos.x + 15, rowY + 5, 20, 20, color)
			rl.DrawText(labels[i], panelPos.x + 45, rowY + 5, 10, rl.DARKGRAY)
			values[i] = SliderBar(panelPos.x + 130, rowY, 110, 30, values[i], 0.0, 1000.0)
			rl.DrawText(string.format("%.0f", values[i]), panelPos.x + 130, rowY + 10, 8, rl.DARKGRAY)
		end

		rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
