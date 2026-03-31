--[[
    raylib [textures] example - image rotate

    Example complexity rating: [★★☆☆] 2/4

    Example originally created with raylib 1.0, last time updated with raylib 1.0

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2014-2025 Ramon Santamaria (@raysan5)
]]

local NUM_TEXTURES = 3

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - image rotate")

-- NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
local image45 = rl.LoadImage("resources/raylib_logo.png")
local image90 = rl.LoadImage("resources/raylib_logo.png")
local imageNeg90 = rl.LoadImage("resources/raylib_logo.png")

rl.ImageRotate(image45, 45)
rl.ImageRotate(image90, 90)
rl.ImageRotate(imageNeg90, -90)

local textures = {}
textures[1] = rl.LoadTextureFromImage(image45)
textures[2] = rl.LoadTextureFromImage(image90)
textures[3] = rl.LoadTextureFromImage(imageNeg90)

local currentTexture = 1

rl.SetTargetFPS(60)                                              -- Set our game to run at 60 frames-per-second

-- Main game loop
while not rl.WindowShouldClose() do                              -- Detect window close button or ESC key
	-- Update
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) or rl.IsKeyPressed(rl.KEY_RIGHT) then
		currentTexture = (currentTexture % NUM_TEXTURES) + 1     -- Cycle between the textures
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexture(textures[currentTexture], math.floor(screenWidth/2 - textures[currentTexture].width/2),
		math.floor(screenHeight/2 - textures[currentTexture].height/2), rl.WHITE)

	rl.DrawText("Press LEFT MOUSE BUTTON to rotate the image clockwise", 250, 420, 10, rl.DARKGRAY)

	rl.EndDrawing()
end

-- De-Initialization
for i = 1, NUM_TEXTURES do
	rl.UnloadTexture(textures[i])
end

rl.CloseWindow()                                                 -- Close window and OpenGL context
