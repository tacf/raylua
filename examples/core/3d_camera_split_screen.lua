--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_3d_camera_split_screen.c

]]

-- raylib [core] example - 3d camera split screen

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera split screen")

-- Setup player 1 camera and screen
local cameraPlayer1 = rl.new("Camera3D", {
	position = { 0, 1, -3 },
	target = { 0, 1, 0 },
	up = { 0, 1, 0 },
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE
})

local screenPlayer1 = rl.LoadRenderTexture(screenWidth / 2, screenHeight)

-- Setup player 2 camera and screen
local cameraPlayer2 = rl.new("Camera3D", {
	position = { -3, 3, 0 },
	target = { 0, 3, 0 },
	up = { 0, 1, 0 },
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE
})

local screenPlayer2 = rl.LoadRenderTexture(screenWidth / 2, screenHeight)

-- Build a flipped rectangle the size of the split view to use for drawing later
local splitScreenRect = rl.new("Rectangle", 0, 0, screenPlayer1.texture.width, -screenPlayer1.texture.height)

-- Grid data
local count = 5
local spacing = 4

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- If anyone moves this frame, how far will they move based on the time since the last frame
	local offsetThisFrame = 10.0 * rl.GetFrameTime()

	-- Move Player1 forward and backwards (no turning)
	if rl.IsKeyDown(rl.KEY_W) then
		cameraPlayer1.position.z = cameraPlayer1.position.z + offsetThisFrame
		cameraPlayer1.target.z = cameraPlayer1.target.z + offsetThisFrame
	elseif rl.IsKeyDown(rl.KEY_S) then
		cameraPlayer1.position.z = cameraPlayer1.position.z - offsetThisFrame
		cameraPlayer1.target.z = cameraPlayer1.target.z - offsetThisFrame
	end

	-- Move Player2 forward and backwards (no turning)
	if rl.IsKeyDown(rl.KEY_UP) then
		cameraPlayer2.position.x = cameraPlayer2.position.x + offsetThisFrame
		cameraPlayer2.target.x = cameraPlayer2.target.x + offsetThisFrame
	elseif rl.IsKeyDown(rl.KEY_DOWN) then
		cameraPlayer2.position.x = cameraPlayer2.position.x - offsetThisFrame
		cameraPlayer2.target.x = cameraPlayer2.target.x - offsetThisFrame
	end

	-- Draw Player1 view to the render texture
	rl.BeginTextureMode(screenPlayer1)
		rl.ClearBackground(rl.SKYBLUE)

		rl.BeginMode3D(cameraPlayer1)
			-- Draw scene: grid of cube trees on a plane to make a "world"
			rl.DrawPlane(rl.new("Vector3", 0, 0, 0), rl.new("Vector2", 50, 50), rl.BEIGE)

			for x = -count * spacing, count * spacing, spacing do
				for z = -count * spacing, count * spacing, spacing do
					rl.DrawCube(rl.new("Vector3", x, 1.5, z), 1, 1, 1, rl.LIME)
					rl.DrawCube(rl.new("Vector3", x, 0.5, z), 0.25, 1, 0.25, rl.BROWN)
				end
			end

			-- Draw a cube at each player's position
			rl.DrawCube(cameraPlayer1.position, 1, 1, 1, rl.RED)
			rl.DrawCube(cameraPlayer2.position, 1, 1, 1, rl.BLUE)
		rl.EndMode3D()

		rl.DrawRectangle(0, 0, rl.GetScreenWidth() / 2, 40, rl.Fade(rl.RAYWHITE, 0.8))
		rl.DrawText("PLAYER1: W/S to move", 10, 10, 20, rl.MAROON)
	rl.EndTextureMode()

	-- Draw Player2 view to the render texture
	rl.BeginTextureMode(screenPlayer2)
		rl.ClearBackground(rl.SKYBLUE)

		rl.BeginMode3D(cameraPlayer2)
			-- Draw scene: grid of cube trees on a plane to make a "world"
			rl.DrawPlane(rl.new("Vector3", 0, 0, 0), rl.new("Vector2", 50, 50), rl.BEIGE)

			for x = -count * spacing, count * spacing, spacing do
				for z = -count * spacing, count * spacing, spacing do
					rl.DrawCube(rl.new("Vector3", x, 1.5, z), 1, 1, 1, rl.LIME)
					rl.DrawCube(rl.new("Vector3", x, 0.5, z), 0.25, 1, 0.25, rl.BROWN)
				end
			end

			-- Draw a cube at each player's position
			rl.DrawCube(cameraPlayer1.position, 1, 1, 1, rl.RED)
			rl.DrawCube(cameraPlayer2.position, 1, 1, 1, rl.BLUE)
		rl.EndMode3D()

		rl.DrawRectangle(0, 0, rl.GetScreenWidth() / 2, 40, rl.Fade(rl.RAYWHITE, 0.8))
		rl.DrawText("PLAYER2: UP/DOWN to move", 10, 10, 20, rl.DARKBLUE)
	rl.EndTextureMode()

	-- Draw both views render textures to the screen side by side
	rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		rl.DrawTextureRec(screenPlayer1.texture, splitScreenRect, rl.new("Vector2", 0, 0), rl.WHITE)
		rl.DrawTextureRec(screenPlayer2.texture, splitScreenRect, rl.new("Vector2", screenWidth / 2.0, 0), rl.WHITE)

		rl.DrawRectangle(rl.GetScreenWidth() / 2 - 2, 0, 4, rl.GetScreenHeight(), rl.LIGHTGRAY)
	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadRenderTexture(screenPlayer1)
rl.UnloadRenderTexture(screenPlayer2)
rl.CloseWindow()
