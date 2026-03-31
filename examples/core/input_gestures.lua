--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_input_gestures.c

]]

-- raylib [core] example - input gestures

local MAX_GESTURE_STRINGS = 20

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - input gestures")

local touchPosition = rl.new("Vector2", 0, 0)
local touchArea = rl.new("Rectangle", 220, 10, screenWidth - 230.0, screenHeight - 20.0)

local gesturesCount = 0
local gestureStrings = {}

local currentGesture = rl.GESTURE_NONE
local lastGesture = rl.GESTURE_NONE

rl.SetTargetFPS(60)

-- Gesture name lookup
local gestureNames = {
	[rl.GESTURE_TAP] = "GESTURE TAP",
	[rl.GESTURE_DOUBLETAP] = "GESTURE DOUBLETAP",
	[rl.GESTURE_HOLD] = "GESTURE HOLD",
	[rl.GESTURE_DRAG] = "GESTURE DRAG",
	[rl.GESTURE_SWIPE_RIGHT] = "GESTURE SWIPE RIGHT",
	[rl.GESTURE_SWIPE_LEFT] = "GESTURE SWIPE LEFT",
	[rl.GESTURE_SWIPE_UP] = "GESTURE SWIPE UP",
	[rl.GESTURE_SWIPE_DOWN] = "GESTURE SWIPE DOWN",
	[rl.GESTURE_PINCH_IN] = "GESTURE PINCH IN",
	[rl.GESTURE_PINCH_OUT] = "GESTURE PINCH OUT",
}

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	lastGesture = currentGesture
	currentGesture = rl.GetGestureDetected()
	touchPosition = rl.GetTouchPosition(0)

	if rl.CheckCollisionPointRec(touchPosition, touchArea) and (currentGesture ~= rl.GESTURE_NONE) then
		if currentGesture ~= lastGesture then
			-- Store gesture string
			local gestureName = gestureNames[currentGesture]
			if gestureName then
				gestureStrings[gesturesCount] = gestureName
				gesturesCount = gesturesCount + 1
			end

			-- Reset gestures strings
			if gesturesCount >= MAX_GESTURE_STRINGS then
				gestureStrings = {}
				gesturesCount = 0
			end
		end
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawRectangleRec(touchArea, rl.GRAY)
	rl.DrawRectangle(225, 15, screenWidth - 240, screenHeight - 30, rl.RAYWHITE)

	rl.DrawText("GESTURES TEST AREA", screenWidth - 270, screenHeight - 40, 20, rl.Fade(rl.GRAY, 0.5))

	for i = 0, gesturesCount - 1 do
		if i % 2 == 0 then
			rl.DrawRectangle(10, 30 + 20 * i, 200, 20, rl.Fade(rl.LIGHTGRAY, 0.5))
		else
			rl.DrawRectangle(10, 30 + 20 * i, 200, 20, rl.Fade(rl.LIGHTGRAY, 0.3))
		end

		if i < gesturesCount - 1 then
			rl.DrawText(gestureStrings[i], 35, 36 + 20 * i, 10, rl.DARKGRAY)
		else
			rl.DrawText(gestureStrings[i], 35, 36 + 20 * i, 10, rl.MAROON)
		end
	end

	rl.DrawRectangleLines(10, 29, 200, screenHeight - 50, rl.GRAY)
	rl.DrawText("DETECTED GESTURES", 50, 15, 10, rl.GRAY)

	if currentGesture ~= rl.GESTURE_NONE then rl.DrawCircleV(touchPosition, 30, rl.MAROON) end

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
