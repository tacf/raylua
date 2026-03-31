-- raylib [shapes] example - math sine cosine

local WAVE_POINTS = 36

local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - math sine cosine")

local sinePoints = {}
local cosPoints = {}
local center = rl.new("Vector2", (screenWidth / 2.0) - 30.0, screenHeight / 2.0)
local start = rl.new("Rectangle", 20.0, screenHeight - 120.0, 200.0, 100.0)
local radius = 130.0
local angle = 0.0
local pause = false

for i = 0, WAVE_POINTS - 1 do
	local t = i / (WAVE_POINTS - 1)
	local currentAngle = math.rad(t * 360.0)
	sinePoints[i] = rl.new("Vector2",
		start.x + t * start.width,
		start.y + start.height / 2.0 - math.sin(currentAngle) * (start.height / 2.0))
	cosPoints[i] = rl.new("Vector2",
		start.x + t * start.width,
		start.y + start.height / 2.0 - math.cos(currentAngle) * (start.height / 2.0))
end

local function SliderBar(bx, by, bw, bh, label, value, minVal, maxVal)
	local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
	if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
		value = minVal + (maxVal - minVal) * (mx - bx) / bw
	end
	value = math.max(minVal, math.min(maxVal, value))
	rl.DrawRectangle(bx, by, bw, bh, rl.LIGHTGRAY)
	local fillW = (value - minVal) / (maxVal - minVal) * bw
	rl.DrawRectangle(bx, by, fillW, bh, rl.LIME)
	rl.DrawRectangleLines(bx, by, bw, bh, rl.DARKGRAY)
	rl.DrawText(string.format("%s: %.0f", label, value), bx, by - 16, 10, rl.GRAY)
	return value
end

local function Toggle(bx, by, bw, bh, label, active)
	local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
		active = not active
	end
	rl.DrawRectangle(bx, by, bw, bh, active and rl.LIME or rl.LIGHTGRAY)
	rl.DrawRectangleLines(bx, by, bw, bh, rl.DARKGRAY)
	rl.DrawText(label, bx + 4, by + 4, 10, rl.DARKGRAY)
	return active
end

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	local angleRad = math.rad(angle)
	local cosRad = math.cos(angleRad)
	local sinRad = math.sin(angleRad)

	local point = rl.new("Vector2", center.x + cosRad * radius, center.y - sinRad * radius)
	local limitMin = rl.new("Vector2", center.x - radius, center.y - radius)
	local limitMax = rl.new("Vector2", center.x + radius, center.y + radius)

	local complementary = 90.0 - angle
	local supplementary = 180.0 - angle
	local explementary = 360.0 - angle

	local tanVal = rl.Clamp(math.tan(angleRad), -10.0, 10.0)
	local cotangent = (math.abs(tanVal) > 0.001) and rl.Clamp(1.0 / tanVal, -radius, radius) or 0.0
	local tangentPoint = rl.new("Vector2", center.x + radius, center.y - tanVal * radius)
	local cotangentPoint = rl.new("Vector2", center.x + cotangent * radius, center.y - radius)

	if not pause then angle = rl.Wrap(angle + 1.0, 0.0, 360.0) end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		-- Cotangent (orange)
		rl.DrawLineEx(rl.new("Vector2", center.x, limitMin.y), rl.new("Vector2", cotangentPoint.x, limitMin.y), 2.0, rl.ORANGE)
		rl.DrawLineDashed(center, cotangentPoint, 10, 4, rl.ORANGE)

		-- Side background
		rl.DrawLine(580, 0, 580, rl.GetScreenHeight(), rl.new("Color", 218, 218, 218, 255))
		rl.DrawRectangle(580, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.new("Color", 232, 232, 232, 255))

		-- Base circle and axes
		rl.DrawCircleLinesV(center, radius, rl.GRAY)
		rl.DrawLineEx(rl.new("Vector2", center.x, limitMin.y), rl.new("Vector2", center.x, limitMax.y), 1.0, rl.GRAY)
		rl.DrawLineEx(rl.new("Vector2", limitMin.x, center.y), rl.new("Vector2", limitMax.x, center.y), 1.0, rl.GRAY)

		-- Wave graph axes
		rl.DrawLineEx(rl.new("Vector2", start.x, start.y), rl.new("Vector2", start.x, start.y + start.height), 2.0, rl.GRAY)
		rl.DrawLineEx(rl.new("Vector2", start.x + start.width, start.y), rl.new("Vector2", start.x + start.width, start.y + start.height), 2.0, rl.GRAY)
		rl.DrawLineEx(rl.new("Vector2", start.x, start.y + start.height / 2), rl.new("Vector2", start.x + start.width, start.y + start.height / 2), 2.0, rl.GRAY)

		-- Wave graph axis labels
		rl.DrawText("1", math.floor(start.x) - 8, math.floor(start.y), 6, rl.GRAY)
		rl.DrawText("0", math.floor(start.x) - 8, math.floor(start.y) + math.floor(start.height / 2) - 6, 6, rl.GRAY)
		rl.DrawText("-1", math.floor(start.x) - 12, math.floor(start.y) + math.floor(start.height) - 8, 6, rl.GRAY)
		rl.DrawText("0", math.floor(start.x) - 2, math.floor(start.y) + math.floor(start.height) + 4, 6, rl.GRAY)
		rl.DrawText("360", math.floor(start.x) + math.floor(start.width) - 8, math.floor(start.y) + math.floor(start.height) + 4, 6, rl.GRAY)

		-- Sine (red - vertical)
		rl.DrawLineEx(rl.new("Vector2", center.x, center.y), rl.new("Vector2", center.x, point.y), 2.0, rl.RED)
		rl.DrawLineDashed(rl.new("Vector2", point.x, center.y), rl.new("Vector2", point.x, point.y), 10, 4, rl.RED)
		rl.DrawText(string.format("Sine %.2f", sinRad), 640, 190, 6, rl.RED)
		rl.DrawCircleV(rl.new("Vector2", start.x + (angle / 360.0) * start.width, start.y + ((-sinRad + 1) * start.height / 2.0)), 4.0, rl.RED)
		rl.DrawSplineLinear(sinePoints, WAVE_POINTS, 1.0, rl.RED)

		-- Cosine (blue - horizontal)
		rl.DrawLineEx(rl.new("Vector2", center.x, center.y), rl.new("Vector2", point.x, center.y), 2.0, rl.BLUE)
		rl.DrawLineDashed(rl.new("Vector2", center.x, point.y), rl.new("Vector2", point.x, point.y), 10, 4, rl.BLUE)
		rl.DrawText(string.format("Cosine %.2f", cosRad), 640, 210, 6, rl.BLUE)
		rl.DrawCircleV(rl.new("Vector2", start.x + (angle / 360.0) * start.width, start.y + ((-cosRad + 1) * start.height / 2.0)), 4.0, rl.BLUE)
		rl.DrawSplineLinear(cosPoints, WAVE_POINTS, 1.0, rl.BLUE)

		-- Tangent (purple)
		rl.DrawLineEx(rl.new("Vector2", limitMax.x, center.y), rl.new("Vector2", limitMax.x, tangentPoint.y), 2.0, rl.PURPLE)
		rl.DrawLineDashed(center, tangentPoint, 10, 4, rl.PURPLE)
		rl.DrawText(string.format("Tangent %.2f", tanVal), 640, 230, 6, rl.PURPLE)

		-- Cotangent (orange)
		rl.DrawText(string.format("Cotangent %.2f", cotangent), 640, 250, 6, rl.ORANGE)

		-- Complementary angle (beige)
		rl.DrawCircleSectorLines(center, radius * 0.6, -angle, -90.0, 36, rl.BEIGE)
		rl.DrawText(string.format("Complementary  %.0f°", complementary), 640, 150, 6, rl.BEIGE)

		-- Supplementary angle (darkblue)
		rl.DrawCircleSectorLines(center, radius * 0.5, -angle, -180.0, 36, rl.DARKBLUE)
		rl.DrawText(string.format("Supplementary  %.0f°", supplementary), 640, 130, 6, rl.DARKBLUE)

		-- Explementary angle (pink)
		rl.DrawCircleSectorLines(center, radius * 0.4, -angle, -360.0, 36, rl.PINK)
		rl.DrawText(string.format("Explementary  %.0f°", explementary), 640, 170, 6, rl.PINK)

		-- Current angle - arc (lime), radius (black), endpoint (black)
		rl.DrawCircleSectorLines(center, radius * 0.7, -angle, 0.0, 36, rl.LIME)
		rl.DrawLineEx(rl.new("Vector2", center.x, center.y), point, 2.0, rl.BLACK)
		rl.DrawCircleV(point, 4.0, rl.BLACK)

		-- GUI controls
		angle = SliderBar(640, 40, 120, 20, "Angle", angle, 0.0, 360.0)
		pause = Toggle(640, 70, 120, 20, "Pause", pause)

		-- Angle values panel
		rl.DrawRectangleLines(620, 110, 140, 170, rl.GRAY)
		rl.DrawText("Angle Values", 630, 108, 10, rl.DARKGRAY)

		rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
