local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - animation blend custom")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 4.0, 4.0, 4.0),
	target = rl.new("Vector3", 0.0, 1.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local model = rl.LoadModel("resources/models/gltf/greenman.glb")
local position = rl.new("Vector3", 0.0, 0.0, 0.0)

local skinningShader = rl.LoadShader(
	string.format("resources/shaders/glsl330/skinning.vs"),
	string.format("resources/shaders/glsl330/skinning.fs")
)
model.materials[1].shader = skinningShader

local animCount = 0
local anims = rl.LoadModelAnimations("resources/models/gltf/greenman.glb", animCount)

local animIndex0 = 2
local animIndex1 = 3
local animCurrentFrame0 = 0
local animCurrentFrame1 = 0

if animIndex0 >= animCount then animIndex0 = 0 end
if animIndex1 >= animCount then animIndex1 = (animCount > 1) and 1 or 0 end

local upperBodyBlend = true

rl.SetTargetFPS(60)

local function isUpperBodyBone(boneName)
	if boneName == "spine" or boneName == "spine1" or boneName == "spine2" or
	   boneName == "chest" or boneName == "upperChest" or
	   boneName == "neck" or boneName == "head" or
	   boneName == "shoulder" or boneName == "shoulder_L" or boneName == "shoulder_R" or
	   boneName == "upperArm" or boneName == "upperArm_L" or boneName == "upperArm_R" or
	   boneName == "lowerArm" or boneName == "lowerArm_L" or boneName == "lowerArm_R" or
	   boneName == "hand" or boneName == "hand_L" or boneName == "hand_R" or
	   boneName == "clavicle" or boneName == "clavicle_L" or boneName == "clavicle_R" then
		return true
	end
	return false
end

local function updateModelAnimationBones(model, anim0, frame0, anim1, frame1, blend, upperBodyBlend)
	if anim0.boneCount ~= 0 and anim0.keyframePoses ~= nil and
	   anim1.boneCount ~= 0 and anim1.keyframePoses ~= nil and
	   model.skeleton.boneCount ~= 0 and model.skeleton.bindPose ~= nil then

		blend = math.min(1.0, math.max(0.0, blend))

		if frame0 >= anim0.keyframeCount then frame0 = anim0.keyframeCount - 1 end
		if frame1 >= anim1.keyframeCount then frame1 = anim1.keyframeCount - 1 end
		if frame0 < 0 then frame0 = 0 end
		if frame1 < 0 then frame1 = 0 end

		local boneCount = model.skeleton.boneCount
		if anim0.boneCount < boneCount then boneCount = anim0.boneCount end
		if anim1.boneCount < boneCount then boneCount = anim1.boneCount end

		for boneIndex = 0, boneCount - 1 do
			local boneBlendFactor = blend

			if upperBodyBlend then
				local boneName = model.skeleton.bones[boneIndex].name
				local isUpperBody = isUpperBodyBone(boneName)

				if isUpperBody then
					boneBlendFactor = blend
				else
					boneBlendFactor = 1.0 - blend
				end
			end

			local bindTransform = model.skeleton.bindPose[boneIndex]
			local animTransform0 = anim0.keyframePoses[frame0][boneIndex]
			local animTransform1 = anim1.keyframePoses[frame1][boneIndex]

			local blended = {
				translation = rl.Vector3Lerp(animTransform0.translation, animTransform1.translation, boneBlendFactor),
				rotation = rl.QuaternionSlerp(animTransform0.rotation, animTransform1.rotation, boneBlendFactor),
				scale = rl.Vector3Lerp(animTransform0.scale, animTransform1.scale, boneBlendFactor)
			}

			local bindMatrix = rl.MatrixMultiply(
				rl.MatrixMultiply(
					rl.MatrixScale(bindTransform.scale.x, bindTransform.scale.y, bindTransform.scale.z),
					rl.QuaternionToMatrix(bindTransform.rotation)
				),
				rl.MatrixTranslate(bindTransform.translation.x, bindTransform.translation.y, bindTransform.translation.z)
			)

			local blendedMatrix = rl.MatrixMultiply(
				rl.MatrixMultiply(
					rl.MatrixScale(blended.scale.x, blended.scale.y, blended.scale.z),
					rl.QuaternionToMatrix(blended.rotation)
				),
				rl.MatrixTranslate(blended.translation.x, blended.translation.y, blended.translation.z)
			)

			model.boneMatrices[boneIndex] = rl.MatrixMultiply(rl.MatrixInvert(bindMatrix), blendedMatrix)
		end
	end
end

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	if rl.IsKeyPressed(rl.KEY_SPACE) then
		upperBodyBlend = not upperBodyBlend
	end

	local anim0 = anims[animIndex0]
	local anim1 = anims[animIndex1]

	animCurrentFrame0 = (animCurrentFrame0 + 1) % anim0.keyframeCount
	animCurrentFrame1 = (animCurrentFrame1 + 1) % anim1.keyframeCount

	local blendFactor = upperBodyBlend and 1.0 or 0.5
	updateModelAnimationBones(model, anim0, animCurrentFrame0, anim1, animCurrentFrame1, blendFactor, upperBodyBlend)

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawModel(model, position, 1.0, rl.WHITE)
	rl.DrawGrid(10, 1.0)
	rl.EndMode3D()

	rl.DrawText(string.format("ANIM 0: %s", anim0.name), 10, 10, 20, rl.GRAY)
	rl.DrawText(string.format("ANIM 1: %s", anim1.name), 10, 40, 20, rl.GRAY)
	rl.DrawText(string.format("[SPACE] Toggle blending mode: %s",
		upperBodyBlend and "Upper/Lower Body Blending" or "Uniform Blending"),
		10, screenHeight - 30, 20, rl.DARKGRAY)

	rl.EndDrawing()
end

rl.UnloadModelAnimations(anims, animCount)
rl.UnloadModel(model)
rl.UnloadShader(skinningShader)

rl.CloseWindow()