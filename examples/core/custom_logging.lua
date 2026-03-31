--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_custom_logging.c

]]

-- raylib [core] example - custom logging

local screenWidth = 800
local screenHeight = 450

-- Custom logging function
local function CustomTraceLog(msgType, text)
	local timeStr = os.date("%Y-%m-%d %H:%M:%S")

	local prefix = ""
	if msgType == rl.LOG_INFO then
		prefix = "[INFO] : "
	elseif msgType == rl.LOG_ERROR then
		prefix = "[ERROR]: "
	elseif msgType == rl.LOG_WARNING then
		prefix = "[WARN] : "
	elseif msgType == rl.LOG_DEBUG then
		prefix = "[DEBUG]: "
	end

	print(string.format("[%s] %s%s", timeStr, prefix, text))
end

-- Set custom logger
rl.SetTraceLogCallback(CustomTraceLog)

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - custom logging")

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- TODO: Update your variables here

	-- Draw
	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawText("Check out the console output to see the custom logger in action!", 60, 200, 20, rl.LIGHTGRAY)
	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
