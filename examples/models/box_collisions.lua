--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/models/models_box_collisions.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - box collisions")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 0.0, 10.0, 10.0),
	target = rl.new("Vector3", 0.0, 0.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local playerPosition = rl.new("Vector3", 0.0, 1.0, 2.0)
local playerSize = rl.new("Vector3", 1.0, 2.0, 1.0)
local playerColor = rl.GREEN

local enemyBoxPos = rl.new("Vector3", -4.0, 1.0, 0.0)
local enemyBoxSize = rl.new("Vector3", 2.0, 2.0, 2.0)

local enemySpherePos = rl.new("Vector3", 4.0, 0.0, 0.0)
local enemySphereSize = 1.5

local collision = false

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsKeyDown(rl.KEY_RIGHT) then
		playerPosition.x = playerPosition.x + 0.2
	elseif rl.IsKeyDown(rl.KEY_LEFT) then
		playerPosition.x = playerPosition.x - 0.2
	elseif rl.IsKeyDown(rl.KEY_DOWN) then
		playerPosition.z = playerPosition.z + 0.2
	elseif rl.IsKeyDown(rl.KEY_UP) then
		playerPosition.z = playerPosition.z - 0.2
	end

	collision = false

	local playerBox = rl.new("BoundingBox", {
		min = rl.new("Vector3", playerPosition.x - playerSize.x / 2, playerPosition.y - playerSize.y / 2, playerPosition.z - playerSize.z / 2),
		max = rl.new("Vector3", playerPosition.x + playerSize.x / 2, playerPosition.y + playerSize.y / 2, playerPosition.z + playerSize.z / 2)
	})
	local enemyBox = rl.new("BoundingBox", {
		min = rl.new("Vector3", enemyBoxPos.x - enemyBoxSize.x / 2, enemyBoxPos.y - enemyBoxSize.y / 2, enemyBoxPos.z - enemyBoxSize.z / 2),
		max = rl.new("Vector3", enemyBoxPos.x + enemyBoxSize.x / 2, enemyBoxPos.y + enemyBoxSize.y / 2, enemyBoxPos.z + enemyBoxSize.z / 2)
	})

	if rl.CheckCollisionBoxes(playerBox, enemyBox) then
		collision = true
	end

	if rl.CheckCollisionBoxSphere(playerBox, enemySpherePos, enemySphereSize) then
		collision = true
	end

	if collision then
		playerColor = rl.RED
	else
		playerColor = rl.GREEN
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawCube(enemyBoxPos, enemyBoxSize.x, enemyBoxSize.y, enemyBoxSize.z, rl.GRAY)
	rl.DrawCubeWires(enemyBoxPos, enemyBoxSize.x, enemyBoxSize.y, enemyBoxSize.z, rl.DARKGRAY)
	rl.DrawSphere(enemySpherePos, enemySphereSize, rl.GRAY)
	rl.DrawSphereWires(enemySpherePos, enemySphereSize, 16, 16, rl.DARKGRAY)
	rl.DrawCubeV(playerPosition, playerSize, playerColor)
	rl.DrawGrid(10, 1.0)
	rl.EndMode3D()

	rl.DrawText("Move player with arrow keys to collide", 220, 40, 20, rl.GRAY)
	rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.CloseWindow()