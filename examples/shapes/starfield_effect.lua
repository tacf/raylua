--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_starfield_effect.c

]]

-- raylib [shapes] example - starfield effect

local STAR_COUNT = 420

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - starfield effect")

local bgColor = rl.ColorLerp(rl.DARKBLUE, rl.BLACK, 0.69)

local speed = 10.0 / 9.0
local drawLines = true

local stars = {}
local starsScreenPos = {}

for i = 1, STAR_COUNT do
	stars[i] = {
		x = rl.GetRandomValue(-screenWidth / 2, screenWidth / 2),
		y = rl.GetRandomValue(-screenHeight / 2, screenHeight / 2),
		z = 1.0,
	}
	starsScreenPos[i] = rl.new("Vector2", 0, 0)
end

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	local mouseMove = rl.GetMouseWheelMove()
	if mouseMove ~= 0 then speed = speed + 2.0 * mouseMove / 9.0 end
	if speed < 0.0 then speed = 0.1
	elseif speed > 2.0 then speed = 2.0 end

	if rl.IsKeyPressed(rl.KEY_SPACE) then drawLines = not drawLines end

	local dt = rl.GetFrameTime()
	for i = 1, STAR_COUNT do
		local s = stars[i]
		s.z = s.z - dt * speed

		starsScreenPos[i] = rl.new("Vector2",
			screenWidth * 0.5 + s.x / s.z,
			screenHeight * 0.5 + s.y / s.z)

		if s.z < 0.0 or starsScreenPos[i].x < 0 or starsScreenPos[i].y < 0
			or starsScreenPos[i].x > screenWidth or starsScreenPos[i].y > screenHeight then
			s.x = rl.GetRandomValue(-screenWidth / 2, screenWidth / 2)
			s.y = rl.GetRandomValue(-screenHeight / 2, screenHeight / 2)
			s.z = 1.0
		end
	end

	rl.BeginDrawing()
		rl.ClearBackground(bgColor)

		for i = 1, STAR_COUNT do
			if drawLines then
				local t = rl.Clamp(stars[i].z + 1.0 / 32.0, 0.0, 1.0)
				if (t - stars[i].z) > 1e-3 then
					local startPos = rl.new("Vector2",
						screenWidth * 0.5 + stars[i].x / t,
						screenHeight * 0.5 + stars[i].y / t)
					rl.DrawLineV(startPos, starsScreenPos[i], rl.RAYWHITE)
				end
			else
				local radius = stars[i].z * (5.0 - 1.0) + 1.0 -- Lerp(z, 1, 5) maps z in [0,1] to [1,5]... but Lerp(t,a,b) = a + t*(b-a)
				-- Actually Lerp(t, a, b) in raylib = a + t*(b-a)
				radius = 1.0 + stars[i].z * (5.0 - 1.0)
				rl.DrawCircleV(starsScreenPos[i], radius, rl.RAYWHITE)
			end
		end

		rl.DrawText(string.format("[MOUSE WHEEL] Current Speed: %.0f", 9.0 * speed / 2.0), 10, 40, 20, rl.RAYWHITE)
		rl.DrawText(string.format("[SPACE] Current draw mode: %s", drawLines and "Lines" or "Circles"), 10, 70, 20, rl.RAYWHITE)

		rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
