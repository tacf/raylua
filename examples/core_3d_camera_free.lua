local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera free")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 10, 10, 10),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local cubePosition = rl.new("Vector3", 0, 0, 0)

rl.DisableCursor()
rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	-- Update
	rl.UpdateCamera(camera, rl.CAMERA_FREE)

	if rl.IsKeyPressed(rl.KEY_Z) then
		camera.target = rl.new("Vector3", 0, 0, 0)
	end

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	rl.DrawCube(cubePosition, 2, 2, 2, rl.RED)
	rl.DrawCubeWires(cubePosition, 2, 2, 2, rl.MAROON)

	rl.DrawGrid(10, 1)

	rl.EndMode3D()

	rl.DrawRectangle(10, 10, 320, 93, rl.Fade(rl.SKYBLUE, 0.5))
	rl.DrawRectangleLines(10, 10, 320, 93, rl.BLUE)

	rl.DrawText("Free camera default controls:", 20, 20, 10, rl.BLACK)
	rl.DrawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, rl.DARKGRAY)
	rl.DrawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, rl.DARKGRAY)
	rl.DrawText("- Z to zoom to (0, 0, 0)", 40, 80, 10, rl.DARKGRAY)

	rl.EndDrawing()
end

rl.CloseWindow()
