--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_clock_of_clocks.c

]]

--[[
    raylib [shapes] example - clock of clocks

    Example complexity rating: [★★☆☆] 2/4

    Example originally created with raylib 5.5, last time updated with raylib 6.0

    Example contributed by JP Mortiboys (@themushroompirates) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2025 JP Mortiboys (@themushroompirates)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - clock of clocks")

local bgColor = rl.ColorLerp(rl.DARKBLUE, rl.BLACK, 0.75)
local handsColor = rl.ColorLerp(rl.YELLOW, rl.RAYWHITE, 0.25)

local clockFaceSize = 24
local clockFaceSpacing = 8.0
local sectionSpacing = 16.0

local TL = rl.new("Vector2",   0.0,  90.0)
local TR = rl.new("Vector2",  90.0, 180.0)
local BR = rl.new("Vector2", 180.0, 270.0)
local BL = rl.new("Vector2",   0.0, 270.0)
local HH = rl.new("Vector2",   0.0, 180.0)
local VV = rl.new("Vector2",  90.0, 270.0)
local ZZ = rl.new("Vector2", 135.0, 135.0)

-- digitAngles[digit][cell] = Vector2 pair
local digitAngles = {
	-- 0
	{ TL,HH,HH,TR, VV,TL,TR,VV, VV,VV,VV,VV, VV,VV,VV,VV, VV,BL,BR,VV, BL,HH,HH,BR },
	-- 1
	{ TL,HH,TR,ZZ, BL,TR,VV,ZZ, ZZ,VV,VV,ZZ, ZZ,VV,VV,ZZ, TL,BR,BL,TR, BL,HH,HH,BR },
	-- 2
	{ TL,HH,HH,TR, BL,HH,TR,VV, TL,HH,BR,VV, VV,TL,HH,BR, VV,BL,HH,TR, BL,HH,HH,BR },
	-- 3
	{ TL,HH,HH,TR, BL,HH,TR,VV, TL,HH,BR,VV, BL,HH,TR,VV, TL,HH,BR,VV, BL,HH,HH,BR },
	-- 4
	{ TL,TR,TL,TR, VV,VV,VV,VV, VV,BL,BR,VV, BL,HH,TR,VV, ZZ,ZZ,VV,VV, ZZ,ZZ,BL,BR },
	-- 5
	{ TL,HH,HH,TR, VV,TL,HH,BR, VV,BL,HH,TR, BL,HH,TR,VV, TL,HH,BR,VV, BL,HH,HH,BR },
	-- 6
	{ TL,HH,HH,TR, VV,TL,HH,BR, VV,BL,HH,TR, VV,TL,TR,VV, VV,BL,BR,VV, BL,HH,HH,BR },
	-- 7
	{ TL,HH,HH,TR, BL,HH,TR,VV, ZZ,ZZ,VV,VV, ZZ,ZZ,VV,VV, ZZ,ZZ,VV,VV, ZZ,ZZ,BL,BR },
	-- 8
	{ TL,HH,HH,TR, VV,TL,TR,VV, VV,BL,BR,VV, VV,TL,TR,VV, VV,BL,BR,VV, BL,HH,HH,BR },
	-- 9
	{ TL,HH,HH,TR, VV,TL,TR,VV, VV,BL,BR,VV, BL,HH,TR,VV, TL,HH,BR,VV, BL,HH,HH,BR },
}

local handsMoveDuration = 0.5

local prevSeconds = -1

-- currentAngles, srcAngles, dstAngles as tables indexed by [digit*24 + cell]
local currentAngles = {}
local srcAngles = {}
local dstAngles = {}
for i = 0, 6 * 24 - 1 do
	currentAngles[i] = rl.new("Vector2", 0, 0)
	srcAngles[i] = rl.new("Vector2", 0, 0)
	dstAngles[i] = rl.new("Vector2", 0, 0)
end

local handsMoveTimer = 0.0
local hourMode = 24

rl.SetTargetFPS(60)

-- Helper: Lerp for two values
local function lerp(a, b, t)
	return a + (b - a) * t
end

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- Get the current time via os.date
	local now = os.date("*t")

	if now.sec ~= prevSeconds then
		prevSeconds = now.sec

		local hourDisplay = now.hour % hourMode
		local minDisplay = now.min
		local secDisplay = now.sec

		local clockDigits = string.format("%02d%02d%02d", hourDisplay, minDisplay, secDisplay)

		for digit = 0, 5 do
			local d = tonumber(clockDigits:sub(digit + 1, digit + 1))
			for cell = 0, 23 do
				local idx = digit * 24 + cell
				srcAngles[idx] = rl.new("Vector2", currentAngles[idx].x, currentAngles[idx].y)
				dstAngles[idx] = digitAngles[d + 1][cell + 1]

				-- Quick exception for 12h mode
				if (digit == 0) and (hourMode == 12) and (hourDisplay == 0) then
					dstAngles[idx] = ZZ
				end
				if srcAngles[idx].x > dstAngles[idx].x then
					srcAngles[idx] = rl.new("Vector2", srcAngles[idx].x - 360.0, srcAngles[idx].y)
				end
				if srcAngles[idx].y > dstAngles[idx].y then
					srcAngles[idx] = rl.new("Vector2", srcAngles[idx].x, srcAngles[idx].y - 360.0)
				end
			end
		end

		handsMoveTimer = -rl.GetFrameTime()
	end

	-- Animate hands
	if handsMoveTimer < handsMoveDuration then
		handsMoveTimer = rl.Clamp(handsMoveTimer + rl.GetFrameTime(), 0, handsMoveDuration)

		local t = handsMoveTimer / handsMoveDuration
		t = t * t * (3.0 - 2.0 * t)

		for digit = 0, 5 do
			for cell = 0, 23 do
				local idx = digit * 24 + cell
				currentAngles[idx] = rl.new("Vector2",
					lerp(srcAngles[idx].x, dstAngles[idx].x, t),
					lerp(srcAngles[idx].y, dstAngles[idx].y, t)
				)
			end
		end
	end

	-- Handle input
	if rl.IsKeyPressed(rl.KEY_SPACE) then hourMode = 36 - hourMode end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(bgColor)

	rl.DrawText(string.format("%d-h mode, space to change", hourMode), 10, 30, 20, rl.RAYWHITE)

	local xOffset = 4.0

	for digit = 0, 5 do
		for row = 0, 5 do
			for col = 0, 3 do
				local centre = rl.new("Vector2",
					xOffset + col * (clockFaceSize + clockFaceSpacing) + clockFaceSize * 0.5,
					100 + row * (clockFaceSize + clockFaceSpacing) + clockFaceSize * 0.5
				)

				rl.DrawRing(centre, clockFaceSize * 0.5 - 2.0, clockFaceSize * 0.5, 0, 360, 24, rl.DARKGRAY)

				-- Big hand
				rl.DrawRectanglePro(
					rl.new("Rectangle", centre.x, centre.y, clockFaceSize * 0.5 + 4.0, 4.0),
					rl.new("Vector2", 2.0, 2.0),
					currentAngles[digit * 24 + row * 4 + col].x,
					handsColor
				)

				-- Little hand
				rl.DrawRectanglePro(
					rl.new("Rectangle", centre.x, centre.y, clockFaceSize * 0.5 + 2.0, 4.0),
					rl.new("Vector2", 2.0, 2.0),
					currentAngles[digit * 24 + row * 4 + col].y,
					handsColor
				)
			end
		end

		xOffset = xOffset + (clockFaceSize + clockFaceSpacing) * 4
		if digit % 2 == 1 then
			rl.DrawRing(rl.new("Vector2", xOffset + 4.0, 160.0), 6.0, 8.0, 0.0, 360.0, 24, handsColor)
			rl.DrawRing(rl.new("Vector2", xOffset + 4.0, 225.0), 6.0, 8.0, 0.0, 360.0, 24, handsColor)
			xOffset = xOffset + sectionSpacing
		end
	end

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
