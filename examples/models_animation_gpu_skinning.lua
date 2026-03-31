local screenWidth = 800
local screenHeight = 450

local GLSL_VERSION = 330

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - animation gpu skinning")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 5, 5, 5),
	target = rl.new("Vector3", 0, 1, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local model = rl.LoadModel("raylib/examples/models/resources/models/gltf/greenman.glb")
local position = rl.new("Vector3", 0, 0, 0)

local skinningShader = rl.LoadShader(
	string.format("raylib/examples/models/resources/shaders/glsl%i/skinning.vs", GLSL_VERSION),
	string.format("raylib/examples/models/resources/shaders/glsl%i/skinning.fs", GLSL_VERSION))
model.materials[1].shader = skinningShader

local animCount = 0
local anims, animCount = rl.LoadModelAnimations("raylib/examples/models/resources/models/gltf/greenman.glb")

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
rl.UnloadShader(skinningShader)
rl.CloseWindow()
