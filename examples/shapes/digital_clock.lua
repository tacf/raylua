--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_digital_clock.c

]]

--[[
    raylib [shapes] example - digital clock

    Example complexity rating: [★★★★] 4/4

    Example originally created with raylib 5.5, last time updated with raylib 5.6

    Example contributed by Hamza RAHAL (@hmz-rhl) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2025 Hamza RAHAL (@hmz-rhl) and Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - digital clock")

local CLOCK_ANALOG = 0
local CLOCK_DIGITAL = 1

local clockMode = CLOCK_DIGITAL

-- Clock hand data
local secondHand = { value = 0, angle = 45, length = 140, thickness = 3, color = rl.MAROON }
local minuteHand = { value = 0, angle = 10, length = 130, thickness = 7, color = rl.DARKGRAY }
local hourHand   = { value = 0, angle = 0,  length = 100, thickness = 7, color = rl.BLACK }

-- Update clock time
local function UpdateClock()
	local now = os.date("*t")

	secondHand.value = now.sec
	minuteHand.value = now.min
	hourHand.value = now.hour

	hourHand.angle = (now.hour % 12) * 180.0 / 6.0
	hourHand.angle = hourHand.angle + (now.min % 60) * 30 / 60.0
	hourHand.angle = hourHand.angle - 90

	minuteHand.angle = (now.min % 60) * 6.0
	minuteHand.angle = minuteHand.angle + (now.sec % 60) * 6 / 60.0
	minuteHand.angle = minuteHand.angle - 90

	secondHand.angle = (now.sec % 60) * 6.0
	secondHand.angle = secondHand.angle - 90
end

-- Draw one 7-segment display segment, horizontal or vertical
local function DrawDisplaySegment(center, length, thick, vertical, color)
	if not vertical then
		-- Horizontal segment points
		local points = {
			rl.new("Vector2", center.x - length/2.0 - thick/2.0, center.y),
			rl.new("Vector2", center.x - length/2.0, center.y + thick/2.0),
			rl.new("Vector2", center.x - length/2.0, center.y - thick/2.0),
			rl.new("Vector2", center.x + length/2.0, center.y + thick/2.0),
			rl.new("Vector2", center.x + length/2.0, center.y - thick/2.0),
			rl.new("Vector2", center.x + length/2.0 + thick/2.0, center.y),
		}
		rl.DrawTriangleStrip(points, 6, color)
	else
		-- Vertical segment points
		local points = {
			rl.new("Vector2", center.x, center.y - length/2.0 - thick/2.0),
			rl.new("Vector2", center.x - thick/2.0, center.y - length/2.0),
			rl.new("Vector2", center.x + thick/2.0, center.y - length/2.0),
			rl.new("Vector2", center.x - thick/2.0, center.y + length/2.0),
			rl.new("Vector2", center.x + thick/2.0, center.y + length/2.0),
			rl.new("Vector2", center.x, center.y + length/2.0 + thick/2.0),
		}
		rl.DrawTriangleStrip(points, 6, color)
	end
end

-- Draw seven segments display
local function Draw7SDisplay(position, segments, colorOn, colorOff)
	local segmentLen = 60
	local segmentThick = 20
	local offsetYAdjust = segmentThick * 0.3

	-- Segment A
	DrawDisplaySegment(rl.new("Vector2", position.x + segmentThick + segmentLen/2.0, position.y + segmentThick),
		segmentLen, segmentThick, false, bit.band(segments, 1) ~= 0 and colorOn or colorOff)
	-- Segment B
	DrawDisplaySegment(rl.new("Vector2", position.x + segmentThick + segmentLen + segmentThick/2.0, position.y + 2*segmentThick + segmentLen/2.0 - offsetYAdjust),
		segmentLen, segmentThick, true, bit.band(segments, 2) ~= 0 and colorOn or colorOff)
	-- Segment C
	DrawDisplaySegment(rl.new("Vector2", position.x + segmentThick + segmentLen + segmentThick/2.0, position.y + 4*segmentThick + segmentLen + segmentLen/2.0 - 3*offsetYAdjust),
		segmentLen, segmentThick, true, bit.band(segments, 4) ~= 0 and colorOn or colorOff)
	-- Segment D
	DrawDisplaySegment(rl.new("Vector2", position.x + segmentThick + segmentLen/2.0, position.y + 5*segmentThick + 2*segmentLen - 4*offsetYAdjust),
		segmentLen, segmentThick, false, bit.band(segments, 8) ~= 0 and colorOn or colorOff)
	-- Segment E
	DrawDisplaySegment(rl.new("Vector2", position.x + segmentThick/2.0, position.y + 4*segmentThick + segmentLen + segmentLen/2.0 - 3*offsetYAdjust),
		segmentLen, segmentThick, true, bit.band(segments, 16) ~= 0 and colorOn or colorOff)
	-- Segment F
	DrawDisplaySegment(rl.new("Vector2", position.x + segmentThick/2.0, position.y + 2*segmentThick + segmentLen/2.0 - offsetYAdjust),
		segmentLen, segmentThick, true, bit.band(segments, 32) ~= 0 and colorOn or colorOff)
	-- Segment G
	DrawDisplaySegment(rl.new("Vector2", position.x + segmentThick + segmentLen/2.0, position.y + 3*segmentThick + segmentLen - 2*offsetYAdjust),
		segmentLen, segmentThick, false, bit.band(segments, 64) ~= 0 and colorOn or colorOff)
end

-- 7-segment bit patterns for digits 0-9
local segmentPatterns = {
	0x3F, -- 0: 0b00111111
	0x06, -- 1: 0b00000110
	0x5B, -- 2: 0b01011011
	0x4F, -- 3: 0b01001111
	0x66, -- 4: 0b01100110
	0x6D, -- 5: 0b01101101
	0x7D, -- 6: 0b01111101
	0x07, -- 7: 0b00000111
	0x7F, -- 8: 0b01111111
	0x6F, -- 9: 0b01101111
}

-- Draw 7-segment display with value
local function DrawDisplayValue(position, value, colorOn, colorOff)
	if value >= 0 and value <= 9 then
		Draw7SDisplay(position, segmentPatterns[value + 1], colorOn, colorOff)
	end
end

-- Draw analog clock
local function DrawClockAnalog(pos)
	rl.DrawCircleV(pos, secondHand.length + 40.0, rl.LIGHTGRAY)
	rl.DrawCircleV(pos, 12.0, rl.GRAY)

	-- Draw clock minutes/seconds lines
	for i = 0, 59 do
		local innerLen = secondHand.length + ((i % 5 ~= 0) and 10 or 6)
		local outerLen = secondHand.length + 20
		local angle = math.rad(6.0 * i - 90.0)
		local cosA = math.cos(angle)
		local sinA = math.sin(angle)
		local thick = (i % 5 ~= 0) and 1.0 or 3.0

		rl.DrawLineEx(
			rl.new("Vector2", pos.x + innerLen * cosA, pos.y + innerLen * sinA),
			rl.new("Vector2", pos.x + outerLen * cosA, pos.y + outerLen * sinA),
			thick, rl.DARKGRAY)
	end

	-- Draw hand seconds
	rl.DrawRectanglePro(
		rl.new("Rectangle", pos.x, pos.y, secondHand.length, secondHand.thickness),
		rl.new("Vector2", 0.0, secondHand.thickness / 2.0), secondHand.angle, secondHand.color)

	-- Draw hand minutes
	rl.DrawRectanglePro(
		rl.new("Rectangle", pos.x, pos.y, minuteHand.length, minuteHand.thickness),
		rl.new("Vector2", 0.0, minuteHand.thickness / 2.0), minuteHand.angle, minuteHand.color)

	-- Draw hand hours
	rl.DrawRectanglePro(
		rl.new("Rectangle", pos.x, pos.y, hourHand.length, hourHand.thickness),
		rl.new("Vector2", 0.0, hourHand.thickness / 2.0), hourHand.angle, hourHand.color)
end

-- Draw digital clock
local function DrawClockDigital(pos)
	local colorOn = rl.RED
	local colorOff = rl.Fade(rl.LIGHTGRAY, 0.3)

	DrawDisplayValue(rl.new("Vector2", pos.x, pos.y), math.floor(hourHand.value / 10), colorOn, colorOff)
	DrawDisplayValue(rl.new("Vector2", pos.x + 120, pos.y), hourHand.value % 10, colorOn, colorOff)

	rl.DrawCircle(math.floor(pos.x + 240), math.floor(pos.y + 70), 12, (secondHand.value % 2 ~= 0) and colorOn or colorOff)
	rl.DrawCircle(math.floor(pos.x + 240), math.floor(pos.y + 150), 12, (secondHand.value % 2 ~= 0) and colorOn or colorOff)

	DrawDisplayValue(rl.new("Vector2", pos.x + 260, pos.y), math.floor(minuteHand.value / 10), colorOn, colorOff)
	DrawDisplayValue(rl.new("Vector2", pos.x + 380, pos.y), minuteHand.value % 10, colorOn, colorOff)

	rl.DrawCircle(math.floor(pos.x + 500), math.floor(pos.y + 70), 12, (secondHand.value % 2 ~= 0) and colorOn or colorOff)
	rl.DrawCircle(math.floor(pos.x + 500), math.floor(pos.y + 150), 12, (secondHand.value % 2 ~= 0) and colorOn or colorOff)

	DrawDisplayValue(rl.new("Vector2", pos.x + 520, pos.y), math.floor(secondHand.value / 10), colorOn, colorOff)
	DrawDisplayValue(rl.new("Vector2", pos.x + 640, pos.y), secondHand.value % 10, colorOn, colorOff)
end

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyPressed(rl.KEY_SPACE) then
		if clockMode == CLOCK_DIGITAL then clockMode = CLOCK_ANALOG
		elseif clockMode == CLOCK_ANALOG then clockMode = CLOCK_DIGITAL end
	end

	UpdateClock()

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	if clockMode == CLOCK_ANALOG then
		DrawClockAnalog(rl.new("Vector2", 400, 240))
	elseif clockMode == CLOCK_DIGITAL then
		DrawClockDigital(rl.new("Vector2", 30, 60))

		local clockTime = string.format("%02d:%02d:%02d", hourHand.value, minuteHand.value, secondHand.value)
		rl.DrawText(clockTime, rl.GetScreenWidth()/2 - rl.MeasureText(clockTime, 150)/2, 300, 150, rl.BLACK)
	end

	rl.DrawText(string.format("Press [SPACE] to switch clock mode: %s",
		(clockMode == CLOCK_DIGITAL) and "DIGITAL CLOCK" or "ANALOGUE CLOCK"), 10, 10, 20, rl.DARKGRAY)

	rl.EndDrawing()
end

rl.CloseWindow()
