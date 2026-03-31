--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_2d_camera_split_screen.c

]]

-- raylib [core] example - 2d camera split screen

local PLAYER_SIZE = 40

local screenWidth = 800
local screenHeight = 440

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera split screen")

local player1 = rl.new("Rectangle", 200, 200, PLAYER_SIZE, PLAYER_SIZE)
local player2 = rl.new("Rectangle", 250, 200, PLAYER_SIZE, PLAYER_SIZE)

local camera1 = rl.new("Camera2D", {
	target = rl.new("Vector2", player1.x, player1.y),
	offset = rl.new("Vector2", 200, 200),
	rotation = 0,
	zoom = 1,
})

local camera2 = rl.new("Camera2D", {
	target = rl.new("Vector2", player2.x, player2.y),
	offset = rl.new("Vector2", 200, 200),
	rotation = 0,
	zoom = 1,
})

local screenCamera1 = rl.LoadRenderTexture(screenWidth / 2, screenHeight)
local screenCamera2 = rl.LoadRenderTexture(screenWidth / 2, screenHeight)

-- Build a flipped rectangle the size of the split view to use for drawing later
local splitScreenRect = rl.new("Rectangle", 0, 0, screenCamera1.texture.width, -screenCamera1.texture.height)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyDown(rl.KEY_S) then
		player1.y = player1.y + 3
	elseif rl.IsKeyDown(rl.KEY_W) then
		player1.y = player1.y - 3
	end
	if rl.IsKeyDown(rl.KEY_D) then
		player1.x = player1.x + 3
	elseif rl.IsKeyDown(rl.KEY_A) then
		player1.x = player1.x - 3
	end

	if rl.IsKeyDown(rl.KEY_UP) then
		player2.y = player2.y - 3
	elseif rl.IsKeyDown(rl.KEY_DOWN) then
		player2.y = player2.y + 3
	end
	if rl.IsKeyDown(rl.KEY_RIGHT) then
		player2.x = player2.x + 3
	elseif rl.IsKeyDown(rl.KEY_LEFT) then
		player2.x = player2.x - 3
	end

	camera1.target = rl.new("Vector2", player1.x, player1.y)
	camera2.target = rl.new("Vector2", player2.x, player2.y)

	-- Draw
	rl.BeginTextureMode(screenCamera1)
		rl.ClearBackground(rl.RAYWHITE)

		rl.BeginMode2D(camera1)
			-- Draw full scene with first camera
			for i = 0, screenWidth / PLAYER_SIZE do
				rl.DrawLineV(
					rl.new("Vector2", PLAYER_SIZE * i, 0),
					rl.new("Vector2", PLAYER_SIZE * i, screenHeight),
					rl.LIGHTGRAY)
			end

			for i = 0, screenHeight / PLAYER_SIZE do
				rl.DrawLineV(
					rl.new("Vector2", 0, PLAYER_SIZE * i),
					rl.new("Vector2", screenWidth, PLAYER_SIZE * i),
					rl.LIGHTGRAY)
			end

			for i = 0, screenWidth / PLAYER_SIZE - 1 do
				for j = 0, screenHeight / PLAYER_SIZE - 1 do
					rl.DrawText(string.format("[%d,%d]", i, j), 10 + PLAYER_SIZE * i, 15 + PLAYER_SIZE * j, 10, rl.LIGHTGRAY)
				end
			end

			rl.DrawRectangleRec(player1, rl.RED)
			rl.DrawRectangleRec(player2, rl.BLUE)
		rl.EndMode2D()

		rl.DrawRectangle(0, 0, rl.GetScreenWidth() / 2, 30, rl.Fade(rl.RAYWHITE, 0.6))
		rl.DrawText("PLAYER1: W/S/A/D to move", 10, 10, 10, rl.MAROON)
	rl.EndTextureMode()

	rl.BeginTextureMode(screenCamera2)
		rl.ClearBackground(rl.RAYWHITE)

		rl.BeginMode2D(camera2)
			-- Draw full scene with second camera
			for i = 0, screenWidth / PLAYER_SIZE do
				rl.DrawLineV(
					rl.new("Vector2", PLAYER_SIZE * i, 0),
					rl.new("Vector2", PLAYER_SIZE * i, screenHeight),
					rl.LIGHTGRAY)
			end

			for i = 0, screenHeight / PLAYER_SIZE do
				rl.DrawLineV(
					rl.new("Vector2", 0, PLAYER_SIZE * i),
					rl.new("Vector2", screenWidth, PLAYER_SIZE * i),
					rl.LIGHTGRAY)
			end

			for i = 0, screenWidth / PLAYER_SIZE - 1 do
				for j = 0, screenHeight / PLAYER_SIZE - 1 do
					rl.DrawText(string.format("[%d,%d]", i, j), 10 + PLAYER_SIZE * i, 15 + PLAYER_SIZE * j, 10, rl.LIGHTGRAY)
				end
			end

			rl.DrawRectangleRec(player1, rl.RED)
			rl.DrawRectangleRec(player2, rl.BLUE)
		rl.EndMode2D()

		rl.DrawRectangle(0, 0, rl.GetScreenWidth() / 2, 30, rl.Fade(rl.RAYWHITE, 0.6))
		rl.DrawText("PLAYER2: UP/DOWN/LEFT/RIGHT to move", 10, 10, 10, rl.DARKBLUE)
	rl.EndTextureMode()

	-- Draw both views render textures to the screen side by side
	rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		rl.DrawTextureRec(screenCamera1.texture, splitScreenRect, rl.new("Vector2", 0, 0), rl.WHITE)
		rl.DrawTextureRec(screenCamera2.texture, splitScreenRect, rl.new("Vector2", screenWidth / 2.0, 0), rl.WHITE)

		rl.DrawRectangle(rl.GetScreenWidth() / 2 - 2, 0, 4, rl.GetScreenHeight(), rl.LIGHTGRAY)
	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadRenderTexture(screenCamera1)
rl.UnloadRenderTexture(screenCamera2)
rl.CloseWindow()
