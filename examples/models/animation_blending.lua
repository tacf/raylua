--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/models/models_animation_blending.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - animation blending")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 6.0, 6.0, 6.0),
	target = rl.new("Vector3", 0.0, 2.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local model = rl.LoadModel("resources/models/gltf/robot.glb")
local position = rl.new("Vector3", 0.0, 0.0, 0.0)

local skinningShader = rl.LoadShader(
	string.format("resources/shaders/glsl330/skinning.vs"),
	string.format("resources/shaders/glsl330/skinning.fs")
)

local animCount = 0
local anims = rl.LoadModelAnimations("resources/models/gltf/robot.glb", animCount)

local currentAnimPlaying = 0
local nextAnimToPlay = 1
local animTransition = false

local animIndex0 = 10
local animCurrentFrame0 = 0.0
local animFrameSpeed0 = 0.5
local animIndex1 = 6
local animCurrentFrame1 = 0.0
local animFrameSpeed1 = 0.5

local animBlendFactor = 0.0
local animBlendTime = 2.0
local animBlendTimeCounter = 0.0

local animPause = false

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	if rl.IsKeyPressed(rl.KEY_P) then
		animPause = not animPause
	end

	if not animPause then
		if rl.IsKeyPressed(rl.KEY_SPACE) and not animTransition then
			if currentAnimPlaying == 0 then
				nextAnimToPlay = 1
				animCurrentFrame1 = 0.0
			else
				nextAnimToPlay = 0
				animCurrentFrame0 = 0.0
			end

			animTransition = true
			animBlendTimeCounter = 0.0
			animBlendFactor = 0.0
		end

		if animTransition then
			animCurrentFrame0 = animCurrentFrame0 + animFrameSpeed0
			if animCurrentFrame0 >= anims[animIndex0].keyframeCount then animCurrentFrame0 = 0.0 end
			animCurrentFrame1 = animCurrentFrame1 + animFrameSpeed1
			if animCurrentFrame1 >= anims[animIndex1].keyframeCount then animCurrentFrame1 = 0.0 end

			animBlendFactor = animBlendTimeCounter / animBlendTime
			animBlendTimeCounter = animBlendTimeCounter + rl.GetFrameTime()

			local animBlendProgress = animBlendFactor

			if nextAnimToPlay == 1 then
				rl.UpdateModelAnimationEx(model, anims[animIndex0], animCurrentFrame0,
					anims[animIndex1], animCurrentFrame1, animBlendFactor)
			else
				rl.UpdateModelAnimationEx(model, anims[animIndex1], animCurrentFrame1,
					anims[animIndex0], animCurrentFrame0, animBlendFactor)
			end

			if animBlendFactor > 1.0 then
				if currentAnimPlaying == 0 then animCurrentFrame0 = 0.0
				elseif currentAnimPlaying == 1 then animCurrentFrame1 = 0.0 end
				currentAnimPlaying = nextAnimToPlay

				animBlendFactor = 0.0
				animTransition = false
				animBlendTimeCounter = 0.0
			end
		else
			if currentAnimPlaying == 0 then
				animCurrentFrame0 = animCurrentFrame0 + animFrameSpeed0
				if animCurrentFrame0 >= anims[animIndex0].keyframeCount then animCurrentFrame0 = 0.0 end
				rl.UpdateModelAnimation(model, anims[animIndex0], animCurrentFrame0)
			elseif currentAnimPlaying == 1 then
				animCurrentFrame1 = animCurrentFrame1 + animFrameSpeed1
				if animCurrentFrame1 >= anims[animIndex1].keyframeCount then animCurrentFrame1 = 0.0 end
				rl.UpdateModelAnimation(model, anims[animIndex1], animCurrentFrame1)
			end
		end
	end

	local animFrameProgress0 = animCurrentFrame0
	local animFrameProgress1 = animCurrentFrame1

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawModel(model, position, 1.0, rl.WHITE)
	rl.DrawGrid(10, 1.0)
	rl.EndMode3D()

	if animTransition then
		rl.DrawText("ANIM TRANSITION BLENDING!", 170, 50, 30, rl.BLUE)
	end

	rl.DrawText(string.format("x%.1f", animFrameSpeed0), 170, 38, 12, rl.GRAY)
	rl.DrawText(string.format("%.1fx", animFrameSpeed1), screenWidth - 70, 38, 12, rl.GRAY)

	rl.DrawText(string.format("FRAME: %.2f / %i", animFrameProgress0, anims[animIndex0].keyframeCount), 60, screenHeight - 60, 10, rl.GRAY)
	rl.DrawText(string.format("FRAME: %.2f / %i", animFrameProgress1, anims[animIndex1].keyframeCount), 60, screenHeight - 30, 10, rl.GRAY)

	rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.UnloadModelAnimations(anims, animCount)
rl.UnloadModel(model)
rl.UnloadShader(skinningShader)

rl.CloseWindow()