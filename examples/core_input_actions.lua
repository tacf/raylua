-- raylib [core] example - input actions
--
-- Simple example for decoding input as actions, allowing remapping of input
-- to different keys or gamepad buttons

-- Action types
local NO_ACTION = 0
local ACTION_UP = 1
local ACTION_DOWN = 2
local ACTION_LEFT = 3
local ACTION_RIGHT = 4
local ACTION_FIRE = 5
local MAX_ACTION = 6

-- Key and button inputs
local gamepadIndex = 0
local actionInputs = {}
for i = 0, MAX_ACTION - 1 do
	actionInputs[i] = { key = 0, button = 0 }
end

-- Check action key/button pressed
local function IsActionPressed(action)
	if action < MAX_ACTION then
		return rl.IsKeyPressed(actionInputs[action].key) or
			rl.IsGamepadButtonPressed(gamepadIndex, actionInputs[action].button)
	end
	return false
end

-- Check action key/button released
local function IsActionReleased(action)
	if action < MAX_ACTION then
		return rl.IsKeyReleased(actionInputs[action].key) or
			rl.IsGamepadButtonReleased(gamepadIndex, actionInputs[action].button)
	end
	return false
end

-- Check action key/button down
local function IsActionDown(action)
	if action < MAX_ACTION then
		return rl.IsKeyDown(actionInputs[action].key) or
			rl.IsGamepadButtonDown(gamepadIndex, actionInputs[action].button)
	end
	return false
end

-- Set the "default" keyset (WASD + left-side gamepad buttons)
local function SetActionsDefault()
	actionInputs[ACTION_UP].key = rl.KEY_W
	actionInputs[ACTION_DOWN].key = rl.KEY_S
	actionInputs[ACTION_LEFT].key = rl.KEY_A
	actionInputs[ACTION_RIGHT].key = rl.KEY_D
	actionInputs[ACTION_FIRE].key = rl.KEY_SPACE

	actionInputs[ACTION_UP].button = rl.GAMEPAD_BUTTON_LEFT_FACE_UP
	actionInputs[ACTION_DOWN].button = rl.GAMEPAD_BUTTON_LEFT_FACE_DOWN
	actionInputs[ACTION_LEFT].button = rl.GAMEPAD_BUTTON_LEFT_FACE_LEFT
	actionInputs[ACTION_RIGHT].button = rl.GAMEPAD_BUTTON_LEFT_FACE_RIGHT
	actionInputs[ACTION_FIRE].button = rl.GAMEPAD_BUTTON_RIGHT_FACE_DOWN
end

-- Set the "alternate" keyset (Arrow keys + right-side gamepad buttons)
local function SetActionsCursor()
	actionInputs[ACTION_UP].key = rl.KEY_UP
	actionInputs[ACTION_DOWN].key = rl.KEY_DOWN
	actionInputs[ACTION_LEFT].key = rl.KEY_LEFT
	actionInputs[ACTION_RIGHT].key = rl.KEY_RIGHT
	actionInputs[ACTION_FIRE].key = rl.KEY_SPACE

	actionInputs[ACTION_UP].button = rl.GAMEPAD_BUTTON_RIGHT_FACE_UP
	actionInputs[ACTION_DOWN].button = rl.GAMEPAD_BUTTON_RIGHT_FACE_DOWN
	actionInputs[ACTION_LEFT].button = rl.GAMEPAD_BUTTON_RIGHT_FACE_LEFT
	actionInputs[ACTION_RIGHT].button = rl.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT
	actionInputs[ACTION_FIRE].button = rl.GAMEPAD_BUTTON_LEFT_FACE_DOWN
end

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - input actions")

-- Set default actions
local actionSet = 0
SetActionsDefault()
local releaseAction = false

local position = rl.new("Vector2", 400.0, 200.0)
local size = rl.new("Vector2", 40.0, 40.0)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	gamepadIndex = 0

	if IsActionDown(ACTION_UP) then position.y = position.y - 2 end
	if IsActionDown(ACTION_DOWN) then position.y = position.y + 2 end
	if IsActionDown(ACTION_LEFT) then position.x = position.x - 2 end
	if IsActionDown(ACTION_RIGHT) then position.x = position.x + 2 end
	if IsActionPressed(ACTION_FIRE) then
		position.x = (screenWidth - size.x) / 2
		position.y = (screenHeight - size.y) / 2
	end

	-- Register release action for one frame
	releaseAction = false
	if IsActionReleased(ACTION_FIRE) then releaseAction = true end

	-- Switch control scheme by pressing TAB
	if rl.IsKeyPressed(rl.KEY_TAB) then
		actionSet = 1 - actionSet
		if actionSet == 0 then
			SetActionsDefault()
		else
			SetActionsCursor()
		end
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.GRAY)

	if releaseAction then
		rl.DrawRectangleV(position, size, rl.BLUE)
	else
		rl.DrawRectangleV(position, size, rl.RED)
	end

	if actionSet == 0 then
		rl.DrawText("Current input set: WASD (default)", 10, 10, 20, rl.WHITE)
	else
		rl.DrawText("Current input set: Arrow keys", 10, 10, 20, rl.WHITE)
	end

	rl.DrawText("Use TAB key to toggles Actions keyset", 10, 50, 20, rl.GREEN)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
