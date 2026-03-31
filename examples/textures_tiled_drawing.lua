--[[
	raylib [textures] example - tiled drawing

	Example complexity rating: [★★★☆] 3/4

	Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
	BSD-like license that allows static linking with closed source software

	Copyright (c) 2020-2025 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
]]

local OPT_WIDTH = 220
local MARGIN_SIZE = 8
local COLOR_SIZE = 16

-- Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest
local function DrawTextureTiled(texture, source, dest, origin, rotation, scale, tint)
	if scale <= 0.0 then return end
	if source.width == 0 or source.height == 0 then return end

	local tileWidth = math.floor(source.width * scale)
	local tileHeight = math.floor(source.height * scale)

	if dest.width < tileWidth and dest.height < tileHeight then
		rl.DrawTexturePro(texture,
			rl.new("Rectangle", source.x, source.y, (dest.width / tileWidth) * source.width, (dest.height / tileHeight) * source.height),
			rl.new("Rectangle", dest.x, dest.y, dest.width, dest.height),
			origin, rotation, tint)
	elseif dest.width <= tileWidth then
		-- Tiled vertically (one column)
		local dy = 0
		while dy + tileHeight < dest.height do
			rl.DrawTexturePro(texture,
				rl.new("Rectangle", source.x, source.y, (dest.width / tileWidth) * source.width, source.height),
				rl.new("Rectangle", dest.x, dest.y + dy, dest.width, tileHeight),
				origin, rotation, tint)
			dy = dy + tileHeight
		end

		if dy < dest.height then
			rl.DrawTexturePro(texture,
				rl.new("Rectangle", source.x, source.y, (dest.width / tileWidth) * source.width, ((dest.height - dy) / tileHeight) * source.height),
				rl.new("Rectangle", dest.x, dest.y + dy, dest.width, dest.height - dy),
				origin, rotation, tint)
		end
	elseif dest.height <= tileHeight then
		-- Tiled horizontally (one row)
		local dx = 0
		while dx + tileWidth < dest.width do
			rl.DrawTexturePro(texture,
				rl.new("Rectangle", source.x, source.y, source.width, (dest.height / tileHeight) * source.height),
				rl.new("Rectangle", dest.x + dx, dest.y, tileWidth, dest.height),
				origin, rotation, tint)
			dx = dx + tileWidth
		end

		if dx < dest.width then
			rl.DrawTexturePro(texture,
				rl.new("Rectangle", source.x, source.y, ((dest.width - dx) / tileWidth) * source.width, (dest.height / tileHeight) * source.height),
				rl.new("Rectangle", dest.x + dx, dest.y, dest.width - dx, dest.height),
				origin, rotation, tint)
		end
	else
		-- Tiled both horizontally and vertically
		local dx = 0
		while dx + tileWidth < dest.width do
			local dy = 0
			while dy + tileHeight < dest.height do
				rl.DrawTexturePro(texture, source,
					rl.new("Rectangle", dest.x + dx, dest.y + dy, tileWidth, tileHeight),
					origin, rotation, tint)
				dy = dy + tileHeight
			end

			if dy < dest.height then
				rl.DrawTexturePro(texture,
					rl.new("Rectangle", source.x, source.y, source.width, ((dest.height - dy) / tileHeight) * source.height),
					rl.new("Rectangle", dest.x + dx, dest.y + dy, tileWidth, dest.height - dy),
					origin, rotation, tint)
			end
			dx = dx + tileWidth
		end

		-- Fit last column of tiles
		if dx < dest.width then
			local dy = 0
			while dy + tileHeight < dest.height do
				rl.DrawTexturePro(texture,
					rl.new("Rectangle", source.x, source.y, ((dest.width - dx) / tileWidth) * source.width, source.height),
					rl.new("Rectangle", dest.x + dx, dest.y + dy, dest.width - dx, tileHeight),
					origin, rotation, tint)
				dy = dy + tileHeight
			end

			if dy < dest.height then
				rl.DrawTexturePro(texture,
					rl.new("Rectangle", source.x, source.y, ((dest.width - dx) / tileWidth) * source.width, ((dest.height - dy) / tileHeight) * source.height),
					rl.new("Rectangle", dest.x + dx, dest.y + dy, dest.width - dx, dest.height - dy),
					origin, rotation, tint)
			end
		end
	end
end

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE)
rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - tiled drawing")

local texPattern = rl.LoadTexture("resources/patterns.png")
rl.SetTextureFilter(texPattern, rl.TEXTURE_FILTER_BILINEAR)

-- Coordinates for all patterns inside the texture
local recPattern = {
	{ x = 3, y = 3, width = 66, height = 66 },
	{ x = 75, y = 3, width = 100, height = 100 },
	{ x = 3, y = 75, width = 66, height = 66 },
	{ x = 7, y = 156, width = 50, height = 50 },
	{ x = 85, y = 106, width = 90, height = 45 },
	{ x = 75, y = 154, width = 100, height = 60 },
}

-- Setup colors
local colors = { rl.BLACK, rl.MAROON, rl.ORANGE, rl.BLUE, rl.PURPLE, rl.BEIGE, rl.LIME, rl.RED, rl.DARKGRAY, rl.SKYBLUE }
local MAX_COLORS = #colors
local colorRec = {}

-- Calculate rectangle for each color
local x, y = 0, 0
for i = 1, MAX_COLORS do
	colorRec[i] = rl.new("Rectangle",
		2.0 + MARGIN_SIZE + x,
		22.0 + 256.0 + MARGIN_SIZE + y,
		COLOR_SIZE * 2.0,
		COLOR_SIZE
	)

	if i == math.floor(MAX_COLORS / 2) then
		x = 0
		y = y + COLOR_SIZE + MARGIN_SIZE
	else
		x = x + (COLOR_SIZE * 2 + MARGIN_SIZE)
	end
end

local activePattern = 1
local activeCol = 1
local scale = 1.0
local rotation = 0.0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then
		local mouse = rl.GetMousePosition()

		for i = 1, #recPattern do
			local rp = recPattern[i]
			if rl.CheckCollisionPointRec(mouse, rl.new("Rectangle", 2 + MARGIN_SIZE + rp.x, 40 + MARGIN_SIZE + rp.y, rp.width, rp.height)) then
				activePattern = i
				break
			end
		end

		for i = 1, MAX_COLORS do
			if rl.CheckCollisionPointRec(mouse, colorRec[i]) then
				activeCol = i
				break
			end
		end
	end

	if rl.IsKeyPressed(rl.KEY_UP) then scale = scale + 0.25 end
	if rl.IsKeyPressed(rl.KEY_DOWN) then scale = scale - 0.25 end
	if scale > 10.0 then scale = 10.0 end
	if scale <= 0.0 then scale = 0.25 end

	if rl.IsKeyPressed(rl.KEY_LEFT) then rotation = rotation - 25.0 end
	if rl.IsKeyPressed(rl.KEY_RIGHT) then rotation = rotation + 25.0 end

	if rl.IsKeyPressed(rl.KEY_SPACE) then
		rotation = 0.0
		scale = 1.0
	end

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	local rp = recPattern[activePattern]
	DrawTextureTiled(texPattern,
		rl.new("Rectangle", rp.x, rp.y, rp.width, rp.height),
		rl.new("Rectangle", OPT_WIDTH + MARGIN_SIZE, MARGIN_SIZE, rl.GetScreenWidth() - OPT_WIDTH - 2 * MARGIN_SIZE, rl.GetScreenHeight() - 2 * MARGIN_SIZE),
		rl.rlVertex2f(0.0, 0.0), rotation, scale, colors[activeCol])

	-- Draw options
	rl.DrawRectangle(MARGIN_SIZE, MARGIN_SIZE, OPT_WIDTH - MARGIN_SIZE, rl.GetScreenHeight() - 2 * MARGIN_SIZE, rl.Fade(rl.LIGHTGRAY, 0.5))

	rl.DrawText("Select Pattern", 2 + MARGIN_SIZE, 30 + MARGIN_SIZE, 10, rl.BLACK)
	rl.DrawTexture(texPattern, 2 + MARGIN_SIZE, 40 + MARGIN_SIZE, rl.BLACK)
	rl.DrawRectangle(2 + MARGIN_SIZE + rp.x, 40 + MARGIN_SIZE + rp.y, rp.width, rp.height, rl.Fade(rl.DARKBLUE, 0.3))

	rl.DrawText("Select Color", 2 + MARGIN_SIZE, 10 + 256 + MARGIN_SIZE, 10, rl.BLACK)
	for i = 1, MAX_COLORS do
		rl.DrawRectangleRec(colorRec[i], colors[i])
		if activeCol == i then
			rl.DrawRectangleLinesEx(colorRec[i], 3, rl.Fade(rl.WHITE, 0.5))
		end
	end

	rl.DrawText("Scale (UP/DOWN to change)", 2 + MARGIN_SIZE, 80 + 256 + MARGIN_SIZE, 10, rl.BLACK)
	rl.DrawText(string.format("%.2fx", scale), 2 + MARGIN_SIZE, 92 + 256 + MARGIN_SIZE, 20, rl.BLACK)

	rl.DrawText("Rotation (LEFT/RIGHT to change)", 2 + MARGIN_SIZE, 122 + 256 + MARGIN_SIZE, 10, rl.BLACK)
	rl.DrawText(string.format("%.0f degrees", rotation), 2 + MARGIN_SIZE, 134 + 256 + MARGIN_SIZE, 20, rl.BLACK)

	rl.DrawText("Press [SPACE] to reset", 2 + MARGIN_SIZE, 164 + 256 + MARGIN_SIZE, 10, rl.DARKBLUE)

	rl.DrawFPS(2 + MARGIN_SIZE, 2 + MARGIN_SIZE)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadTexture(texPattern)

rl.CloseWindow()
