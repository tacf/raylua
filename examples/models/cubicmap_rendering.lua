--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/models/models_cubicmap_rendering.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - cubicmap rendering")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 16.0, 14.0, 16.0),
	target = rl.new("Vector3", 0.0, 0.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local image = rl.LoadImage("resources/cubicmap.png")
local cubicmap = rl.LoadTextureFromImage(image)

local mesh = rl.GenMeshCubicmap(image, rl.new("Vector3", 1.0, 1.0, 1.0))
local model = rl.LoadModelFromMesh(mesh)

local texture = rl.LoadTexture("resources/cubicmap_atlas.png")
model.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = texture

local mapPosition = rl.new("Vector3", -16.0, 0.0, -8.0)

rl.UnloadImage(image)

local pause = false

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsKeyPressed(rl.KEY_P) then
		pause = not pause
	end

	if not pause then
		rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawModel(model, mapPosition, 1.0, rl.WHITE)
	rl.EndMode3D()

	rl.DrawTextureEx(cubicmap, rl.new("Vector2", screenWidth - cubicmap.width * 4.0 - 20, 20.0), 0.0, 4.0, rl.WHITE)
	rl.DrawRectangleLines(screenWidth - cubicmap.width * 4 - 20, 20, cubicmap.width * 4, cubicmap.height * 4, rl.GREEN)

	rl.DrawText("cubicmap image used to", 658, 90, 10, rl.GRAY)
	rl.DrawText("generate map 3d model", 658, 104, 10, rl.GRAY)

	rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.UnloadTexture(cubicmap)
rl.UnloadTexture(texture)
rl.UnloadModel(model)

rl.CloseWindow()