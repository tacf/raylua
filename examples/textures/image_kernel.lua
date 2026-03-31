--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_image_kernel.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - image kernel")
rl.SetTargetFPS(60)

local image = rl.LoadImage("resources/cat.png")

local gaussiankernel = {
	1.0, 2.0, 1.0,
	2.0, 4.0, 2.0,
	1.0, 2.0, 1.0
}

local sobelkernel = {
	1.0, 0.0, -1.0,
	2.0, 0.0, -2.0,
	1.0, 0.0, -1.0
}

local sharpenkernel = {
	0.0, -1.0, 0.0,
	-1.0, 5.0, -1.0,
	0.0, -1.0, 0.0
}

local function NormalizeKernel(kernel, size)
	local sum = 0.0
	for i = 1, size do
		sum = sum + kernel[i]
	end

	if sum ~= 0.0 then
		for i = 1, size do
			kernel[i] = kernel[i] / sum
		end
	end
end

NormalizeKernel(gaussiankernel, 9)
NormalizeKernel(sharpenkernel, 9)
NormalizeKernel(sobelkernel, 9)

local catSharpend = rl.ImageCopy(image)
rl.ImageKernelConvolution(catSharpend, sharpenkernel, 9)

local catSobel = rl.ImageCopy(image)
rl.ImageKernelConvolution(catSobel, sobelkernel, 9)

local catGaussian = rl.ImageCopy(image)

for i = 1, 6 do
	rl.ImageKernelConvolution(catGaussian, gaussiankernel, 9)
end

rl.ImageCrop(image, rl.new("Rectangle", 0, 0, 200, 450))
rl.ImageCrop(catGaussian, rl.new("Rectangle", 0, 0, 200, 450))
rl.ImageCrop(catSobel, rl.new("Rectangle", 0, 0, 200, 450))
rl.ImageCrop(catSharpend, rl.new("Rectangle", 0, 0, 200, 450))

local texture = rl.LoadTextureFromImage(image)
local catSharpendTexture = rl.LoadTextureFromImage(catSharpend)
local catSobelTexture = rl.LoadTextureFromImage(catSobel)
local catGaussianTexture = rl.LoadTextureFromImage(catGaussian)

rl.UnloadImage(image)
rl.UnloadImage(catGaussian)
rl.UnloadImage(catSobel)
rl.UnloadImage(catSharpend)

while not rl.WindowShouldClose() do
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexture(catSharpendTexture, 0, 0, rl.WHITE)
	rl.DrawTexture(catSobelTexture, 200, 0, rl.WHITE)
	rl.DrawTexture(catGaussianTexture, 400, 0, rl.WHITE)
	rl.DrawTexture(texture, 600, 0, rl.WHITE)

	rl.EndDrawing()
end

rl.UnloadTexture(texture)
rl.UnloadTexture(catGaussianTexture)
rl.UnloadTexture(catSobelTexture)
rl.UnloadTexture(catSharpendTexture)

rl.CloseWindow()