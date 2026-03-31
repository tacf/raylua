--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_image_drawing.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - image drawing")
rl.SetTargetFPS(60)

local cat = rl.LoadImage("resources/cat.png")
rl.ImageCrop(cat, rl.new("Rectangle", 100, 10, 280, 380))
rl.ImageFlipHorizontal(cat)
rl.ImageResize(cat, 150, 200)

local parrots = rl.LoadImage("resources/parrots.png")

rl.ImageDraw(parrots, cat,
	rl.new("Rectangle", 0, 0, cat.width, cat.height),
	rl.new("Rectangle", 30, 40, cat.width * 1.5, cat.height * 1.5), rl.WHITE)
rl.ImageCrop(parrots, rl.new("Rectangle", 0, 50, parrots.width, parrots.height - 100))

rl.ImageDrawPixel(parrots, 10, 10, rl.RAYWHITE)
rl.ImageDrawCircleLines(parrots, 10, 10, 5, rl.RAYWHITE)
rl.ImageDrawRectangle(parrots, 5, 20, 10, 10, rl.RAYWHITE)

rl.UnloadImage(cat)

local font = rl.LoadFont("resources/custom_jupiter_crash.png")

rl.ImageDrawTextEx(parrots, font, "PARROTS & CAT", rl.new("Vector2", 300, 230), font.baseSize, -2, rl.WHITE)

rl.UnloadFont(font)

local texture = rl.LoadTextureFromImage(parrots)
rl.UnloadImage(parrots)

while not rl.WindowShouldClose() do
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexture(texture, screenWidth / 2 - texture.width / 2, screenHeight / 2 - texture.height / 2 - 40, rl.WHITE)
	rl.DrawRectangleLines(screenWidth / 2 - texture.width / 2, screenHeight / 2 - texture.height / 2 - 40, texture.width, texture.height, rl.DARKGRAY)

	rl.DrawText("We are drawing only one texture from various images composed!", 240, 350, 10, rl.DARKGRAY)
	rl.DrawText("Source images have been cropped, scaled, flipped and copied one over the other.", 190, 370, 10, rl.DARKGRAY)

	rl.EndDrawing()
end

rl.UnloadTexture(texture)

rl.CloseWindow()