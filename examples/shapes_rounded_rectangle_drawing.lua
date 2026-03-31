-- raylib [shapes] example - rounded rectangle drawing

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - rounded rectangle drawing")

local roundness = 0.2
local width = 200.0
local height = 100.0
local segments = 0.0
local lineThick = 1.0

local drawRect = false
local drawRoundedRect = true
local drawRoundedLines = false

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	local rec = rl.new("Rectangle", (rl.GetScreenWidth() - width - 250) / 2, (rl.GetScreenHeight() - height) / 2.0, width, height)

	-- Sliders
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

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawLine(560, 0, 560, rl.GetScreenHeight(), rl.Fade(rl.LIGHTGRAY, 0.6))
		rl.DrawRectangle(560, 0, rl.GetScreenWidth() - 500, rl.GetScreenHeight(), rl.Fade(rl.LIGHTGRAY, 0.3))

		if drawRect then rl.DrawRectangleRec(rec, rl.Fade(rl.GOLD, 0.6)) end
		if drawRoundedRect then rl.DrawRectangleRounded(rec, roundness, math.floor(segments), rl.Fade(rl.MAROON, 0.2)) end
		if drawRoundedLines then rl.DrawRectangleRoundedLinesEx(rec, roundness, math.floor(segments), lineThick, rl.Fade(rl.MAROON, 0.4)) end

		width = SliderBar(640, 40, 105, 20, "Width", width, 0, rl.GetScreenWidth() - 300)
		height = SliderBar(640, 70, 105, 20, "Height", height, 0, rl.GetScreenHeight() - 50)
		roundness = SliderBar(640, 140, 105, 20, "Roundness", roundness, 0.0, 1.0)
		lineThick = SliderBar(640, 170, 105, 20, "Thickness", lineThick, 0, 20)
		segments = SliderBar(640, 240, 105, 20, "Segments", segments, 0, 60)

		drawRoundedRect = CheckBox(640, 320, 20, "DrawRoundedRect", drawRoundedRect)
		drawRoundedLines = CheckBox(640, 350, 20, "DrawRoundedLines", drawRoundedLines)
		drawRect = CheckBox(640, 380, 20, "DrawRect", drawRect)

		if segments >= 4 then
			rl.DrawText("MODE: MANUAL", 640, 280, 10, rl.MAROON)
		else
			rl.DrawText("MODE: AUTO", 640, 280, 10, rl.DARKGRAY)
		end

		rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.CloseWindow()
