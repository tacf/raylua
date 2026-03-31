-- raylib [shapes] example - rectangle advanced
-- Helper function: Draw rectangle with rounded edges and horizontal gradient
local function DrawRectangleRoundedGradientH(rec, roundnessLeft, roundnessRight, segments, left, right)
	if (roundnessLeft <= 0.0 and roundnessRight <= 0.0) or (rec.width < 1) or (rec.height < 1) then
		rl.DrawRectangleGradientEx(rec, left, left, right, right)
		return
	end

	if roundnessLeft >= 1.0 then roundnessLeft = 1.0 end
	if roundnessRight >= 1.0 then roundnessRight = 1.0 end

	local recSize = math.min(rec.width, rec.height)
	local radiusLeft = (recSize * roundnessLeft) / 2
	local radiusRight = (recSize * roundnessRight) / 2

	if radiusLeft <= 0.0 then radiusLeft = 0.0 end
	if radiusRight <= 0.0 then radiusRight = 0.0 end

	if radiusRight <= 0.0 and radiusLeft <= 0.0 then return end

	local stepLength = 90.0 / segments

	local DEG2RAD = math.pi / 180.0

	local point = {
		{ x = rec.x + radiusLeft, y = rec.y },
		{ x = rec.x + rec.width - radiusRight, y = rec.y },
		{ x = rec.x + rec.width, y = rec.y + radiusRight },
		{ x = rec.x + rec.width, y = rec.y + rec.height - radiusRight },
		{ x = rec.x + rec.width - radiusRight, y = rec.y + rec.height },
		{ x = rec.x + radiusLeft, y = rec.y + rec.height },
		{ x = rec.x, y = rec.y + rec.height - radiusLeft },
		{ x = rec.x, y = rec.y + radiusLeft },
		{ x = rec.x + radiusLeft, y = rec.y + radiusLeft },
		{ x = rec.x + rec.width - radiusRight, y = rec.y + radiusRight },
		{ x = rec.x + rec.width - radiusRight, y = rec.y + rec.height - radiusRight },
		{ x = rec.x + radiusLeft, y = rec.y + rec.height - radiusLeft },
	}

	local centers = { point[9], point[10], point[11], point[12] }
	local angles = { 180.0, 270.0, 0.0, 90.0 }

	rl.rlBegin(rl.RL_TRIANGLES)
		for k = 0, 3 do
			local color, radius
			if k == 0 then color = left;  radius = radiusLeft end
			if k == 1 then color = right; radius = radiusRight end
			if k == 2 then color = right; radius = radiusRight end
			if k == 3 then color = left;  radius = radiusLeft end

			local angle = angles[k + 1]
			local center = centers[k + 1]

			for i = 0, segments - 1 do
				rl.rlColor4ub(color.r, color.g, color.b, color.a)
				rl.rlVertex2f(center.x, center.y)
				rl.rlVertex2f(center.x + math.cos(DEG2RAD * (angle + stepLength)) * radius, center.y + math.sin(DEG2RAD * (angle + stepLength)) * radius)
				rl.rlVertex2f(center.x + math.cos(DEG2RAD * angle) * radius, center.y + math.sin(DEG2RAD * angle) * radius)
				angle = angle + stepLength
			end
		end

		-- [2] Upper Rectangle
		rl.rlColor4ub(left.r, left.g, left.b, left.a)
		rl.rlVertex2f(point[1].x, point[1].y)
		rl.rlVertex2f(point[9].x, point[9].y)
		rl.rlColor4ub(right.r, right.g, right.b, right.a)
		rl.rlVertex2f(point[10].x, point[10].y)
		rl.rlVertex2f(point[2].x, point[2].y)
		rl.rlColor4ub(left.r, left.g, left.b, left.a)
		rl.rlVertex2f(point[1].x, point[1].y)
		rl.rlColor4ub(right.r, right.g, right.b, right.a)
		rl.rlVertex2f(point[10].x, point[10].y)

		-- [4] Right Rectangle
		rl.rlColor4ub(right.r, right.g, right.b, right.a)
		rl.rlVertex2f(point[10].x, point[10].y)
		rl.rlVertex2f(point[11].x, point[11].y)
		rl.rlVertex2f(point[4].x, point[4].y)
		rl.rlVertex2f(point[3].x, point[3].y)
		rl.rlVertex2f(point[10].x, point[10].y)
		rl.rlVertex2f(point[4].x, point[4].y)

		-- [6] Bottom Rectangle
		rl.rlColor4ub(left.r, left.g, left.b, left.a)
		rl.rlVertex2f(point[12].x, point[12].y)
		rl.rlVertex2f(point[6].x, point[6].y)
		rl.rlColor4ub(right.r, right.g, right.b, right.a)
		rl.rlVertex2f(point[5].x, point[5].y)
		rl.rlVertex2f(point[11].x, point[11].y)
		rl.rlColor4ub(left.r, left.g, left.b, left.a)
		rl.rlVertex2f(point[12].x, point[12].y)
		rl.rlColor4ub(right.r, right.g, right.b, right.a)
		rl.rlVertex2f(point[5].x, point[5].y)

		-- [8] Left Rectangle
		rl.rlColor4ub(left.r, left.g, left.b, left.a)
		rl.rlVertex2f(point[8].x, point[8].y)
		rl.rlVertex2f(point[7].x, point[7].y)
		rl.rlVertex2f(point[12].x, point[12].y)
		rl.rlVertex2f(point[9].x, point[9].y)
		rl.rlVertex2f(point[8].x, point[8].y)
		rl.rlVertex2f(point[12].x, point[12].y)

		-- [9] Middle Rectangle
		rl.rlColor4ub(left.r, left.g, left.b, left.a)
		rl.rlVertex2f(point[9].x, point[9].y)
		rl.rlVertex2f(point[12].x, point[12].y)
		rl.rlColor4ub(right.r, right.g, right.b, right.a)
		rl.rlVertex2f(point[11].x, point[11].y)
		rl.rlVertex2f(point[10].x, point[10].y)
		rl.rlColor4ub(left.r, left.g, left.b, left.a)
		rl.rlVertex2f(point[9].x, point[9].y)
		rl.rlColor4ub(right.r, right.g, right.b, right.a)
		rl.rlVertex2f(point[11].x, point[11].y)
	rl.rlEnd()
end

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - rectangle advanced")

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	local width = rl.GetScreenWidth() / 2.0
	local height = rl.GetScreenHeight() / 6.0
	local rec = rl.new("Rectangle", rl.GetScreenWidth() / 2.0 - width / 2, rl.GetScreenHeight() / 2.0 - 5 * (height / 2), width, height)

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		DrawRectangleRoundedGradientH(rec, 0.8, 0.8, 36, rl.BLUE, rl.RED)

		rec.y = rec.y + rec.height + 1
		DrawRectangleRoundedGradientH(rec, 0.5, 1.0, 36, rl.RED, rl.PINK)

		rec.y = rec.y + rec.height + 1
		DrawRectangleRoundedGradientH(rec, 1.0, 0.5, 36, rl.RED, rl.BLUE)

		rec.y = rec.y + rec.height + 1
		DrawRectangleRoundedGradientH(rec, 0.0, 1.0, 36, rl.BLUE, rl.BLACK)

		rec.y = rec.y + rec.height + 1
		DrawRectangleRoundedGradientH(rec, 1.0, 0.0, 36, rl.BLUE, rl.PINK)
	rl.EndDrawing()
end

rl.CloseWindow()
