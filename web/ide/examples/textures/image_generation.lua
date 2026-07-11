--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_image_generation.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - image generation")
rl.SetTargetFPS(60)

local NUM_TEXTURES = 9

local verticalGradient = rl.GenImageGradientLinear(screenWidth, screenHeight, 0, rl.RED, rl.BLUE)
local horizontalGradient = rl.GenImageGradientLinear(screenWidth, screenHeight, 90, rl.RED, rl.BLUE)
local diagonalGradient = rl.GenImageGradientLinear(screenWidth, screenHeight, 45, rl.RED, rl.BLUE)
local radialGradient = rl.GenImageGradientRadial(screenWidth, screenHeight, 0.0, rl.WHITE, rl.BLACK)
local squareGradient = rl.GenImageGradientSquare(screenWidth, screenHeight, 0.0, rl.WHITE, rl.BLACK)
local checked = rl.GenImageChecked(screenWidth, screenHeight, 32, 32, rl.RED, rl.BLUE)
local whiteNoise = rl.GenImageWhiteNoise(screenWidth, screenHeight, 0.5)
local perlinNoise = rl.GenImagePerlinNoise(screenWidth, screenHeight, 50, 50, 4.0)
local cellular = rl.GenImageCellular(screenWidth, screenHeight, 32)

local textures = {}

textures[1] = rl.LoadTextureFromImage(verticalGradient)
textures[2] = rl.LoadTextureFromImage(horizontalGradient)
textures[3] = rl.LoadTextureFromImage(diagonalGradient)
textures[4] = rl.LoadTextureFromImage(radialGradient)
textures[5] = rl.LoadTextureFromImage(squareGradient)
textures[6] = rl.LoadTextureFromImage(checked)
textures[7] = rl.LoadTextureFromImage(whiteNoise)
textures[8] = rl.LoadTextureFromImage(perlinNoise)
textures[9] = rl.LoadTextureFromImage(cellular)

rl.UnloadImage(verticalGradient)
rl.UnloadImage(horizontalGradient)
rl.UnloadImage(diagonalGradient)
rl.UnloadImage(radialGradient)
rl.UnloadImage(squareGradient)
rl.UnloadImage(checked)
rl.UnloadImage(whiteNoise)
rl.UnloadImage(perlinNoise)
rl.UnloadImage(cellular)

local currentTexture = 1

while not rl.WindowShouldClose() do
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) or rl.IsKeyPressed(rl.KEY_RIGHT) then
		currentTexture = currentTexture + 1
		if currentTexture > NUM_TEXTURES then currentTexture = 1 end
	end

	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexture(textures[currentTexture], 0, 0, rl.WHITE)

	rl.DrawRectangle(30, 400, 325, 30, rl.Fade(rl.SKYBLUE, 0.5))
	rl.DrawRectangleLines(30, 400, 325, 30, rl.Fade(rl.WHITE, 0.5))
	rl.DrawText("MOUSE LEFT BUTTON to CYCLE PROCEDURAL TEXTURES", 40, 410, 10, rl.WHITE)

	if currentTexture == 1 then
		rl.DrawText("VERTICAL GRADIENT", 560, 10, 20, rl.RAYWHITE)
	elseif currentTexture == 2 then
		rl.DrawText("HORIZONTAL GRADIENT", 540, 10, 20, rl.RAYWHITE)
	elseif currentTexture == 3 then
		rl.DrawText("DIAGONAL GRADIENT", 540, 10, 20, rl.RAYWHITE)
	elseif currentTexture == 4 then
		rl.DrawText("RADIAL GRADIENT", 580, 10, 20, rl.LIGHTGRAY)
	elseif currentTexture == 5 then
		rl.DrawText("SQUARE GRADIENT", 580, 10, 20, rl.LIGHTGRAY)
	elseif currentTexture == 6 then
		rl.DrawText("CHECKED", 680, 10, 20, rl.RAYWHITE)
	elseif currentTexture == 7 then
		rl.DrawText("WHITE NOISE", 640, 10, 20, rl.RED)
	elseif currentTexture == 8 then
		rl.DrawText("PERLIN NOISE", 640, 10, 20, rl.RED)
	elseif currentTexture == 9 then
		rl.DrawText("CELLULAR", 670, 10, 20, rl.RAYWHITE)
	end

	rl.EndDrawing()
end

for i = 1, NUM_TEXTURES do
	rl.UnloadTexture(textures[i])
end

rl.CloseWindow()