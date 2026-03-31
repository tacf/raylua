--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_rlgl_color_wheel.c

]]

-- raylib [shapes] example - rlgl color wheel

local pointsMin = 3
local pointsMax = 256

local triangleCount = 64
local pointScale = 150.0
local value = 1.0

local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - rlgl color wheel")

local center = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0)
local circlePosition = rl.new("Vector2", center.x, center.y)
local color = rl.new("Color", 255, 255, 255, 255)
local settingColor = false
local sliderClicked = false
local renderType = rl.RL_TRIANGLES

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	triangleCount = triangleCount + rl.GetMouseWheelMove()
	triangleCount = math.floor(rl.Clamp(triangleCount, pointsMin, pointsMax))

	local sliderX, sliderY, sliderW, sliderH = 42.0, 16.0 + 64.0 + 45.0, 64.0, 16.0
	local mousePosition = rl.GetMousePosition()

	local sliderHover = (mousePosition.x >= sliderX and mousePosition.y >= sliderY
		and mousePosition.x < sliderX + sliderW
		and mousePosition.y < sliderY + sliderH)

	if rl.IsKeyDown(rl.KEY_LEFT_CONTROL) and rl.IsKeyDown(rl.KEY_C) then
		if rl.IsKeyPressed(rl.KEY_C) then
			rl.SetClipboardText(string.format("#%02X%02X%02X", color.r, color.g, color.b))
		end
	end

	if rl.IsKeyDown(rl.KEY_UP) then
		pointScale = pointScale * 1.025
		if pointScale > screenHeight / 2.0 then
			pointScale = screenHeight / 2.0
		else
			local diff = rl.new("Vector2", circlePosition.x - center.x, circlePosition.y - center.y)
			circlePosition = rl.new("Vector2",
				diff.x * 1.025 + center.x,
				diff.y * 1.025 + center.y)
		end
	end

	if rl.IsKeyDown(rl.KEY_DOWN) then
		pointScale = pointScale * 0.975
		if pointScale < 32.0 then
			pointScale = 32.0
		else
			local diff = rl.new("Vector2", circlePosition.x - center.x, circlePosition.y - center.y)
			circlePosition = rl.new("Vector2",
				diff.x * 0.975 + center.x,
				diff.y * 0.975 + center.y)
		end

		local distance = rl.Vector2Distance(center, circlePosition) / pointScale
		if distance > 1.0 then
			local dirSub = rl.new("Vector2", center.x - circlePosition.x, center.y - circlePosition.y)
			local ang = ((rl.Vector2Angle(rl.new("Vector2", 0.0, -pointScale), dirSub) / math.pi + 1.0) / 2.0)
			circlePosition = rl.new("Vector2",
				math.sin(ang * (math.pi * 2.0)) * pointScale + center.x,
				-math.cos(ang * (math.pi * 2.0)) * pointScale + center.y)
		end
	end

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and rl.Vector2Distance(rl.GetMousePosition(), center) <= pointScale + 10.0 then
		settingColor = true
	end
	if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then settingColor = false end

	-- Manual slider for value
	if sliderHover and rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then sliderClicked = true end
	if sliderClicked and rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then sliderClicked = false end

	if sliderClicked then
		value = (mousePosition.x - sliderX) / sliderW
		value = rl.Clamp(value, 0.0, 1.0)
	end

	if rl.IsKeyPressed(rl.KEY_SPACE) then renderType = rl.RL_LINES end
	if rl.IsKeyReleased(rl.KEY_SPACE) then renderType = rl.RL_TRIANGLES end

	if settingColor then
		circlePosition = rl.GetMousePosition()

		local distance = rl.Vector2Distance(center, circlePosition) / pointScale

		local dirSub = rl.new("Vector2", center.x - circlePosition.x, center.y - circlePosition.y)
		local ang = ((rl.Vector2Angle(rl.new("Vector2", 0.0, -pointScale), dirSub) / math.pi + 1.0) / 2.0)

		if distance > 1.0 then
			circlePosition = rl.new("Vector2",
				math.sin(ang * (math.pi * 2.0)) * pointScale + center.x,
				-math.cos(ang * (math.pi * 2.0)) * pointScale + center.y)
		end

		local angle360 = ang * 360.0
		local valueActual = rl.Clamp(distance, 0.0, 1.0)
		local grayVal = math.floor(value * 255.0)
		color = rl.ColorLerp(rl.new("Color", grayVal, grayVal, grayVal, 255),
			rl.ColorFromHSV(angle360, rl.Clamp(distance, 0.0, 1.0), 1.0), valueActual)
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.rlBegin(renderType)
		for i = 0, triangleCount - 1 do
			local angleOffset = (math.pi * 2.0) / triangleCount
			local ang = angleOffset * i
			local angleOffsetCalc = (i + 1) * angleOffset

			local offset = rl.new("Vector2", math.sin(ang) * pointScale, -math.cos(ang) * pointScale)
			local offset2 = rl.new("Vector2", math.sin(angleOffsetCalc) * pointScale, -math.cos(angleOffsetCalc) * pointScale)

			local position = rl.new("Vector2", center.x + offset.x, center.y + offset.y)
			local position2 = rl.new("Vector2", center.x + offset2.x, center.y + offset2.y)

			local angleNonRadian = (ang / (2.0 * math.pi)) * 360.0
			local angleNonRadianOffset = (angleOffset / (2.0 * math.pi)) * 360.0

			local currentColor = rl.ColorFromHSV(angleNonRadian, 1.0, 1.0)
			local offsetColor = rl.ColorFromHSV(angleNonRadian + angleNonRadianOffset, 1.0, 1.0)

			if renderType == rl.RL_TRIANGLES then
				rl.rlColor4ub(currentColor.r, currentColor.g, currentColor.b, currentColor.a)
				rl.rlVertex2f(position.x, position.y)
				rl.rlColor4f(value, value, value, 1.0)
				rl.rlVertex2f(center.x, center.y)
				rl.rlColor4ub(offsetColor.r, offsetColor.g, offsetColor.b, offsetColor.a)
				rl.rlVertex2f(position2.x, position2.y)
			elseif renderType == rl.RL_LINES then
				rl.rlColor4ub(currentColor.r, currentColor.g, currentColor.b, currentColor.a)
				rl.rlVertex2f(position.x, position.y)
				rl.rlColor4ub(rl.WHITE.r, rl.WHITE.g, rl.WHITE.b, rl.WHITE.a)
				rl.rlVertex2f(center.x, center.y)

				rl.rlVertex2f(center.x, center.y)
				rl.rlColor4ub(offsetColor.r, offsetColor.g, offsetColor.b, offsetColor.a)
				rl.rlVertex2f(position2.x, position2.y)

				rl.rlVertex2f(position2.x, position2.y)
				rl.rlColor4ub(currentColor.r, currentColor.g, currentColor.b, currentColor.a)
				rl.rlVertex2f(position.x, position.y)
			end
		end
		rl.rlEnd()

		local handleColor = rl.BLACK
		if rl.Vector2Distance(center, circlePosition) / pointScale <= 0.5 and value <= 0.5 then
			handleColor = rl.DARKGRAY
		end

		rl.DrawCircleLinesV(circlePosition, 4.0, handleColor)

		rl.DrawRectangleV(rl.new("Vector2", 8.0, 8.0), rl.new("Vector2", 64.0, 64.0), color)
		rl.DrawRectangleLinesEx(rl.new("Rectangle", 8.0, 8.0, 64.0, 64.0), 2.0, rl.ColorLerp(color, rl.BLACK, 0.5))

		rl.DrawText(string.format("#%02X%02X%02X\n(%d, %d, %d)", color.r, color.g, color.b, color.r, color.g, color.b), 8, 8 + 64 + 8, 20, rl.DARKGRAY)

		local copyColor = rl.DARKGRAY
		local copyOffset = 0
		if rl.IsKeyDown(rl.KEY_LEFT_CONTROL) and rl.IsKeyDown(rl.KEY_C) then
			copyColor = rl.DARKGREEN
			copyOffset = 4
		end

		rl.DrawText("press ctrl+c to copy!", 8, 425 - copyOffset, 20, copyColor)
		rl.DrawText(string.format("triangle count: %d", triangleCount), 8, 395, 20, rl.DARKGRAY)

		-- Manual value slider
		rl.DrawText("value:", sliderX, sliderY - 14, 10, rl.DARKGRAY)
		rl.DrawRectangle(sliderX, sliderY, sliderW, sliderH, rl.LIGHTGRAY)
		rl.DrawRectangle(sliderX, sliderY, value * sliderW, sliderH, rl.SKYBLUE)
		rl.DrawRectangleLines(sliderX, sliderY, sliderW, sliderH, rl.DARKGRAY)
		rl.DrawText(string.format("%.2f", value), sliderX + sliderW + 4, sliderY + 2, 10, rl.DARKGRAY)

		rl.DrawFPS(64 + 16, 8)

	rl.EndDrawing()
end

rl.CloseWindow()
