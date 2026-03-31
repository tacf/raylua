--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_splines_drawing.c

]]

-- raylib [shapes] example - splines drawing

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - splines drawing")

local MAX_SPLINE_POINTS = 32

local points = {
	rl.new("Vector2",  50.0, 400.0),
	rl.new("Vector2", 160.0, 220.0),
	rl.new("Vector2", 340.0, 380.0),
	rl.new("Vector2", 520.0,  60.0),
	rl.new("Vector2", 710.0, 260.0),
}

local pointsInterleaved = {}
for i = 1, 3 * (MAX_SPLINE_POINTS - 1) + 1 do
	pointsInterleaved[i] = rl.new("Vector2", 0, 0)
end

local pointCount = 5
local selectedPoint = -1
local focusedPoint = -1
local selectedControlPoint = nil
local focusedControlPoint = nil

-- Control points: {start, end} pairs
local control = {}
for i = 1, MAX_SPLINE_POINTS - 1 do
	control[i] = {
		start = rl.new("Vector2", 0, 0),
		endp = rl.new("Vector2", 0, 0),
	}
end

for i = 0, pointCount - 2 do
	control[i + 1].start.x = points[i + 1].x + 50
	control[i + 1].start.y = points[i + 1].y
	control[i + 1].endp.x = points[i + 2].x - 50
	control[i + 1].endp.y = points[i + 2].y
end

local SPLINE_LINEAR = 0
local SPLINE_BASIS = 1
local SPLINE_CATMULLROM = 2
local SPLINE_BEZIER = 3

local splineThickness = 8.0
local splineTypeActive = SPLINE_LINEAR
local splineTypeEditMode = false
local splineHelpersActive = true

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	-- Right click to add point
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT) and pointCount < MAX_SPLINE_POINTS then
		points[pointCount + 1] = rl.GetMousePosition()
		local i = pointCount - 1
		control[i + 1].start.x = points[i + 1].x + 50
		control[i + 1].start.y = points[i + 1].y
		control[i + 1].endp.x = points[i + 2].x - 50
		control[i + 1].endp.y = points[i + 2].y
		pointCount = pointCount + 1
	end

	-- Point focus/selection
	if selectedPoint == -1 and (splineTypeActive ~= SPLINE_BEZIER or selectedControlPoint == nil) then
		focusedPoint = -1
		for i = 0, pointCount - 1 do
			if rl.CheckCollisionPointCircle(rl.GetMousePosition(), points[i + 1], 8.0) then
				focusedPoint = i
				break
			end
		end
		if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then selectedPoint = focusedPoint end
	end

	-- Point movement
	if selectedPoint >= 0 then
		points[selectedPoint + 1] = rl.GetMousePosition()
		if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then selectedPoint = -1 end
	end

	-- Bezier control points
	if splineTypeActive == SPLINE_BEZIER and focusedPoint == -1 then
		if selectedControlPoint == nil then
			focusedControlPoint = nil
			for i = 0, pointCount - 2 do
				if rl.CheckCollisionPointCircle(rl.GetMousePosition(), control[i + 1].start, 6.0) then
					focusedControlPoint = { seg = i + 1, which = "start" }
					break
				elseif rl.CheckCollisionPointCircle(rl.GetMousePosition(), control[i + 1].endp, 6.0) then
					focusedControlPoint = { seg = i + 1, which = "endp" }
					break
				end
			end
			if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then selectedControlPoint = focusedControlPoint end
		end

		if selectedControlPoint ~= nil then
			local mp = rl.GetMousePosition()
			control[selectedControlPoint.seg][selectedControlPoint.which].x = mp.x
			control[selectedControlPoint.seg][selectedControlPoint.which].y = mp.y
			if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then selectedControlPoint = nil end
		end
	end

	-- Spline type selection
	if rl.IsKeyPressed(rl.KEY_ONE) then splineTypeActive = 0
	elseif rl.IsKeyPressed(rl.KEY_TWO) then splineTypeActive = 1
	elseif rl.IsKeyPressed(rl.KEY_THREE) then splineTypeActive = 2
	elseif rl.IsKeyPressed(rl.KEY_FOUR) then splineTypeActive = 3
	end

	if rl.IsKeyPressed(rl.KEY_ONE) or rl.IsKeyPressed(rl.KEY_TWO) or rl.IsKeyPressed(rl.KEY_THREE) then
		selectedControlPoint = nil
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		if splineTypeActive == SPLINE_LINEAR then
			rl.DrawSplineLinear(points, pointCount, splineThickness, rl.RED)
		elseif splineTypeActive == SPLINE_BASIS then
			rl.DrawSplineBasis(points, pointCount, splineThickness, rl.RED)
		elseif splineTypeActive == SPLINE_CATMULLROM then
			rl.DrawSplineCatmullRom(points, pointCount, splineThickness, rl.RED)
		elseif splineTypeActive == SPLINE_BEZIER then
			for i = 0, pointCount - 2 do
				pointsInterleaved[3 * i + 1] = points[i + 1]
				pointsInterleaved[3 * i + 2] = control[i + 1].start
				pointsInterleaved[3 * i + 3] = control[i + 1].endp
			end

			pointsInterleaved[3 * (pointCount - 1) + 1] = points[pointCount]

			rl.DrawSplineBezierCubic(pointsInterleaved, 3 * (pointCount - 1) + 1, splineThickness, rl.RED)

			for i = 0, pointCount - 2 do
				rl.DrawCircleV(control[i + 1].start, 6, rl.GOLD)
				rl.DrawCircleV(control[i + 1].endp, 6, rl.GOLD)
				if focusedControlPoint ~= nil and focusedControlPoint.seg == i + 1 and focusedControlPoint.which == "start" then
					rl.DrawCircleV(control[i + 1].start, 8, rl.GREEN)
				elseif focusedControlPoint ~= nil and focusedControlPoint.seg == i + 1 and focusedControlPoint.which == "endp" then
					rl.DrawCircleV(control[i + 1].endp, 8, rl.GREEN)
				end
				rl.DrawLineEx(points[i + 1], control[i + 1].start, 1.0, rl.LIGHTGRAY)
				rl.DrawLineEx(points[i + 2], control[i + 1].endp, 1.0, rl.LIGHTGRAY)

				rl.DrawLineV(points[i + 1], control[i + 1].start, rl.GRAY)
				rl.DrawLineV(control[i + 1].endp, points[i + 2], rl.GRAY)
			end
		end

		if splineHelpersActive then
			for i = 0, pointCount - 1 do
				if focusedPoint == i then
					rl.DrawCircleLinesV(points[i + 1], 12.0, rl.BLUE)
				else
					rl.DrawCircleLinesV(points[i + 1], 8.0, rl.DARKBLUE)
				end
				if splineTypeActive ~= SPLINE_LINEAR and splineTypeActive ~= SPLINE_BEZIER and i < pointCount - 1 then
					rl.DrawLineV(points[i + 1], points[i + 2], rl.GRAY)
				end

				rl.DrawText(string.format("[%.0f, %.0f]", points[i + 1].x, points[i + 1].y), points[i + 1].x, points[i + 1].y + 10, 10, rl.BLACK)
			end
		end

		-- UI controls
		local function SliderBar(bx, by, bw, bh, value, minVal, maxVal)
			local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
			if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
				value = minVal + (maxVal - minVal) * (mx - bx) / bw
			end
			value = math.max(minVal, math.min(maxVal, value))
			rl.DrawRectangle(bx, by, bw, bh, rl.LIGHTGRAY)
			local fillW = (value - minVal) / (maxVal - minVal) * bw
			rl.DrawRectangle(bx, by, fillW, bh, rl.MAROON)
			rl.DrawRectangleLines(bx, by, bw, bh, rl.DARKGRAY)
			return value
		end

		rl.DrawText(string.format("Spline thickness: %i", math.floor(splineThickness)), 12, 62, 14, rl.DARKGRAY)
		splineThickness = SliderBar(12, 84, 140, 16, splineThickness, 1.0, 40.0)

		-- Checkbox for helpers
		rl.DrawRectangle(12, 110, 20, 20, splineHelpersActive and rl.MAROON or rl.LIGHTGRAY)
		rl.DrawRectangleLines(12, 110, 20, 20, rl.DARKGRAY)
		rl.DrawText("Show point helpers", 36, 112, 10, rl.DARKGRAY)
		local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
		if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and mx >= 12 and mx <= 32 and my >= 110 and my <= 130 then
			splineHelpersActive = not splineHelpersActive
		end

		rl.DrawText("Spline type:", 12, 10, 14, rl.DARKGRAY)

		local types = { "LINEAR", "BSPLINE", "CATMULLROM", "BEZIER" }
		rl.DrawRectangle(12, 32, 140, 28, rl.LIGHTGRAY)
		rl.DrawRectangleLines(12, 32, 140, 28, rl.DARKGRAY)
		rl.DrawText(types[splineTypeActive + 1], 20, 36, 14, rl.BLACK)

		-- Dropdown simulation (click to cycle)
		if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and mx >= 12 and mx <= 152 and my >= 32 and my <= 60 then
			splineTypeActive = (splineTypeActive + 1) % 4
			if splineTypeActive ~= SPLINE_BEZIER then selectedControlPoint = nil end
		end

	rl.EndDrawing()
end

rl.CloseWindow()
