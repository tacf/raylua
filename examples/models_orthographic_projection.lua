local screenWidth = 800
local screenHeight = 450

local FOVY_PERSPECTIVE = 45.0
local WIDTH_ORTHOGRAPHIC = 10.0

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - orthographic projection")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 0, 10, 10),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = FOVY_PERSPECTIVE,
	type = rl.CAMERA_PERSPECTIVE,
})

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsKeyPressed(rl.KEY_SPACE) then
		if camera.type == rl.CAMERA_PERSPECTIVE then
			camera.fovy = WIDTH_ORTHOGRAPHIC
			camera.type = rl.CAMERA_ORTHOGRAPHIC
		else
			camera.fovy = FOVY_PERSPECTIVE
			camera.type = rl.CAMERA_PERSPECTIVE
		end
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	rl.DrawCube(rl.new("Vector3", -4, 0, 2), 2, 5, 2, rl.RED)
	rl.DrawCubeWires(rl.new("Vector3", -4, 0, 2), 2, 5, 2, rl.GOLD)
	rl.DrawCubeWires(rl.new("Vector3", -4, 0, -2), 3, 6, 2, rl.MAROON)

	rl.DrawSphere(rl.new("Vector3", -1, 0, -2), 1, rl.GREEN)
	rl.DrawSphereWires(rl.new("Vector3", 1, 0, 2), 2, 16, 16, rl.LIME)

	rl.DrawCylinder(rl.new("Vector3", 4, 0, -2), 1, 2, 3, 4, rl.SKYBLUE)
	rl.DrawCylinderWires(rl.new("Vector3", 4, 0, -2), 1, 2, 3, 4, rl.DARKBLUE)
	rl.DrawCylinderWires(rl.new("Vector3", 4.5, -1, 2), 1, 1, 2, 6, rl.BROWN)

	rl.DrawCylinder(rl.new("Vector3", 1, 0, -4), 0, 1.5, 3, 8, rl.GOLD)
	rl.DrawCylinderWires(rl.new("Vector3", 1, 0, -4), 0, 1.5, 3, 8, rl.PINK)

	rl.DrawGrid(10, 1.0)

	rl.EndMode3D()

	rl.DrawText("Press Spacebar to switch camera type", 10, screenHeight - 30, 20, rl.DARKGRAY)

	if camera.type == rl.CAMERA_ORTHOGRAPHIC then
		rl.DrawText("ORTHOGRAPHIC", 10, 40, 20, rl.BLACK)
	elseif camera.type == rl.CAMERA_PERSPECTIVE then
		rl.DrawText("PERSPECTIVE", 10, 40, 20, rl.BLACK)
	end

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
