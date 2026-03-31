--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/models/models_loading_m3d.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - loading m3d")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 1.5, 1.5, 1.5),
	target = rl.new("Vector3", 0, 0.4, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local model = rl.LoadModel("raylib/examples/models/resources/models/m3d/cesium_man.m3d")
local position = rl.new("Vector3", 0, 0, 0)

local animCount = 0
local anims, animCount = rl.LoadModelAnimations("raylib/examples/models/resources/models/m3d/cesium_man.m3d")

local animIndex = 0
local animCurrentFrame = 0.0

rl.SetTargetFPS(60)

local function DrawModelSkeleton(skeleton, pose, scale, color)
	for i = 0, skeleton.boneCount - 2 do
		local trans = pose[i]
		rl.DrawCube(trans, scale * 0.05, scale * 0.05, scale * 0.05, color)

		local parent = skeleton.bones[i].parent
		if parent >= 0 then
			rl.DrawLine3D(trans, pose[parent], color)
		end
	end
end

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	if rl.IsKeyPressed(rl.KEY_RIGHT) then
		animIndex = (animIndex + 1) % animCount
	elseif rl.IsKeyPressed(rl.KEY_LEFT) then
		animIndex = (animIndex + animCount - 1) % animCount
	end

	animCurrentFrame = animCurrentFrame + 1.0
	if animCurrentFrame >= anims[animIndex].keyframeCount then
		animCurrentFrame = 0.0
	end
	rl.UpdateModelAnimation(model, anims[animIndex], animCurrentFrame)

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	if not rl.IsKeyDown(rl.KEY_SPACE) then
		rl.DrawModel(model, position, 1.0, rl.WHITE)
	else
		DrawModelSkeleton(model.skeleton, anims[animIndex].keyframePoses[math.floor(animCurrentFrame)], 1.0, rl.RED)
	end

	rl.DrawGrid(10, 1.0)

	rl.EndMode3D()

	rl.DrawText(string.format("Current animation: %s", anims[animIndex].name), 10, 10, 20, rl.LIGHTGRAY)
	rl.DrawText("Press SPACE to draw skeleton", 10, 40, 20, rl.MAROON)
	rl.DrawText("(c) CesiumMan model by KhronosGroup", screenWidth - 210, screenHeight - 20, 10, rl.GRAY)

	rl.EndDrawing()
end

rl.UnloadModelAnimations(anims, animCount)
rl.UnloadModel(model)
rl.CloseWindow()
