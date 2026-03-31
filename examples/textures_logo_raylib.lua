--[[
    raylib [textures] example - logo raylib

    Example complexity rating: [★☆☆☆] 1/4

    Example originally created with raylib 1.0, last time updated with raylib 1.0

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2014-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - logo raylib")

-- NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
local texture = rl.LoadTexture("resources/raylib_logo.png")     -- Texture loading

rl.SetTargetFPS(60)                                              -- Set our game to run at 60 frames-per-second

-- Main game loop
while not rl.WindowShouldClose() do                              -- Detect window close button or ESC key
	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexture(texture, math.floor(screenWidth/2 - texture.width/2), math.floor(screenHeight/2 - texture.height/2), rl.WHITE)

	rl.DrawText("this IS a texture!", 360, 370, 10, rl.GRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(texture)                                        -- Texture unloading

rl.CloseWindow()                                                 -- Close window and OpenGL context
