--[[
	raylib [textures] example - sprite button

	Example complexity rating: [★★☆☆] 2/4

	Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
	BSD-like license that allows static linking with closed source software

	Copyright (c) 2019-2025 Ramon Santamaria (@raysan5)
]]

local NUM_FRAMES = 3

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - sprite button")

rl.InitAudioDevice()

local fxButton = rl.LoadSound("resources/buttonfx.wav")
local button = rl.LoadTexture("resources/button.png")

-- Define frame rectangle for drawing
local frameHeight = button.height / NUM_FRAMES
local sourceRec = rl.new("Rectangle", 0, 0, button.width, frameHeight)

-- Define button bounds on screen
local btnBounds = rl.new("Rectangle",
	screenWidth / 2.0 - button.width / 2.0,
	screenHeight / 2.0 - button.height / NUM_FRAMES / 2.0,
	button.width,
	frameHeight
)

local btnState = 0
local btnAction = false

local mousePoint = rl.rlVertex2f(0.0, 0.0)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	mousePoint = rl.GetMousePosition()
	btnAction = false

	-- Check button state
	if rl.CheckCollisionPointRec(mousePoint, btnBounds) then
		if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) then
			btnState = 2
		else
			btnState = 1
		end

		if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then
			btnAction = true
		end
	else
		btnState = 0
	end

	if btnAction then
		rl.PlaySound(fxButton)
	end

	-- Calculate button frame rectangle to draw depending on button state
	sourceRec.y = btnState * frameHeight

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTextureRec(button, sourceRec, rl.rlVertex2f(btnBounds.x, btnBounds.y), rl.WHITE)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(button)
rl.UnloadSound(fxButton)

rl.CloseAudioDevice()

rl.CloseWindow()
