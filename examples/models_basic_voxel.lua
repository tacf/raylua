local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - basic voxel")

rl.DisableCursor()

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", -2.0, 0.0, -2.0),
	target = rl.new("Vector3", 0.0, 0.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local cubeMesh = rl.GenMeshCube(1.0, 1.0, 1.0)
local cubeModel = rl.LoadModelFromMesh(cubeMesh)
cubeModel.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].color = rl.BEIGE

local WORLD_SIZE = 8
local voxels = {}
for x = 1, WORLD_SIZE do
	voxels[x] = {}
	for y = 1, WORLD_SIZE do
		voxels[x][y] = {}
		for z = 1, WORLD_SIZE do
			voxels[x][y][z] = true
		end
	end
end

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_FIRST_PERSON)

	if rl.IsMouseButtonPressed(rl.MOUSE_LEFT_BUTTON) then
		local screenCenter = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0)
		local ray = rl.GetMouseRay(screenCenter, camera)

		local closestDistance = 99999.0
		local closestVoxelPosition = rl.new("Vector3", -1, -1, -1)
		local voxelFound = false

		for x = 1, WORLD_SIZE do
			for y = 1, WORLD_SIZE do
				for z = 1, WORLD_SIZE do
					if not voxels[x][y][z] then end

					local position = rl.new("Vector3", x - 1, y - 1, z - 1)
					local box = rl.new("BoundingBox", {
						min = rl.new("Vector3", position.x - 0.5, position.y - 0.5, position.z - 0.5),
						max = rl.new("Vector3", position.x + 0.5, position.y + 0.5, position.z + 0.5)
					})

					local collision = rl.GetRayCollisionBox(ray, box)
					if collision.hit and collision.distance < closestDistance then
						closestDistance = collision.distance
						closestVoxelPosition = rl.new("Vector3", x - 1, y - 1, z - 1)
						voxelFound = true
					end
				end
			end
		end

		if voxelFound then
			voxels[math.floor(closestVoxelPosition.x) + 1][math.floor(closestVoxelPosition.y) + 1][math.floor(closestVoxelPosition.z) + 1] = false
		end
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawGrid(10, 1.0)

	for x = 1, WORLD_SIZE do
		for y = 1, WORLD_SIZE do
			for z = 1, WORLD_SIZE do
				if voxels[x][y][z] then
					local position = rl.new("Vector3", x - 1, y - 1, z - 1)
					rl.DrawModel(cubeModel, position, 1.0, rl.BEIGE)
					rl.DrawCubeWires(position, 1.0, 1.0, 1.0, rl.BLACK)
				end
			end
		end
	end

	rl.EndMode3D()

	rl.DrawCircle(screenWidth / 2, screenHeight / 2, 4, rl.RED)
	rl.DrawText("Left-click a voxel to remove it!", 10, 10, 20, rl.DARKGRAY)
	rl.DrawText("WASD to move, mouse to look around", 10, 35, 10, rl.GRAY)

	rl.EndDrawing()
end

rl.UnloadModel(cubeModel)

rl.CloseWindow()