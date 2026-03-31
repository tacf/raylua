--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_image_channel.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - image channel")
rl.SetTargetFPS(60)

local fudesumiImage = rl.LoadImage("resources/fudesumi.png")

local imageAlpha = rl.ImageFromChannel(fudesumiImage, 3)
rl.ImageAlphaMask(imageAlpha, imageAlpha)

local imageRed = rl.ImageFromChannel(fudesumiImage, 0)
rl.ImageAlphaMask(imageRed, imageAlpha)

local imageGreen = rl.ImageFromChannel(fudesumiImage, 1)
rl.ImageAlphaMask(imageGreen, imageAlpha)

local imageBlue = rl.ImageFromChannel(fudesumiImage, 2)
rl.ImageAlphaMask(imageBlue, imageAlpha)

local backgroundImage = rl.GenImageChecked(screenWidth, screenHeight, screenWidth / 20, screenHeight / 20, rl.ORANGE, rl.YELLOW)

local fudesumiTexture = rl.LoadTextureFromImage(fudesumiImage)
local textureAlpha = rl.LoadTextureFromImage(imageAlpha)
local textureRed = rl.LoadTextureFromImage(imageRed)
local textureGreen = rl.LoadTextureFromImage(imageGreen)
local textureBlue = rl.LoadTextureFromImage(imageBlue)
local backgroundTexture = rl.LoadTextureFromImage(backgroundImage)

rl.UnloadImage(fudesumiImage)
rl.UnloadImage(imageAlpha)
rl.UnloadImage(imageRed)
rl.UnloadImage(imageGreen)
rl.UnloadImage(imageBlue)
rl.UnloadImage(backgroundImage)

local fudesumiRec = { x = 0, y = 0, width = fudesumiImage.width, height = fudesumiImage.height }
local fudesumiPos = { x = 50, y = 10, width = fudesumiImage.width * 0.8, height = fudesumiImage.height * 0.8 }
local redPos = { x = 410, y = 10, width = fudesumiPos.width / 2.0, height = fudesumiPos.height / 2.0 }
local greenPos = { x = 600, y = 10, width = fudesumiPos.width / 2.0, height = fudesumiPos.height / 2.0 }
local bluePos = { x = 410, y = 230, width = fudesumiPos.width / 2.0, height = fudesumiPos.height / 2.0 }
local alphaPos = { x = 600, y = 230, width = fudesumiPos.width / 2.0, height = fudesumiPos.height / 2.0 }

while not rl.WindowShouldClose() do
	rl.BeginDrawing()

	rl.DrawTexture(backgroundTexture, 0, 0, rl.WHITE)
	rl.DrawTexturePro(fudesumiTexture,
		rl.new("Rectangle", fudesumiRec.x, fudesumiRec.y, fudesumiRec.width, fudesumiRec.height),
		rl.new("Rectangle", fudesumiPos.x, fudesumiPos.y, fudesumiPos.width, fudesumiPos.height),
		rl.new("Vector2", 0, 0), 0, rl.WHITE)

	rl.DrawTexturePro(textureRed,
		rl.new("Rectangle", fudesumiRec.x, fudesumiRec.y, fudesumiRec.width, fudesumiRec.height),
		rl.new("Rectangle", redPos.x, redPos.y, redPos.width, redPos.height),
		rl.new("Vector2", 0, 0), 0, rl.RED)

	rl.DrawTexturePro(textureGreen,
		rl.new("Rectangle", fudesumiRec.x, fudesumiRec.y, fudesumiRec.width, fudesumiRec.height),
		rl.new("Rectangle", greenPos.x, greenPos.y, greenPos.width, greenPos.height),
		rl.new("Vector2", 0, 0), 0, rl.GREEN)

	rl.DrawTexturePro(textureBlue,
		rl.new("Rectangle", fudesumiRec.x, fudesumiRec.y, fudesumiRec.width, fudesumiRec.height),
		rl.new("Rectangle", bluePos.x, bluePos.y, bluePos.width, bluePos.height),
		rl.new("Vector2", 0, 0), 0, rl.BLUE)

	rl.DrawTexturePro(textureAlpha,
		rl.new("Rectangle", fudesumiRec.x, fudesumiRec.y, fudesumiRec.width, fudesumiRec.height),
		rl.new("Rectangle", alphaPos.x, alphaPos.y, alphaPos.width, alphaPos.height),
		rl.new("Vector2", 0, 0), 0, rl.WHITE)

	rl.EndDrawing()
end

rl.UnloadTexture(backgroundTexture)
rl.UnloadTexture(fudesumiTexture)
rl.UnloadTexture(textureRed)
rl.UnloadTexture(textureGreen)
rl.UnloadTexture(textureBlue)
rl.UnloadTexture(textureAlpha)

rl.CloseWindow()