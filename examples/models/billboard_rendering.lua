--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/models/models_billboard_rendering.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - billboard rendering")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 5.0, 4.0, 5.0),
	target = rl.new("Vector3", 0.0, 2.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local bill = rl.LoadTexture("resources/billboard.png")
local billPositionStatic = rl.new("Vector3", 0.0, 2.0, 0.0)
local billPositionRotating = rl.new("Vector3", 1.0, 2.0, 1.0)

local source = rl.new("Rectangle", 0, 0, bill.width, bill.height)

local billUp = rl.new("Vector3", 0.0, 1.0, 0.0)

local size = rl.new("Vector2", source.width / source.height, 1.0)

local origin = rl.Vector2Scale(size, 0.5)

local distanceStatic
local distanceRotating
local rotation = 0.0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	rotation = rotation + 0.4
	distanceStatic = rl.Vector3Distance(camera.position, billPositionStatic)
	distanceRotating = rl.Vector3Distance(camera.position, billPositionRotating)

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawGrid(10, 1.0)

	if distanceStatic > distanceRotating then
		rl.DrawBillboard(camera, bill, billPositionStatic, 2.0, rl.WHITE)
		rl.DrawBillboardPro(camera, bill, source, billPositionRotating, billUp, size, origin, rotation, rl.WHITE)
	else
		rl.DrawBillboardPro(camera, bill, source, billPositionRotating, billUp, size, origin, rotation, rl.WHITE)
		rl.DrawBillboard(camera, bill, billPositionStatic, 2.0, rl.WHITE)
	end

	rl.EndMode3D()

	rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.UnloadTexture(bill)

rl.CloseWindow()