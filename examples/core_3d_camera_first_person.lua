local MAX_COLUMNS = 20

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera first person")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 0, 2, 4),
	target = rl.new("Vector3", 0, 2, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 60,
	type = rl.CAMERA_PERSPECTIVE,
})

local cameraMode = rl.CAMERA_FIRST_PERSON

local heights = {}
local positions = {}
local colors = {}

for i = 0, MAX_COLUMNS - 1 do
	heights[i] = rl.GetRandomValue(1, 12)
	positions[i] = rl.new("Vector3", rl.GetRandomValue(-15, 15), heights[i] / 2, rl.GetRandomValue(-15, 15))
	colors[i] = rl.new("Color", rl.GetRandomValue(20, 255), rl.GetRandomValue(10, 55), 30, 255)
end

rl.DisableCursor()
rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyPressed(rl.KEY_ONE) then
		cameraMode = rl.CAMERA_FREE
		camera.up = rl.new("Vector3", 0, 1, 0)
	end

	if rl.IsKeyPressed(rl.KEY_TWO) then
		cameraMode = rl.CAMERA_FIRST_PERSON
		camera.up = rl.new("Vector3", 0, 1, 0)
	end

	if rl.IsKeyPressed(rl.KEY_THREE) then
		cameraMode = rl.CAMERA_THIRD_PERSON
		camera.up = rl.new("Vector3", 0, 1, 0)
	end

	if rl.IsKeyPressed(rl.KEY_FOUR) then
		cameraMode = rl.CAMERA_ORBITAL
		camera.up = rl.new("Vector3", 0, 1, 0)
	end

	if rl.IsKeyPressed(rl.KEY_P) then
		if camera.projection == rl.CAMERA_PERSPECTIVE then
			cameraMode = rl.CAMERA_THIRD_PERSON
			camera.position = rl.new("Vector3", 0, 2, -100)
			camera.target = rl.new("Vector3", 0, 2, 0)
			camera.up = rl.new("Vector3", 0, 1, 0)
			camera.projection = rl.CAMERA_ORTHOGRAPHIC
			camera.fovy = 20
			rl.CameraYaw(camera, -135 * rl.DEG2RAD, true)
			rl.CameraPitch(camera, -45 * rl.DEG2RAD, true, true, false)
		elseif camera.projection == rl.CAMERA_ORTHOGRAPHIC then
			cameraMode = rl.CAMERA_THIRD_PERSON
			camera.position = rl.new("Vector3", 0, 2, 10)
			camera.target = rl.new("Vector3", 0, 2, 0)
			camera.up = rl.new("Vector3", 0, 1, 0)
			camera.projection = rl.CAMERA_PERSPECTIVE
			camera.fovy = 60
		end
	end

	rl.UpdateCamera(camera, cameraMode)

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	rl.DrawPlane(rl.new("Vector3", 0, 0, 0), rl.new("Vector2", 32, 32), rl.LIGHTGRAY)
	rl.DrawCube(rl.new("Vector3", -16, 2.5, 0), 1, 5, 32, rl.BLUE)
	rl.DrawCube(rl.new("Vector3", 16, 2.5, 0), 1, 5, 32, rl.LIME)
	rl.DrawCube(rl.new("Vector3", 0, 2.5, 16), 32, 5, 1, rl.GOLD)

	for i = 0, MAX_COLUMNS - 1 do
		rl.DrawCube(positions[i], 2, heights[i], 2, colors[i])
		rl.DrawCubeWires(positions[i], 2, heights[i], 2, rl.MAROON)
	end

	if cameraMode == rl.CAMERA_THIRD_PERSON then
		rl.DrawCube(camera.target, 0.5, 0.5, 0.5, rl.PURPLE)
		rl.DrawCubeWires(camera.target, 0.5, 0.5, 0.5, rl.DARKPURPLE)
	end

	rl.EndMode3D()

	rl.DrawRectangle(5, 5, 330, 100, rl.Fade(rl.SKYBLUE, 0.5))
	rl.DrawRectangleLines(5, 5, 330, 100, rl.BLUE)

	rl.DrawText("Camera controls:", 15, 15, 10, rl.BLACK)
	rl.DrawText("- Move keys: W, A, S, D, Space, Left-Ctrl", 15, 30, 10, rl.BLACK)
	rl.DrawText("- Look around: arrow keys or mouse", 15, 45, 10, rl.BLACK)
	rl.DrawText("- Camera mode keys: 1, 2, 3, 4", 15, 60, 10, rl.BLACK)
	rl.DrawText("- Zoom keys: num-plus, num-minus or mouse scroll", 15, 75, 10, rl.BLACK)
	rl.DrawText("- Camera projection key: P", 15, 90, 10, rl.BLACK)

	rl.DrawRectangle(600, 5, 195, 100, rl.Fade(rl.SKYBLUE, 0.5))
	rl.DrawRectangleLines(600, 5, 195, 100, rl.BLUE)

	local modeName = "CUSTOM"
	if cameraMode == rl.CAMERA_FREE then modeName = "FREE"
	elseif cameraMode == rl.CAMERA_FIRST_PERSON then modeName = "FIRST_PERSON"
	elseif cameraMode == rl.CAMERA_THIRD_PERSON then modeName = "THIRD_PERSON"
	elseif cameraMode == rl.CAMERA_ORBITAL then modeName = "ORBITAL"
	end

	local projName = "CUSTOM"
	if camera.projection == rl.CAMERA_PERSPECTIVE then projName = "PERSPECTIVE"
	elseif camera.projection == rl.CAMERA_ORTHOGRAPHIC then projName = "ORTHOGRAPHIC"
	end

	rl.DrawText("Camera status:", 610, 15, 10, rl.BLACK)
	rl.DrawText(string.format("- Mode: %s", modeName), 610, 30, 10, rl.BLACK)
	rl.DrawText(string.format("- Projection: %s", projName), 610, 45, 10, rl.BLACK)
	rl.DrawText(string.format("- Position: (%06.3f, %06.3f, %06.3f)", camera.position.x, camera.position.y, camera.position.z), 610, 60, 10, rl.BLACK)
	rl.DrawText(string.format("- Target: (%06.3f, %06.3f, %06.3f)", camera.target.x, camera.target.y, camera.target.z), 610, 75, 10, rl.BLACK)
	rl.DrawText(string.format("- Up: (%06.3f, %06.3f, %06.3f)", camera.up.x, camera.up.y, camera.up.z), 610, 90, 10, rl.BLACK)

	rl.EndDrawing()
end

rl.CloseWindow()
