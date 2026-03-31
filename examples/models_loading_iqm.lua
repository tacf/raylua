local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - loading iqm")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 10.0, 10.0, 10.0),
	target = rl.new("Vector3", 0.0, 4.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local model = rl.LoadModel("resources/models/iqm/guy.iqm")
local texture = rl.LoadTexture("resources/models/iqm/guytex.png")
rl.SetMaterialTexture(model.materials[0], rl.MATERIAL_MAP_DIFFUSE, texture)
local position = rl.new("Vector3", 0.0, 0.0, 0.0)

local animCount = 0
local anims = rl.LoadModelAnimations("resources/models/iqm/guyanim.iqm", animCount)

local animIndex = 0
local animCurrentFrame = 0.0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	animCurrentFrame = animCurrentFrame + 1.0
	rl.UpdateModelAnimation(model, anims[0], animCurrentFrame)
	if animCurrentFrame >= anims[0].keyframeCount then
		animCurrentFrame = 0
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawModelEx(model, position, rl.new("Vector3", 1.0, 0.0, 0.0), -90.0, rl.new("Vector3", 1.0, 1.0, 1.0), rl.WHITE)
	rl.DrawGrid(10, 1.0)
	rl.EndMode3D()

	rl.DrawText(string.format("Current animation: %s", anims[animIndex].name), 10, 10, 20, rl.MAROON)
	rl.DrawText("(c) Guy IQM 3D model by @culacant", screenWidth - 200, screenHeight - 20, 10, rl.GRAY)

	rl.EndDrawing()
end

rl.UnloadTexture(texture)
rl.UnloadModelAnimations(anims, animCount)
rl.UnloadModel(model)

rl.CloseWindow()