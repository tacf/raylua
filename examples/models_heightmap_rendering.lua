local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - heightmap rendering")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 18.0, 21.0, 18.0),
	target = rl.new("Vector3", 0.0, 0.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local image = rl.LoadImage("resources/heightmap.png")
local texture = rl.LoadTextureFromImage(image)

local mesh = rl.GenMeshHeightmap(image, rl.new("Vector3", 16, 8, 16))
local model = rl.LoadModelFromMesh(mesh)

model.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = texture
local mapPosition = rl.new("Vector3", -8.0, 0.0, -8.0)

rl.UnloadImage(image)

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawModel(model, mapPosition, 1.0, rl.RED)
	rl.DrawGrid(20, 1.0)
	rl.EndMode3D()

	rl.DrawTexture(texture, screenWidth - texture.width - 20, 20, rl.WHITE)
	rl.DrawRectangleLines(screenWidth - texture.width - 20, 20, texture.width, texture.height, rl.GREEN)

	rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.UnloadTexture(texture)
rl.UnloadModel(model)

rl.CloseWindow()