--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_textured_curve.c

]]

--[[
	raylib [textures] example - textured curve

	Example complexity rating: [★★★☆] 3/4

	Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
	BSD-like license that allows static linking with closed source software

	Copyright (c) 2022-2025 Jeffery Myers (@JeffM2501) and Ramon Santamaria (@raysan5)
]]

local texRoad = nil
local showCurve = false
local curveWidth = 50
local curveSegments = 24

local curveStartPosition = rl.rlVertex2f(80, 100)
local curveStartPositionTangent = rl.rlVertex2f(100, 300)
local curveEndPosition = rl.rlVertex2f(700, 350)
local curveEndPositionTangent = rl.rlVertex2f(600, 100)

local curveSelectedPoint = nil

-- Draw textured curve using Spline Cubic Bezier
local function DrawTexturedCurve()
	local step = 1.0 / curveSegments

	local previous = curveStartPosition
	local previousTangent = rl.rlVertex2f(0, 0)
	local previousV = 0
	local tangentSet = false

	local current = rl.rlVertex2f(0, 0)
	local t = 0.0

	for i = 1, curveSegments do
		t = step * i

		local a = (1.0 - t) ^ 3
		local b = 3.0 * (1.0 - t) ^ 2 * t
		local c = 3.0 * (1.0 - t) * t ^ 2
		local d = t ^ 3

		current.y = a * curveStartPosition.y + b * curveStartPositionTangent.y + c * curveEndPositionTangent.y + d * curveEndPosition.y
		current.x = a * curveStartPosition.x + b * curveStartPositionTangent.x + c * curveEndPositionTangent.x + d * curveEndPosition.x

		local delta = rl.rlVertex2f(current.x - previous.x, current.y - previous.y)

		local deltaLen = math.sqrt(delta.x * delta.x + delta.y * delta.y)
		local normal = rl.rlVertex2f(-delta.y / deltaLen, delta.x / deltaLen)

		local v = previousV + deltaLen / (texRoad.height * 2)

		if not tangentSet then
			previousTangent = rl.rlVertex2f(normal.x, normal.y)
			tangentSet = true
		end

		local prevPosNormal = rl.rlVertex2f(
			previous.x + previousTangent.x * curveWidth,
			previous.y + previousTangent.y * curveWidth
		)
		local prevNegNormal = rl.rlVertex2f(
			previous.x - previousTangent.x * curveWidth,
			previous.y - previousTangent.y * curveWidth
		)

		local currentPosNormal = rl.rlVertex2f(
			current.x + normal.x * curveWidth,
			current.y + normal.y * curveWidth
		)
		local currentNegNormal = rl.rlVertex2f(
			current.x - normal.x * curveWidth,
			current.y - normal.y * curveWidth
		)

		-- Draw the segment as a quad
		rl.rlSetTexture(texRoad.id)
		rl.rlBegin(rl.RL_QUADS)
			rl.rlColor4ub(255, 255, 255, 255)
			rl.rlNormal3f(0.0, 0.0, 1.0)

			rl.rlTexCoord2f(0, previousV)
			rl.rlVertex2f(prevNegNormal.x, prevNegNormal.y)

			rl.rlTexCoord2f(1, previousV)
			rl.rlVertex2f(prevPosNormal.x, prevPosNormal.y)

			rl.rlTexCoord2f(1, v)
			rl.rlVertex2f(currentPosNormal.x, currentPosNormal.y)

			rl.rlTexCoord2f(0, v)
			rl.rlVertex2f(currentNegNormal.x, currentNegNormal.y)
		rl.rlEnd()

		previous = current
		previousTangent = rl.rlVertex2f(normal.x, normal.y)
		previousV = v
	end
end

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_VSYNC_HINT | rl.FLAG_MSAA_4X_HINT)
rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - textured curve")

texRoad = rl.LoadTexture("resources/road.png")
rl.SetTextureFilter(texRoad, rl.TEXTURE_FILTER_BILINEAR)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyPressed(rl.KEY_SPACE) then showCurve = not showCurve end
	if rl.IsKeyPressed(rl.KEY_EQUAL) then curveWidth = curveWidth + 2 end
	if rl.IsKeyPressed(rl.KEY_MINUS) then curveWidth = curveWidth - 2 end
	if curveWidth < 2 then curveWidth = 2 end

	if rl.IsKeyPressed(rl.KEY_LEFT) then curveSegments = curveSegments - 2 end
	if rl.IsKeyPressed(rl.KEY_RIGHT) then curveSegments = curveSegments + 2 end
	if curveSegments < 2 then curveSegments = 2 end

	-- If the mouse is not down, clear the selection
	if not rl.IsMouseButtonDown(rl.MOUSE_LEFT_BUTTON) then
		curveSelectedPoint = nil
	end

	-- If a point was selected, move it
	if curveSelectedPoint then
		local delta = rl.GetMouseDelta()
		curveSelectedPoint.x = curveSelectedPoint.x + delta.x
		curveSelectedPoint.y = curveSelectedPoint.y + delta.y
	end

	-- Pick control points
	local mouse = rl.GetMousePosition()
	if rl.CheckCollisionPointCircle(mouse, curveStartPosition, 6) then
		curveSelectedPoint = curveStartPosition
	elseif rl.CheckCollisionPointCircle(mouse, curveStartPositionTangent, 6) then
		curveSelectedPoint = curveStartPositionTangent
	elseif rl.CheckCollisionPointCircle(mouse, curveEndPosition, 6) then
		curveSelectedPoint = curveEndPosition
	elseif rl.CheckCollisionPointCircle(mouse, curveEndPositionTangent, 6) then
		curveSelectedPoint = curveEndPositionTangent
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	DrawTexturedCurve()

	if showCurve then
		rl.DrawSplineSegmentBezierCubic(curveStartPosition, curveEndPosition, curveStartPositionTangent, curveEndPositionTangent, 2, rl.BLUE)
	end

	rl.DrawLineV(curveStartPosition, curveStartPositionTangent, rl.SKYBLUE)
	rl.DrawLineV(curveStartPositionTangent, curveEndPositionTangent, rl.Fade(rl.LIGHTGRAY, 0.4))
	rl.DrawLineV(curveEndPosition, curveEndPositionTangent, rl.PURPLE)

	if rl.CheckCollisionPointCircle(mouse, curveStartPosition, 6) then
		rl.DrawCircleV(curveStartPosition, 7, rl.YELLOW)
	end
	rl.DrawCircleV(curveStartPosition, 5, rl.RED)

	if rl.CheckCollisionPointCircle(mouse, curveStartPositionTangent, 6) then
		rl.DrawCircleV(curveStartPositionTangent, 7, rl.YELLOW)
	end
	rl.DrawCircleV(curveStartPositionTangent, 5, rl.MAROON)

	if rl.CheckCollisionPointCircle(mouse, curveEndPosition, 6) then
		rl.DrawCircleV(curveEndPosition, 7, rl.YELLOW)
	end
	rl.DrawCircleV(curveEndPosition, 5, rl.GREEN)

	if rl.CheckCollisionPointCircle(mouse, curveEndPositionTangent, 6) then
		rl.DrawCircleV(curveEndPositionTangent, 7, rl.YELLOW)
	end
	rl.DrawCircleV(curveEndPositionTangent, 5, rl.DARKGREEN)

	rl.DrawText("Drag points to move curve, press SPACE to show/hide base curve", 10, 10, 10, rl.DARKGRAY)
	rl.DrawText(string.format("Curve width: %2.0f (Use + and - to adjust)", curveWidth), 10, 30, 10, rl.DARKGRAY)
	rl.DrawText(string.format("Curve segments: %d (Use LEFT and RIGHT to adjust)", curveSegments), 10, 50, 10, rl.DARKGRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(texRoad)

rl.CloseWindow()
