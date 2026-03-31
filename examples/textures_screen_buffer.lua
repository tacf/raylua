--[[
	raylib [textures] example - screen buffer

	Example complexity rating: [★★☆☆] 2/4

	Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
	BSD-like license that allows static linking with closed source software

	Copyright (c) 2025 Agnis Aldiņš (@nezvers)
]]

local MAX_COLORS = 256
local SCALE_FACTOR = 2

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - screen buffer")

local imageWidth = math.floor(screenWidth / SCALE_FACTOR)
local imageHeight = math.floor(screenHeight / SCALE_FACTOR)
local flameWidth = math.floor(screenWidth / SCALE_FACTOR)

-- Generate flame color palette
local palette = {}
for i = 0, MAX_COLORS - 1 do
	local t = i / (MAX_COLORS - 1)
	local hue = t * t
	local saturation = t
	local value = t
	palette[i] = rl.ColorFromHSV(250.0 + 150.0 * hue, saturation, value)
end

-- Index buffer and flame root buffer
local indexBuffer = {}
for i = 0, imageWidth * imageHeight - 1 do
	indexBuffer[i] = 0
end

local flameRootBuffer = {}
for i = 0, flameWidth - 1 do
	flameRootBuffer[i] = 0
end

local screenImage = rl.GenImageColor(imageWidth, imageHeight, rl.BLACK)
local screenTexture = rl.LoadTextureFromImage(screenImage)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- Grow flameRoot
	for x = 2, flameWidth - 1 do
		local flame = flameRootBuffer[x]
		flame = flame + rl.GetRandomValue(0, 2)
		if flame > 255 then flame = 255 end
		flameRootBuffer[x] = flame
	end

	-- Transfer flameRoot to indexBuffer
	for x = 0, flameWidth - 1 do
		local i = x + (imageHeight - 1) * imageWidth
		indexBuffer[i] = flameRootBuffer[x]
	end

	-- Clear top row, because it can't move any higher
	for x = 0, imageWidth - 1 do
		if indexBuffer[x] ~= 0 then
			indexBuffer[x] = 0
		end
	end

	-- Skip top row, it is already cleared
	for y = 1, imageHeight - 1 do
		for x = 0, imageWidth - 1 do
			local i = x + y * imageWidth
			local colorIndex = indexBuffer[i]

			if colorIndex ~= 0 then
				-- Move pixel a row above
				indexBuffer[i] = 0
				local moveX = rl.GetRandomValue(0, 2) - 1
				local newX = x + moveX

				if newX > 0 and newX < imageWidth then
					local iabove = i - imageWidth + moveX
					local decay = rl.GetRandomValue(0, 3)
					if decay < colorIndex then
						colorIndex = colorIndex - decay
					else
						colorIndex = 0
					end
					indexBuffer[iabove] = colorIndex
				end
			end
		end
	end

	-- Update screenImage with palette colors
	for y = 1, imageHeight - 1 do
		for x = 0, imageWidth - 1 do
			local i = x + y * imageWidth
			local colorIndex = indexBuffer[i]
			local col = palette[colorIndex]
			rl.ImageDrawPixel(screenImage, x, y, col)
		end
	end

	rl.UpdateTexture(screenTexture, screenImage.data)

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTextureEx(screenTexture, rl.rlVertex2f(0, 0), 0.0, 2.0, rl.WHITE)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(screenTexture)
rl.UnloadImage(screenImage)

rl.CloseWindow()
