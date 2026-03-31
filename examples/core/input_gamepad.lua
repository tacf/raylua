--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_input_gamepad.c

]]

-- raylib [core] example - input gamepad
--
-- NOTE: This example requires a Gamepad connected to the system

-- Gamepad name ID depends on drivers and OS
local XBOX_ALIAS_1 = "xbox"
local XBOX_ALIAS_2 = "x-box"
local PS_ALIAS_1 = "playstation"
local PS_ALIAS_2 = "sony"

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - input gamepad")

local texPs3Pad = rl.LoadTexture("resources/ps3.png")
local texXboxPad = rl.LoadTexture("resources/xbox.png")

-- Set axis deadzones
local leftStickDeadzoneX = 0.1
local leftStickDeadzoneY = 0.1
local rightStickDeadzoneX = 0.1
local rightStickDeadzoneY = 0.1
local leftTriggerDeadzone = -0.9
local rightTriggerDeadzone = -0.9

local vibrateButton = rl.new("Rectangle", 0, 0, 0, 0)

rl.SetTargetFPS(60)

local gamepad = 0

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyPressed(rl.KEY_LEFT) and gamepad > 0 then gamepad = gamepad - 1 end
	if rl.IsKeyPressed(rl.KEY_RIGHT) then gamepad = gamepad + 1 end

	local mousePosition = rl.GetMousePosition()

	vibrateButton = rl.new("Rectangle", 10, 70.0 + 20 * rl.GetGamepadAxisCount(gamepad) + 20, 75, 24)
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and rl.CheckCollisionPointRec(mousePosition, vibrateButton) then
		rl.SetGamepadVibration(gamepad, 1.0, 1.0, 1.0)
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	if rl.IsGamepadAvailable(gamepad) then
		rl.DrawText(string.format("GP%d: %s", gamepad, rl.GetGamepadName(gamepad)), 10, 10, 10, rl.BLACK)

		-- Get axis values
		local leftStickX = rl.GetGamepadAxisMovement(gamepad, rl.GAMEPAD_AXIS_LEFT_X)
		local leftStickY = rl.GetGamepadAxisMovement(gamepad, rl.GAMEPAD_AXIS_LEFT_Y)
		local rightStickX = rl.GetGamepadAxisMovement(gamepad, rl.GAMEPAD_AXIS_RIGHT_X)
		local rightStickY = rl.GetGamepadAxisMovement(gamepad, rl.GAMEPAD_AXIS_RIGHT_Y)
		local leftTrigger = rl.GetGamepadAxisMovement(gamepad, rl.GAMEPAD_AXIS_LEFT_TRIGGER)
		local rightTrigger = rl.GetGamepadAxisMovement(gamepad, rl.GAMEPAD_AXIS_RIGHT_TRIGGER)

		-- Calculate deadzones
		if leftStickX > -leftStickDeadzoneX and leftStickX < leftStickDeadzoneX then leftStickX = 0.0 end
		if leftStickY > -leftStickDeadzoneY and leftStickY < leftStickDeadzoneY then leftStickY = 0.0 end
		if rightStickX > -rightStickDeadzoneX and rightStickX < rightStickDeadzoneX then rightStickX = 0.0 end
		if rightStickY > -rightStickDeadzoneY and rightStickY < rightStickDeadzoneY then rightStickY = 0.0 end
		if leftTrigger < leftTriggerDeadzone then leftTrigger = -1.0 end
		if rightTrigger < rightTriggerDeadzone then rightTrigger = -1.0 end

		local gamepadNameLower = string.lower(rl.GetGamepadName(gamepad))

		if string.find(gamepadNameLower, XBOX_ALIAS_1) or string.find(gamepadNameLower, XBOX_ALIAS_2) then
			rl.DrawTexture(texXboxPad, 0, 0, rl.DARKGRAY)

			-- Draw buttons: xbox home
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_MIDDLE) then rl.DrawCircle(394, 89, 19, rl.RED) end

			-- Draw buttons: basic
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_MIDDLE_RIGHT) then rl.DrawCircle(436, 150, 9, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_MIDDLE_LEFT) then rl.DrawCircle(352, 150, 9, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_LEFT) then rl.DrawCircle(501, 151, 15, rl.BLUE) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_DOWN) then rl.DrawCircle(536, 187, 15, rl.LIME) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT) then rl.DrawCircle(572, 151, 15, rl.MAROON) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_UP) then rl.DrawCircle(536, 115, 15, rl.GOLD) end

			-- Draw buttons: d-pad
			rl.DrawRectangle(317, 202, 19, 71, rl.BLACK)
			rl.DrawRectangle(293, 228, 69, 19, rl.BLACK)
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_UP) then rl.DrawRectangle(317, 202, 19, 26, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_DOWN) then rl.DrawRectangle(317, 202 + 45, 19, 26, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_LEFT) then rl.DrawRectangle(292, 228, 25, 19, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_RIGHT) then rl.DrawRectangle(292 + 44, 228, 26, 19, rl.RED) end

			-- Draw buttons: left-right back
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_TRIGGER_1) then rl.DrawCircle(259, 61, 20, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_TRIGGER_1) then rl.DrawCircle(536, 61, 20, rl.RED) end

			-- Draw axis: left joystick
			local leftGamepadColor = rl.BLACK
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_THUMB) then leftGamepadColor = rl.RED end
			rl.DrawCircle(259, 152, 39, rl.BLACK)
			rl.DrawCircle(259, 152, 34, rl.LIGHTGRAY)
			rl.DrawCircle(259 + math.floor(leftStickX * 20), 152 + math.floor(leftStickY * 20), 25, leftGamepadColor)

			-- Draw axis: right joystick
			local rightGamepadColor = rl.BLACK
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_THUMB) then rightGamepadColor = rl.RED end
			rl.DrawCircle(461, 237, 38, rl.BLACK)
			rl.DrawCircle(461, 237, 33, rl.LIGHTGRAY)
			rl.DrawCircle(461 + math.floor(rightStickX * 20), 237 + math.floor(rightStickY * 20), 25, rightGamepadColor)

			-- Draw axis: left-right triggers
			rl.DrawRectangle(170, 30, 15, 70, rl.GRAY)
			rl.DrawRectangle(604, 30, 15, 70, rl.GRAY)
			rl.DrawRectangle(170, 30, 15, math.floor(((1 + leftTrigger) / 2) * 70), rl.RED)
			rl.DrawRectangle(604, 30, 15, math.floor(((1 + rightTrigger) / 2) * 70), rl.RED)

		elseif string.find(gamepadNameLower, PS_ALIAS_1) or string.find(gamepadNameLower, PS_ALIAS_2) then
			rl.DrawTexture(texPs3Pad, 0, 0, rl.DARKGRAY)

			-- Draw buttons: ps
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_MIDDLE) then rl.DrawCircle(396, 222, 13, rl.RED) end

			-- Draw buttons: basic
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_MIDDLE_LEFT) then rl.DrawRectangle(328, 170, 32, 13, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_MIDDLE_RIGHT) then
				rl.DrawTriangle(
					rl.new("Vector2", 436, 168),
					rl.new("Vector2", 436, 185),
					rl.new("Vector2", 464, 177),
					rl.RED)
			end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_UP) then rl.DrawCircle(557, 144, 13, rl.LIME) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT) then rl.DrawCircle(586, 173, 13, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_DOWN) then rl.DrawCircle(557, 203, 13, rl.VIOLET) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_LEFT) then rl.DrawCircle(527, 173, 13, rl.PINK) end

			-- Draw buttons: d-pad
			rl.DrawRectangle(225, 132, 24, 84, rl.BLACK)
			rl.DrawRectangle(195, 161, 84, 25, rl.BLACK)
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_UP) then rl.DrawRectangle(225, 132, 24, 29, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_DOWN) then rl.DrawRectangle(225, 132 + 54, 24, 30, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_LEFT) then rl.DrawRectangle(195, 161, 30, 25, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_RIGHT) then rl.DrawRectangle(195 + 54, 161, 30, 25, rl.RED) end

			-- Draw buttons: left-right back buttons
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_TRIGGER_1) then rl.DrawCircle(239, 82, 20, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_TRIGGER_1) then rl.DrawCircle(557, 82, 20, rl.RED) end

			-- Draw axis: left joystick
			local leftGamepadColor = rl.BLACK
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_THUMB) then leftGamepadColor = rl.RED end
			rl.DrawCircle(319, 255, 35, rl.BLACK)
			rl.DrawCircle(319, 255, 31, rl.LIGHTGRAY)
			rl.DrawCircle(319 + math.floor(leftStickX * 20), 255 + math.floor(leftStickY * 20), 25, leftGamepadColor)

			-- Draw axis: right joystick
			local rightGamepadColor = rl.BLACK
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_THUMB) then rightGamepadColor = rl.RED end
			rl.DrawCircle(475, 255, 35, rl.BLACK)
			rl.DrawCircle(475, 255, 31, rl.LIGHTGRAY)
			rl.DrawCircle(475 + math.floor(rightStickX * 20), 255 + math.floor(rightStickY * 20), 25, rightGamepadColor)

			-- Draw axis: left-right triggers
			rl.DrawRectangle(169, 48, 15, 70, rl.GRAY)
			rl.DrawRectangle(611, 48, 15, 70, rl.GRAY)
			rl.DrawRectangle(169, 48, 15, math.floor(((1 + leftTrigger) / 2) * 70), rl.RED)
			rl.DrawRectangle(611, 48, 15, math.floor(((1 + rightTrigger) / 2) * 70), rl.RED)

		else
			-- Draw background: generic
			rl.DrawRectangleRounded(rl.new("Rectangle", 175, 110, 460, 220), 0.3, 16, rl.DARKGRAY)

			-- Draw buttons: basic
			rl.DrawCircle(365, 170, 12, rl.RAYWHITE)
			rl.DrawCircle(405, 170, 12, rl.RAYWHITE)
			rl.DrawCircle(445, 170, 12, rl.RAYWHITE)
			rl.DrawCircle(516, 191, 17, rl.RAYWHITE)
			rl.DrawCircle(551, 227, 17, rl.RAYWHITE)
			rl.DrawCircle(587, 191, 17, rl.RAYWHITE)
			rl.DrawCircle(551, 155, 17, rl.RAYWHITE)
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_MIDDLE_LEFT) then rl.DrawCircle(365, 170, 10, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_MIDDLE) then rl.DrawCircle(405, 170, 10, rl.GREEN) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_MIDDLE_RIGHT) then rl.DrawCircle(445, 170, 10, rl.BLUE) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_LEFT) then rl.DrawCircle(516, 191, 15, rl.GOLD) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_DOWN) then rl.DrawCircle(551, 227, 15, rl.BLUE) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT) then rl.DrawCircle(587, 191, 15, rl.GREEN) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_FACE_UP) then rl.DrawCircle(551, 155, 15, rl.RED) end

			-- Draw buttons: d-pad
			rl.DrawRectangle(245, 145, 28, 88, rl.RAYWHITE)
			rl.DrawRectangle(215, 174, 88, 29, rl.RAYWHITE)
			rl.DrawRectangle(247, 147, 24, 84, rl.BLACK)
			rl.DrawRectangle(217, 176, 84, 25, rl.BLACK)
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_UP) then rl.DrawRectangle(247, 147, 24, 29, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_DOWN) then rl.DrawRectangle(247, 147 + 54, 24, 30, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_LEFT) then rl.DrawRectangle(217, 176, 30, 25, rl.RED) end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_FACE_RIGHT) then rl.DrawRectangle(217 + 54, 176, 30, 25, rl.RED) end

			-- Draw buttons: left-right back
			rl.DrawRectangleRounded(rl.new("Rectangle", 215, 98, 100, 10), 0.5, 16, rl.DARKGRAY)
			rl.DrawRectangleRounded(rl.new("Rectangle", 495, 98, 100, 10), 0.5, 16, rl.DARKGRAY)
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_TRIGGER_1) then
				rl.DrawRectangleRounded(rl.new("Rectangle", 215, 98, 100, 10), 0.5, 16, rl.RED)
			end
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_TRIGGER_1) then
				rl.DrawRectangleRounded(rl.new("Rectangle", 495, 98, 100, 10), 0.5, 16, rl.RED)
			end

			-- Draw axis: left joystick
			local leftGamepadColor = rl.BLACK
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_LEFT_THUMB) then leftGamepadColor = rl.RED end
			rl.DrawCircle(345, 260, 40, rl.BLACK)
			rl.DrawCircle(345, 260, 35, rl.LIGHTGRAY)
			rl.DrawCircle(345 + math.floor(leftStickX * 20), 260 + math.floor(leftStickY * 20), 25, leftGamepadColor)

			-- Draw axis: right joystick
			local rightGamepadColor = rl.BLACK
			if rl.IsGamepadButtonDown(gamepad, rl.GAMEPAD_BUTTON_RIGHT_THUMB) then rightGamepadColor = rl.RED end
			rl.DrawCircle(465, 260, 40, rl.BLACK)
			rl.DrawCircle(465, 260, 35, rl.LIGHTGRAY)
			rl.DrawCircle(465 + math.floor(rightStickX * 20), 260 + math.floor(rightStickY * 20), 25, rightGamepadColor)

			-- Draw axis: left-right triggers
			rl.DrawRectangle(151, 110, 15, 70, rl.GRAY)
			rl.DrawRectangle(644, 110, 15, 70, rl.GRAY)
			rl.DrawRectangle(151, 110, 15, math.floor(((1 + leftTrigger) / 2) * 70), rl.RED)
			rl.DrawRectangle(644, 110, 15, math.floor(((1 + rightTrigger) / 2) * 70), rl.RED)
		end

		rl.DrawText(string.format("DETECTED AXIS [%i]:", rl.GetGamepadAxisCount(gamepad)), 10, 50, 10, rl.MAROON)

		for i = 0, rl.GetGamepadAxisCount(gamepad) - 1 do
			rl.DrawText(string.format("AXIS %i: %.02f", i, rl.GetGamepadAxisMovement(gamepad, i)), 20, 70 + 20 * i, 10, rl.DARKGRAY)
		end

		-- Draw vibrate button
		rl.DrawRectangleRec(vibrateButton, rl.SKYBLUE)
		rl.DrawText("VIBRATE", math.floor(vibrateButton.x + 14), math.floor(vibrateButton.y + 1), 10, rl.DARKGRAY)

		if rl.GetGamepadButtonPressed() ~= rl.GAMEPAD_BUTTON_UNKNOWN then
			rl.DrawText(string.format("DETECTED BUTTON: %i", rl.GetGamepadButtonPressed()), 10, 430, 10, rl.RED)
		else
			rl.DrawText("DETECTED BUTTON: NONE", 10, 430, 10, rl.GRAY)
		end
	else
		rl.DrawText(string.format("GP%d: NOT DETECTED", gamepad), 10, 10, 10, rl.GRAY)
		rl.DrawTexture(texXboxPad, 0, 0, rl.LIGHTGRAY)
	end

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(texPs3Pad)
rl.UnloadTexture(texXboxPad)

rl.CloseWindow()
