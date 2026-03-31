--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_3d_picking.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d picking")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 10, 10, 10),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local cubePosition = rl.new("Vector3", 0, 1, 0)
local cubeSize = rl.new("Vector3", 2, 2, 2)

local ray = rl.new("Ray", {
	position = rl.new("Vector3", 0, 0, 0),
	direction = rl.new("Vector3", 0, 0, 0),
})

local collision = rl.new("RayCollision", {
	hit = false,
	distance = 0,
	point = rl.new("Vector3", 0, 0, 0),
	normal = rl.new("Vector3", 0, 0, 0),
})

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	-- Update
	if rl.IsCursorHidden() then rl.UpdateCamera(camera, rl.CAMERA_FIRST_PERSON) end

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT) then
		if rl.IsCursorHidden() then rl.EnableCursor()
		else rl.DisableCursor()
		end
	end

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then
		if not collision.hit then
			ray = rl.GetScreenToWorldRay(rl.GetMousePosition(), camera)

			collision = rl.GetRayCollisionBox(ray, rl.new("BoundingBox", {
				min = rl.new("Vector3",
					cubePosition.x - cubeSize.x / 2,
					cubePosition.y - cubeSize.y / 2,
					cubePosition.z - cubeSize.z / 2),
				max = rl.new("Vector3",
					cubePosition.x + cubeSize.x / 2,
					cubePosition.y + cubeSize.y / 2,
					cubePosition.z + cubeSize.z / 2),
			}))
		else
			collision.hit = false
		end
	end

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	if collision.hit then
		rl.DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, rl.RED)
		rl.DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, rl.MAROON)

		rl.DrawCubeWires(cubePosition, cubeSize.x + 0.2, cubeSize.y + 0.2, cubeSize.z + 0.2, rl.GREEN)
	else
		rl.DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, rl.GRAY)
		rl.DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, rl.DARKGRAY)
	end

	rl.DrawRay(ray, rl.MAROON)
	rl.DrawGrid(10, 1)

	rl.EndMode3D()

	rl.DrawText("Try clicking on the box with your mouse!", 240, 10, 20, rl.DARKGRAY)

	if collision.hit then
		rl.DrawText("BOX SELECTED", (screenWidth - rl.MeasureText("BOX SELECTED", 30)) / 2, math.floor(screenHeight * 0.1), 30, rl.GREEN)
	end

	rl.DrawText("Right click mouse to toggle camera controls", 10, 430, 10, rl.GRAY)

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
