--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/models/models_loading_gltf.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - loading gltf")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 6.0, 6.0, 6.0),
	target = rl.new("Vector3", 0.0, 2.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local model = rl.LoadModel("resources/models/gltf/robot.glb")
local position = rl.new("Vector3", 0.0, 0.0, 0.0)

local animCount = 0
local anims = rl.LoadModelAnimations("resources/models/gltf/robot.glb", animCount)

local animIndex = 0
local animCurrentFrame = 0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	if rl.IsKeyPressed(rl.KEY_RIGHT) then
		animIndex = (animIndex + 1) % animCount
	elseif rl.IsKeyPressed(rl.KEY_LEFT) then
		animIndex = (animIndex + animCount - 1) % animCount
	end

	animCurrentFrame = (animCurrentFrame + 1) % anims[animIndex].keyframeCount
	rl.UpdateModelAnimation(model, anims[animIndex], animCurrentFrame)

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawModel(model, position, 1.0, rl.WHITE)
	rl.DrawGrid(10, 1.0)
	rl.EndMode3D()

	rl.DrawText(string.format("Current animation: %s", anims[animIndex].name), 10, 40, 20, rl.MAROON)
	rl.DrawText("Use the LEFT/RIGHT keys to switch animation", 10, 10, 20, rl.GRAY)

	rl.EndDrawing()
end

rl.UnloadModelAnimations(anims, animCount)
rl.UnloadModel(model)

rl.CloseWindow()