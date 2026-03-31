--[[
    raylib [textures] example - polygon drawing

    Example complexity rating: [★☆☆☆] 1/4

    Example originally created with raylib 3.7, last time updated with raylib 3.7

    Example contributed by Chris Camacho (@chriscamacho) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2021-2025 Chris Camacho (@chriscamacho) and Ramon Santamaria (@raysan5)
]]

local MAX_POINTS = 11                                            -- 10 points and back to the start

-- Draw textured polygon, defined by vertex and texture coordinates
-- NOTE: Polygon center must have straight line path to all points
-- without crossing perimeter, points must be in anticlockwise order
local function DrawTexturePoly(texture, center, points, texcoords, pointCount, tint)
	rl.rlSetTexture(texture.id)
	rl.rlBegin(rl.RL_TRIANGLES)

	rl.rlColor4ub(tint.r, tint.g, tint.b, tint.a)

	for i = 1, pointCount - 1 do
		rl.rlTexCoord2f(0.5, 0.5)
		rl.rlVertex2f(center.x, center.y)

		rl.rlTexCoord2f(texcoords[i].x, texcoords[i].y)
		rl.rlVertex2f(points[i].x + center.x, points[i].y + center.y)

		rl.rlTexCoord2f(texcoords[i + 1].x, texcoords[i + 1].y)
		rl.rlVertex2f(points[i + 1].x + center.x, points[i + 1].y + center.y)
	end

	rl.rlEnd()

	rl.rlSetTexture(0)
end

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - polygon drawing")

-- Define texture coordinates to map our texture to poly
local texcoords = {
	rl.new("Vector2", 0.75, 0.0),
	rl.new("Vector2", 0.25, 0.0),
	rl.new("Vector2", 0.0, 0.5),
	rl.new("Vector2", 0.0, 0.75),
	rl.new("Vector2", 0.25, 1.0),
	rl.new("Vector2", 0.375, 0.875),
	rl.new("Vector2", 0.625, 0.875),
	rl.new("Vector2", 0.75, 1.0),
	rl.new("Vector2", 1.0, 0.75),
	rl.new("Vector2", 1.0, 0.5),
	rl.new("Vector2", 0.75, 0.0)                               -- Close the poly
}

-- Define the base poly vertices from the UV's
-- NOTE: They can be specified in any other way
local points = {}
for i = 1, MAX_POINTS do
	points[i] = rl.new("Vector2",
		(texcoords[i].x - 0.5) * 256.0,
		(texcoords[i].y - 0.5) * 256.0
	)
end

-- Define the vertices drawing position
-- NOTE: Initially same as points but updated every frame
local positions = {}
for i = 1, MAX_POINTS do positions[i] = points[i] end

-- Load texture to be mapped to poly
local texture = rl.LoadTexture("resources/cat.png")

local angle = 0.0                                                -- Rotation angle (in degrees)

rl.SetTargetFPS(60)                                              -- Set our game to run at 60 frames-per-second

-- Main game loop
while not rl.WindowShouldClose() do                              -- Detect window close button or ESC key
	-- Update
	-- Update points rotation with an angle transform
	-- NOTE: Base points position are not modified
	angle = angle + 1
	for i = 1, MAX_POINTS do
		positions[i] = rl.Vector2Rotate(points[i], angle * math.pi / 180.0)
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawText("textured polygon", 20, 20, 20, rl.DARKGRAY)

	DrawTexturePoly(texture, rl.new("Vector2", rl.GetScreenWidth()/2.0, rl.GetScreenHeight()/2.0),
		positions, texcoords, MAX_POINTS, rl.WHITE)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(texture)                                        -- Unload texture

rl.CloseWindow()                                                 -- Close window and OpenGL context
