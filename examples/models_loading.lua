local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - loading")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 50.0, 50.0, 50.0),
	target = rl.new("Vector3", 0.0, 12.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local model = rl.LoadModel("resources/models/obj/castle.obj")
local texture = rl.LoadTexture("resources/models/obj/castle_diffuse.png")
model.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = texture

local position = rl.new("Vector3", 0.0, 0.0, 0.0)

local bounds = rl.GetMeshBoundingBox(model.meshes[0])

local selected = false

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	if rl.IsFileDropped() then
		local droppedFiles = rl.LoadDroppedFiles()

		if droppedFiles.count == 1 then
			local path = droppedFiles.paths[0]
			local ext = path:match("%.%w+$"):lower()

			if ext == ".obj" or ext == ".gltf" or ext == ".glb" or ext == ".vox" or ext == ".iqm" or ext == ".m3d" then
				rl.UnloadModel(model)
				model = rl.LoadModel(path)
				model.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = texture

				bounds = rl.GetMeshBoundingBox(model.meshes[0])

				camera.position.x = bounds.max.x + 10.0
				camera.position.y = bounds.max.y + 10.0
				camera.position.z = bounds.max.z + 10.0
			elseif ext == ".png" then
				rl.UnloadTexture(texture)
				texture = rl.LoadTexture(path)
				model.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = texture
			end
		end

		rl.UnloadDroppedFiles(droppedFiles)
	end

	if rl.IsMouseButtonPressed(rl.MOUSE_LEFT_BUTTON) then
		local ray = rl.GetScreenToWorldRay(rl.GetMousePosition(), camera)
		local collision = rl.GetRayCollisionBox(ray, bounds)
		if collision.hit then
			selected = not selected
		else
			selected = false
		end
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawModel(model, position, 1.0, rl.WHITE)
	rl.DrawGrid(20, 10.0)

	if selected then
		rl.DrawBoundingBox(bounds, rl.GREEN)
	end

	rl.EndMode3D()

	rl.DrawText("Drag & drop model to load mesh/texture.", 10, screenHeight - 20, 10, rl.DARKGRAY)
	if selected then
		rl.DrawText("MODEL SELECTED", screenWidth - 110, 10, 10, rl.GREEN)
	end

	rl.DrawText("(c) Castle 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, rl.GRAY)

	rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.UnloadTexture(texture)
rl.UnloadModel(model)

rl.CloseWindow()