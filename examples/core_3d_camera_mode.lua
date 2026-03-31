local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera mode")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 0, 10, 10),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local cubePosition = rl.new("Vector3", 0, 0, 0)

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	rl.DrawCube(cubePosition, 2, 2, 2, rl.RED)
	rl.DrawCubeWires(cubePosition, 2, 2, 2, rl.MAROON)

	rl.DrawGrid(10, 1)

	rl.EndMode3D()

	rl.DrawText("Welcome to the third dimension!", 10, 40, 20, rl.DARKGRAY)

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
