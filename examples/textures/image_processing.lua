--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_image_processing.c

]]

--[[
    raylib [textures] example - image processing

    Example complexity rating: [★★★☆] 3/4

    NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)

    Example originally created with raylib 1.4, last time updated with raylib 3.5

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2016-2025 Ramon Santamaria (@raysan5)
]]

local NUM_PROCESSES = 9

local processText = {
	"NO PROCESSING",
	"COLOR GRAYSCALE",
	"COLOR TINT",
	"COLOR INVERT",
	"COLOR CONTRAST",
	"COLOR BRIGHTNESS",
	"GAUSSIAN BLUR",
	"FLIP VERTICAL",
	"FLIP HORIZONTAL"
}

local COLOR_GRAYSCALE = 1
local COLOR_TINT = 2
local COLOR_INVERT = 3
local COLOR_CONTRAST = 4
local COLOR_BRIGHTNESS = 5
local GAUSSIAN_BLUR = 6
local FLIP_VERTICAL = 7
local FLIP_HORIZONTAL = 8

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - image processing")

-- NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
local imOrigin = rl.LoadImage("resources/parrots.png")          -- Loaded in CPU memory (RAM)
rl.ImageFormat(imOrigin, rl.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)  -- Format image to RGBA 32bit (required for texture update)
local texture = rl.LoadTextureFromImage(imOrigin)                -- Image converted to texture, GPU memory (VRAM)

local imCopy = rl.ImageCopy(imOrigin)

local currentProcess = 0                                         -- NONE
local textureReload = false

local toggleRecs = {}
for i = 1, NUM_PROCESSES do
	toggleRecs[i] = rl.new("Rectangle", 40.0, 50.0 + 32*(i-1), 150.0, 30.0)
end

local mouseHoverRec = -1

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do                              -- Detect window close button or ESC key
	-- Update

	-- Mouse toggle group logic
	mouseHoverRec = -1
	for i = 1, NUM_PROCESSES do
		if rl.CheckCollisionPointRec(rl.GetMousePosition(), toggleRecs[i]) then
			mouseHoverRec = i - 1

			if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then
				currentProcess = i - 1
				textureReload = true
			end
			break
		end
	end

	-- Keyboard toggle group logic
	if rl.IsKeyPressed(rl.KEY_DOWN) then
		currentProcess = currentProcess + 1
		if currentProcess > (NUM_PROCESSES - 1) then currentProcess = 0 end
		textureReload = true
	elseif rl.IsKeyPressed(rl.KEY_UP) then
		currentProcess = currentProcess - 1
		if currentProcess < 0 then currentProcess = 7 end
		textureReload = true
	end

	-- Reload texture when required
	if textureReload then
		rl.UnloadImage(imCopy)                                     -- Unload image-copy data
		imCopy = rl.ImageCopy(imOrigin)                            -- Restore image-copy from image-origin

		-- NOTE: Image processing is a costly CPU process to be done every frame,
		-- If image processing is required in a frame-basis, it should be done
		-- with a texture and by shaders
		if currentProcess == COLOR_GRAYSCALE then
			rl.ImageColorGrayscale(imCopy)
		elseif currentProcess == COLOR_TINT then
			rl.ImageColorTint(imCopy, rl.GREEN)
		elseif currentProcess == COLOR_INVERT then
			rl.ImageColorInvert(imCopy)
		elseif currentProcess == COLOR_CONTRAST then
			rl.ImageColorContrast(imCopy, -40)
		elseif currentProcess == COLOR_BRIGHTNESS then
			rl.ImageColorBrightness(imCopy, -80)
		elseif currentProcess == GAUSSIAN_BLUR then
			rl.ImageBlurGaussian(imCopy, 10)
		elseif currentProcess == FLIP_VERTICAL then
			rl.ImageFlipVertical(imCopy)
		elseif currentProcess == FLIP_HORIZONTAL then
			rl.ImageFlipHorizontal(imCopy)
		end

		local pixels = rl.LoadImageColors(imCopy)                  -- Load pixel data from image (RGBA 32bit)
		rl.UpdateTexture(texture, pixels)                          -- Update texture with new image data
		rl.UnloadImageColors(pixels)                               -- Unload pixels data from RAM

		textureReload = false
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawText("IMAGE PROCESSING:", 40, 30, 10, rl.DARKGRAY)

	-- Draw rectangles
	for i = 1, NUM_PROCESSES do
		local isSelected = ((i - 1) == currentProcess) or ((i - 1) == mouseHoverRec)
		rl.DrawRectangleRec(toggleRecs[i], isSelected and rl.SKYBLUE or rl.LIGHTGRAY)
		rl.DrawRectangleLines(math.floor(toggleRecs[i].x), math.floor(toggleRecs[i].y),
			math.floor(toggleRecs[i].width), math.floor(toggleRecs[i].height),
			isSelected and rl.BLUE or rl.GRAY)
		rl.DrawText(processText[i],
			math.floor(toggleRecs[i].x + toggleRecs[i].width/2 - rl.MeasureText(processText[i], 10)/2),
			math.floor(toggleRecs[i].y) + 11, 10,
			isSelected and rl.DARKBLUE or rl.DARKGRAY)
	end

	rl.DrawTexture(texture, screenWidth - texture.width - 60, math.floor(screenHeight/2 - texture.height/2), rl.WHITE)
	rl.DrawRectangleLines(screenWidth - texture.width - 60, math.floor(screenHeight/2 - texture.height/2),
		texture.width, texture.height, rl.BLACK)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(texture)                                        -- Unload texture from VRAM
rl.UnloadImage(imOrigin)                                         -- Unload image-origin from RAM
rl.UnloadImage(imCopy)                                           -- Unload image-copy from RAM

rl.CloseWindow()                                                 -- Close window and OpenGL context
