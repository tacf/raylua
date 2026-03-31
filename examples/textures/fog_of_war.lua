--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/textures/textures_fog_of_war.c

]]

local MAP_TILE_SIZE = 32
local PLAYER_SIZE = 16
local PLAYER_TILE_VISIBILITY = 2

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - fog of war")
rl.SetTargetFPS(60)

local tilesX = 25
local tilesY = 15

local tileIds = {}
local tileFog = {}
for i = 1, tilesX * tilesY do
	tileIds[i] = rl.GetRandomValue(0, 1)
	tileFog[i] = 0
end

local playerPosition = { x = 180, y = 130 }
local playerTileX = 0
local playerTileY = 0

local fogOfWar = rl.LoadRenderTexture(tilesX, tilesY)
rl.SetTextureFilter(fogOfWar.texture, rl.TEXTURE_FILTER_BILINEAR)
rl.SetTextureWrap(fogOfWar.texture, rl.TEXTURE_WRAP_CLAMP)

while not rl.WindowShouldClose() do
	if rl.IsKeyDown(rl.KEY_RIGHT) then playerPosition.x = playerPosition.x + 5 end
	if rl.IsKeyDown(rl.KEY_LEFT) then playerPosition.x = playerPosition.x - 5 end
	if rl.IsKeyDown(rl.KEY_DOWN) then playerPosition.y = playerPosition.y + 5 end
	if rl.IsKeyDown(rl.KEY_UP) then playerPosition.y = playerPosition.y - 5 end

	if playerPosition.x < 0 then playerPosition.x = 0
	elseif (playerPosition.x + PLAYER_SIZE) > (tilesX * MAP_TILE_SIZE) then playerPosition.x = tilesX * MAP_TILE_SIZE - PLAYER_SIZE
	end
	if playerPosition.y < 0 then playerPosition.y = 0
	elseif (playerPosition.y + PLAYER_SIZE) > (tilesY * MAP_TILE_SIZE) then playerPosition.y = tilesY * MAP_TILE_SIZE - PLAYER_SIZE
	end

	for i = 1, tilesX * tilesY do
		if tileFog[i] == 1 then tileFog[i] = 2 end
	end

	playerTileX = math.floor((playerPosition.x + MAP_TILE_SIZE / 2) / MAP_TILE_SIZE)
	playerTileY = math.floor((playerPosition.y + MAP_TILE_SIZE / 2) / MAP_TILE_SIZE)

	for y = playerTileY - PLAYER_TILE_VISIBILITY, playerTileY + PLAYER_TILE_VISIBILITY do
		for x = playerTileX - PLAYER_TILE_VISIBILITY, playerTileX + PLAYER_TILE_VISIBILITY do
			if (x >= 0) and (x < tilesX) and (y >= 0) and (y < tilesY) then
				tileFog[y * tilesX + x + 1] = 1
			end
		end
	end

	rl.BeginTextureMode(fogOfWar)
	rl.ClearBackground(rl.BLANK)
	for y = 0, tilesY - 1 do
		for x = 0, tilesX - 1 do
			local idx = y * tilesX + x + 1
			if tileFog[idx] == 0 then
				rl.DrawRectangle(x, y, 1, 1, rl.BLACK)
			elseif tileFog[idx] == 2 then
				rl.DrawRectangle(x, y, 1, 1, rl.Fade(rl.BLACK, 0.8))
			end
		end
	end
	rl.EndTextureMode()

	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	for y = 0, tilesY - 1 do
		for x = 0, tilesX - 1 do
			local idx = y * tilesX + x + 1
			local color = nil
			if tileIds[idx] == 0 then
				color = rl.BLUE
			else
				color = rl.Fade(rl.BLUE, 0.9)
			end
			rl.DrawRectangle(x * MAP_TILE_SIZE, y * MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE, color)
			rl.DrawRectangleLines(x * MAP_TILE_SIZE, y * MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE, rl.Fade(rl.DARKBLUE, 0.5))
		end
	end

	rl.DrawRectangleV(rl.new("Vector2", playerPosition.x, playerPosition.y), rl.new("Vector2", PLAYER_SIZE, PLAYER_SIZE), rl.RED)

	rl.DrawTexturePro(fogOfWar.texture,
		rl.new("Rectangle", 0, 0, fogOfWar.texture.width, -fogOfWar.texture.height),
		rl.new("Rectangle", 0, 0, tilesX * MAP_TILE_SIZE, tilesY * MAP_TILE_SIZE),
		rl.new("Vector2", 0, 0), 0.0, rl.WHITE)

	rl.DrawText("Current tile: [" .. tostring(playerTileX) .. "," .. tostring(playerTileY) .. "]", 10, 10, 20, rl.RAYWHITE)
	rl.DrawText("ARROW KEYS to move", 10, screenHeight - 25, 20, rl.RAYWHITE)

	rl.EndDrawing()
end

rl.UnloadRenderTexture(fogOfWar)

rl.CloseWindow()