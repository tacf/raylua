--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/models/models_rotating_cube.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - rotating cube")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 0, 3, 3),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local model = rl.LoadModelFromMesh(rl.GenMeshCube(1, 1, 1))
local img = rl.LoadImage("raylib/examples/models/resources/cubicmap_atlas.png")
local crop = rl.ImageFromImage(img, rl.new("Rectangle", 0, img.height / 2.0, img.width / 2.0, img.height / 2.0))
local texture = rl.LoadTextureFromImage(crop)
rl.UnloadImage(img)
rl.UnloadImage(crop)

model.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = texture

local rotation = 0.0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rotation = rotation + 1.0

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	rl.DrawModelEx(model, rl.new("Vector3", 0, 0, 0), rl.new("Vector3", 0.5, 1.0, 0.0),
		rotation, rl.new("Vector3", 1, 1, 1), rl.WHITE)

	rl.DrawGrid(10, 1.0)

	rl.EndMode3D()

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.UnloadTexture(texture)
rl.UnloadModel(model)
rl.CloseWindow()
