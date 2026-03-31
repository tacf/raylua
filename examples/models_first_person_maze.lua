local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - first person maze")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 0.2, 0.4, 0.2),
	target = rl.new("Vector3", 0.185, 0.4, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local imMap = rl.LoadImage("resources/cubicmap.png")
local cubicmap = rl.LoadTextureFromImage(imMap)
local mesh = rl.GenMeshCubicmap(imMap, rl.new("Vector3", 1.0, 1.0, 1.0))
local model = rl.LoadModelFromMesh(mesh)

local texture = rl.LoadTexture("resources/cubicmap_atlas.png")
model.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = texture

local mapPixels = rl.LoadImageColors(imMap)
rl.UnloadImage(imMap)

local mapPosition = rl.new("Vector3", -16.0, 0.0, -8.0)

rl.DisableCursor()

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	local oldCamPos = { x = camera.position.x, y = camera.position.y, z = camera.position.z }

	rl.UpdateCamera(camera, rl.CAMERA_FIRST_PERSON)

	local playerPos = rl.new("Vector2", camera.position.x, camera.position.z)
	local playerRadius = 0.1

	local playerCellX = math.floor(playerPos.x - mapPosition.x + 0.5)
	local playerCellY = math.floor(playerPos.y - mapPosition.z + 0.5)

	if playerCellX < 0 then playerCellX = 0
	elseif playerCellX >= cubicmap.width then playerCellX = cubicmap.width - 1 end

	if playerCellY < 0 then playerCellY = 0
	elseif playerCellY >= cubicmap.height then playerCellY = cubicmap.height - 1 end

	for y = playerCellY - 1, playerCellY + 1 do
		if y >= 0 and y < cubicmap.height then
			for x = playerCellX - 1, playerCellX + 1 do
				if x >= 0 and x < cubicmap.width then
					local pixelIndex = y * cubicmap.width + x
					if mapPixels[pixelIndex + 1].r == 255 then
						local cellRec = rl.new("Rectangle",
							mapPosition.x - 0.5 + x * 1.0,
							mapPosition.z - 0.5 + y * 1.0,
							1.0, 1.0)
						if rl.CheckCollisionCircleRec(playerPos, playerRadius, cellRec) then
							camera.position.x = oldCamPos.x
							camera.position.y = oldCamPos.y
							camera.position.z = oldCamPos.z
						end
					end
				end
			end
		end
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawModel(model, mapPosition, 1.0, rl.WHITE)
	rl.EndMode3D()

	rl.DrawTextureEx(cubicmap, rl.new("Vector2", screenWidth - cubicmap.width * 4.0 - 20, 20.0), 0.0, 4.0, rl.WHITE)
	rl.DrawRectangleLines(screenWidth - cubicmap.width * 4 - 20, 20, cubicmap.width * 4, cubicmap.height * 4, rl.GREEN)

	rl.DrawRectangle(screenWidth - cubicmap.width * 4 - 20 + playerCellX * 4, 20 + playerCellY * 4, 4, 4, rl.RED)

	rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.UnloadImageColors(mapPixels)
rl.UnloadTexture(cubicmap)
rl.UnloadTexture(texture)
rl.UnloadModel(model)

rl.CloseWindow()