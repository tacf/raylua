--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_to_image.c

]]

--[[
	raylib [textures] example - to image

	Example complexity rating: [★☆☆☆] 1/4

	Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
	BSD-like license that allows static linking with closed source software

	Copyright (c) 2015-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - to image")

local image = rl.LoadImage("resources/raylib_logo.png")
local texture = rl.LoadTextureFromImage(image)
rl.UnloadImage(image)

image = rl.LoadImageFromTexture(texture)
rl.UnloadTexture(texture)

texture = rl.LoadTextureFromImage(image)
rl.UnloadImage(image)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexture(texture, math.floor(screenWidth / 2 - texture.width / 2), math.floor(screenHeight / 2 - texture.height / 2), rl.WHITE)

	rl.DrawText("this IS a texture loaded from an image!", 300, 370, 10, rl.GRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(texture)

rl.CloseWindow()
