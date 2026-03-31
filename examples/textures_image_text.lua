--[[
    raylib [textures] example - image text

    Example complexity rating: [★★☆☆] 2/4

    Example originally created with raylib 1.8, last time updated with raylib 4.0

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2017-2025 Ramon Santamaria (@raysan5)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - image text")

local parrots = rl.LoadImage("resources/parrots.png")            -- Load image in CPU memory (RAM)

-- TTF Font loading with custom generation parameters
local font = rl.LoadFontEx("resources/KAISG.ttf", 64, 0, 0)

-- Draw over image using custom font
rl.ImageDrawTextEx(parrots, font, "[Parrots font drawing]", rl.new("Vector2", 20.0, 20.0), font.baseSize, 0.0, rl.RED)

local texture = rl.LoadTextureFromImage(parrots)                 -- Image converted to texture, uploaded to GPU memory (VRAM)
rl.UnloadImage(parrots)                                          -- Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

local position = rl.new("Vector2", screenWidth/2 - texture.width/2, screenHeight/2 - texture.height/2 - 20)

local showFont = false

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do                              -- Detect window close button or ESC key
	-- Update
	if rl.IsKeyDown(rl.KEY_SPACE) then showFont = true
	else showFont = false end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	if not showFont then
		-- Draw texture with text already drawn inside
		rl.DrawTextureV(texture, position, rl.WHITE)

		-- Draw text directly using sprite font
		rl.DrawTextEx(font, "[Parrots font drawing]", rl.new("Vector2", position.x + 20,
			position.y + 20 + 280), font.baseSize, 0.0, rl.WHITE)
	else
		rl.DrawTexture(font.texture, math.floor(screenWidth/2 - font.texture.width/2), 50, rl.BLACK)
	end

	rl.DrawText("PRESS SPACE to SHOW FONT ATLAS USED", 290, 420, 10, rl.DARKGRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(texture)                                        -- Texture unloading

rl.UnloadFont(font)                                              -- Unload custom font

rl.CloseWindow()                                                 -- Close window and OpenGL context
