-- raylib [core] example - world screen

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - world screen")

-- Define the camera to look into our 3d world
local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 10.0, 10.0, 10.0),
	target = rl.new("Vector3", 0.0, 0.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE,
})

local cubePosition = rl.new("Vector3", 0.0, 0.0, 0.0)
local cubeScreenPosition = rl.new("Vector2", 0.0, 0.0)

rl.DisableCursor()

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	rl.UpdateCamera(camera, rl.CAMERA_THIRD_PERSON)

	-- Calculate cube screen space position (with a little offset to be in top)
	cubeScreenPosition = rl.GetWorldToScreen(rl.new("Vector3", cubePosition.x, cubePosition.y + 2.5, cubePosition.z), camera)

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawCube(cubePosition, 2.0, 2.0, 2.0, rl.RED)
	rl.DrawCubeWires(cubePosition, 2.0, 2.0, 2.0, rl.MAROON)
	rl.DrawGrid(10, 1.0)
	rl.EndMode3D()

	rl.DrawText("Enemy: 100/100", cubeScreenPosition.x - rl.MeasureText("Enemy: 100/100", 20) / 2, cubeScreenPosition.y, 20, rl.BLACK)

	rl.DrawText(string.format("Cube position in screen space coordinates: [%i, %i]", cubeScreenPosition.x, cubeScreenPosition.y), 10, 10, 20, rl.LIME)
	rl.DrawText("Text 2d should be always on top of the cube", 10, 40, 20, rl.GRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
