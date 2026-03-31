-- raylib [core] example - basic screen manager

-- Game screen states
local LOGO = 0
local TITLE = 1
local GAMEPLAY = 2
local ENDING = 3

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic screen manager")

local currentScreen = LOGO

-- TODO: Initialize all required variables and load all required data here!

local framesCounter = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if currentScreen == LOGO then
		-- TODO: Update LOGO screen variables here!
		framesCounter = framesCounter + 1

		-- Wait for 2 seconds (120 frames) before jumping to TITLE screen
		if framesCounter > 120 then
			currentScreen = TITLE
		end
	elseif currentScreen == TITLE then
		-- TODO: Update TITLE screen variables here!
		if rl.IsKeyPressed(rl.KEY_ENTER) or rl.IsGestureDetected(rl.GESTURE_TAP) then
			currentScreen = GAMEPLAY
		end
	elseif currentScreen == GAMEPLAY then
		-- TODO: Update GAMEPLAY screen variables here!
		if rl.IsKeyPressed(rl.KEY_ENTER) or rl.IsGestureDetected(rl.GESTURE_TAP) then
			currentScreen = ENDING
		end
	elseif currentScreen == ENDING then
		-- TODO: Update ENDING screen variables here!
		if rl.IsKeyPressed(rl.KEY_ENTER) or rl.IsGestureDetected(rl.GESTURE_TAP) then
			currentScreen = TITLE
		end
	end

	-- Draw
	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		if currentScreen == LOGO then
			-- TODO: Draw LOGO screen here!
			rl.DrawText("LOGO SCREEN", 20, 20, 40, rl.LIGHTGRAY)
			rl.DrawText("WAIT for 2 SECONDS...", 290, 220, 20, rl.GRAY)
		elseif currentScreen == TITLE then
			-- TODO: Draw TITLE screen here!
			rl.DrawRectangle(0, 0, screenWidth, screenHeight, rl.GREEN)
			rl.DrawText("TITLE SCREEN", 20, 20, 40, rl.DARKGREEN)
			rl.DrawText("PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN", 120, 220, 20, rl.DARKGREEN)
		elseif currentScreen == GAMEPLAY then
			-- TODO: Draw GAMEPLAY screen here!
			rl.DrawRectangle(0, 0, screenWidth, screenHeight, rl.PURPLE)
			rl.DrawText("GAMEPLAY SCREEN", 20, 20, 40, rl.MAROON)
			rl.DrawText("PRESS ENTER or TAP to JUMP to ENDING SCREEN", 130, 220, 20, rl.MAROON)
		elseif currentScreen == ENDING then
			-- TODO: Draw ENDING screen here!
			rl.DrawRectangle(0, 0, screenWidth, screenHeight, rl.BLUE)
			rl.DrawText("ENDING SCREEN", 20, 20, 40, rl.DARKBLUE)
			rl.DrawText("PRESS ENTER or TAP to RETURN to TITLE SCREEN", 120, 220, 20, rl.DARKBLUE)
		end
	rl.EndDrawing()
end

-- De-Initialization
-- TODO: Unload all loaded data (textures, fonts, audio) here!
rl.CloseWindow()
