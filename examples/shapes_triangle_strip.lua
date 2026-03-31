-- raylib [shapes] example - triangle strip

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - triangle strip")

local points = {}
for i = 1, 122 do points[i] = rl.new("Vector2", 0, 0) end

local center = rl.new("Vector2", (screenWidth / 2.0) - 125.0, screenHeight / 2.0)
local segments = 6.0
local insideRadius = 100.0
local outsideRadius = 150.0
local outline = true

local function SliderBar(bx, by, bw, bh, label, value, minVal, maxVal)
	local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
	if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
		value = minVal + (maxVal - minVal) * (mx - bx) / bw
	end
	value = math.max(minVal, math.min(maxVal, value))
	rl.DrawRectangle(bx, by, bw, bh, rl.LIGHTGRAY)
	local fillW = (value - minVal) / (maxVal - minVal) * bw
	rl.DrawRectangle(bx, by, fillW, bh, rl.SKYBLUE)
	rl.DrawRectangleLines(bx, by, bw, bh, rl.DARKGRAY)
	rl.DrawText(string.format("%s: %.0f", label, value), bx, by - 16, 10, rl.DARKGRAY)
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
	local pointCount = math.floor(segments)
	local angleStep = (360.0 / pointCount) * rl.DEG2RAD

	for i = 0, pointCount - 1 do
		local angle1 = i * angleStep
		points[i * 2 + 1] = rl.new("Vector2",
			center.x + math.cos(angle1) * insideRadius,
			center.y + math.sin(angle1) * insideRadius)
		local angle2 = angle1 + angleStep / 2.0
		points[i * 2 + 2] = rl.new("Vector2",
			center.x + math.cos(angle2) * outsideRadius,
			center.y + math.sin(angle2) * outsideRadius)
	end

	points[pointCount * 2 + 1] = points[1]
	points[pointCount * 2 + 2] = points[2]

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		for i = 0, pointCount - 1 do
			local a = points[i * 2 + 1]
			local b = points[i * 2 + 2]
			local c = points[i * 2 + 3]
			local d = points[i * 2 + 4]

			local angle1 = i * angleStep
			rl.DrawTriangle(c, b, a, rl.ColorFromHSV(angle1 * rl.RAD2DEG, 1.0, 1.0))
			rl.DrawTriangle(d, b, c, rl.ColorFromHSV((angle1 + angleStep / 2) * rl.RAD2DEG, 1.0, 1.0))

			if outline then
				rl.DrawTriangleLines(a, b, c, rl.BLACK)
				rl.DrawTriangleLines(c, b, d, rl.BLACK)
			end
		end

		rl.DrawLine(580, 0, 580, rl.GetScreenHeight(), rl.new("Color", 218, 218, 218, 255))
		rl.DrawRectangle(580, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.new("Color", 232, 232, 232, 255))

		segments = SliderBar(640, 40, 120, 20, "Segments", segments, 6.0, 60.0)
		outline = CheckBox(640, 70, 20, "Outline", outline)

		rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
