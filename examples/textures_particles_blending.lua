--[[
    raylib [textures] example - particles blending

    Example complexity rating: [★☆☆☆] 1/4

    Example originally created with raylib 1.7, last time updated with raylib 3.5

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2017-2025 Ramon Santamaria (@raysan5)
]]

local MAX_PARTICLES = 200

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - particles blending")

-- Particles pool, reuse them!
local mouseTail = {}

-- Initialize particles
for i = 1, MAX_PARTICLES do
	mouseTail[i] = {
		position = rl.new("Vector2", 0, 0),
		color = rl.new("Color", rl.GetRandomValue(0, 255), rl.GetRandomValue(0, 255), rl.GetRandomValue(0, 255), 255),
		alpha = 1.0,
		size = rl.GetRandomValue(1, 30) / 20.0,
		rotation = rl.GetRandomValue(0, 360),
		active = false
	}
end

local gravity = 3.0

local smoke = rl.LoadTexture("resources/spark_flame.png")

local blending = rl.BLEND_ALPHA

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do                              -- Detect window close button or ESC key
	-- Update

	-- Activate one particle every frame and Update active particles
	-- NOTE: Particles initial position should be mouse position when activated
	-- NOTE: Particles fall down with gravity and rotation... and disappear after 2 seconds (alpha = 0)
	-- NOTE: When a particle disappears, active = false and it can be reused
	for i = 1, MAX_PARTICLES do
		if not mouseTail[i].active then
			mouseTail[i].active = true
			mouseTail[i].alpha = 1.0
			mouseTail[i].position = rl.GetMousePosition()
			break
		end
	end

	for i = 1, MAX_PARTICLES do
		if mouseTail[i].active then
			mouseTail[i].position.y = mouseTail[i].position.y + gravity/2
			mouseTail[i].alpha = mouseTail[i].alpha - 0.005

			if mouseTail[i].alpha <= 0.0 then mouseTail[i].active = false end

			mouseTail[i].rotation = mouseTail[i].rotation + 2.0
		end
	end

	if rl.IsKeyPressed(rl.KEY_SPACE) then
		if blending == rl.BLEND_ALPHA then blending = rl.BLEND_ADDITIVE
		else blending = rl.BLEND_ALPHA end
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.DARKGRAY)

	rl.BeginBlendMode(blending)

	-- Draw active particles
	for i = 1, MAX_PARTICLES do
		if mouseTail[i].active then
			rl.DrawTexturePro(smoke, rl.new("Rectangle", 0.0, 0.0, smoke.width, smoke.height),
				rl.new("Rectangle", mouseTail[i].position.x, mouseTail[i].position.y,
					smoke.width*mouseTail[i].size, smoke.height*mouseTail[i].size),
				rl.new("Vector2", smoke.width*mouseTail[i].size/2.0, smoke.height*mouseTail[i].size/2.0),
				mouseTail[i].rotation, rl.Fade(mouseTail[i].color, mouseTail[i].alpha))
		end
	end

	rl.EndBlendMode()

	rl.DrawText("PRESS SPACE to CHANGE BLENDING MODE", 180, 20, 20, rl.BLACK)

	if blending == rl.BLEND_ALPHA then rl.DrawText("ALPHA BLENDING", 290, screenHeight - 40, 20, rl.BLACK)
	else rl.DrawText("ADDITIVE BLENDING", 280, screenHeight - 40, 20, rl.RAYWHITE) end

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(smoke)

rl.CloseWindow()                                                 -- Close window and OpenGL context
