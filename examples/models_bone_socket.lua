local screenWidth = 800
local screenHeight = 450

local BONE_SOCKETS = 3
local BONE_SOCKET_HAT = 1
local BONE_SOCKET_HAND_R = 2
local BONE_SOCKET_HAND_L = 3

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - bone socket")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 5, 5, 5),
	target = rl.new("Vector3", 0, 2, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local characterModel = rl.LoadModel("raylib/examples/models/resources/models/gltf/greenman.glb")
local equipModel = {
	rl.LoadModel("raylib/examples/models/resources/models/gltf/greenman_hat.glb"),
	rl.LoadModel("raylib/examples/models/resources/models/gltf/greenman_sword.glb"),
	rl.LoadModel("raylib/examples/models/resources/models/gltf/greenman_shield.glb"),
}

local showEquip = { true, true, true }

local animsCount = 0
local animIndex = 0
local animCurrentFrame = 0
local modelAnimations, animsCount = rl.LoadModelAnimations("raylib/examples/models/resources/models/gltf/greenman.glb")

local boneSocketIndex = { -1, -1, -1 }

for i = 0, characterModel.skeleton.boneCount - 1 do
	local boneName = characterModel.skeleton.bones[i].name
	if boneName == "socket_hat" then
		boneSocketIndex[BONE_SOCKET_HAT] = i
	elseif boneName == "socket_hand_R" then
		boneSocketIndex[BONE_SOCKET_HAND_R] = i
	elseif boneName == "socket_hand_L" then
		boneSocketIndex[BONE_SOCKET_HAND_L] = i
	end
end

local position = rl.new("Vector3", 0, 0, 0)
local angle = 0

rl.DisableCursor()
rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_THIRD_PERSON)

	if rl.IsKeyDown(rl.KEY_F) then
		angle = (angle + 1) % 360
	elseif rl.IsKeyDown(rl.KEY_H) then
		angle = (360 + angle - 1) % 360
	end

	if rl.IsKeyPressed(rl.KEY_T) then
		animIndex = (animIndex + 1) % animsCount
	elseif rl.IsKeyPressed(rl.KEY_G) then
		animIndex = (animIndex + animsCount - 1) % animsCount
	end

	if rl.IsKeyPressed(rl.KEY_ONE) then showEquip[BONE_SOCKET_HAT] = not showEquip[BONE_SOCKET_HAT] end
	if rl.IsKeyPressed(rl.KEY_TWO) then showEquip[BONE_SOCKET_HAND_R] = not showEquip[BONE_SOCKET_HAND_R] end
	if rl.IsKeyPressed(rl.KEY_THREE) then showEquip[BONE_SOCKET_HAND_L] = not showEquip[BONE_SOCKET_HAND_L] end

	local anim = modelAnimations[animIndex]
	animCurrentFrame = (animCurrentFrame + 1) % anim.keyframeCount
	rl.UpdateModelAnimation(characterModel, anim, animCurrentFrame)

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	local characterRotate = rl.QuaternionFromAxisAngle(rl.new("Vector3", 0, 1, 0), angle * math.pi / 180.0)
	characterModel.transform = rl.MatrixMultiply(rl.QuaternionToMatrix(characterRotate), rl.MatrixTranslate(position.x, position.y, position.z))
	rl.UpdateModelAnimation(characterModel, anim, animCurrentFrame)
	rl.DrawMesh(characterModel.meshes[0], characterModel.materials[1], characterModel.transform)

	for i = 1, BONE_SOCKETS do
		if showEquip[i] then
			local boneIdx = boneSocketIndex[i]
			local transform = anim.keyframePoses[animCurrentFrame][boneIdx]
			local inRotation = characterModel.skeleton.bindPose[boneIdx].rotation
			local outRotation = transform.rotation

			local rotate = rl.QuaternionMultiply(outRotation, rl.QuaternionInvert(inRotation))
			local matrixTransform = rl.QuaternionToMatrix(rotate)
			matrixTransform = rl.MatrixMultiply(matrixTransform, rl.MatrixTranslate(transform.translation.x, transform.translation.y, transform.translation.z))
			matrixTransform = rl.MatrixMultiply(matrixTransform, characterModel.transform)

			rl.DrawMesh(equipModel[i].meshes[0], equipModel[i].materials[1], matrixTransform)
		end
	end

	rl.DrawGrid(10, 1.0)
	rl.EndMode3D()

	rl.DrawText("Use the T/G to switch animation", 10, 10, 20, rl.GRAY)
	rl.DrawText("Use the F/H to rotate character left/right", 10, 35, 20, rl.GRAY)
	rl.DrawText("Use the 1,2,3 to toggle shown of hat, sword and shield", 10, 60, 20, rl.GRAY)

	rl.EndDrawing()
end

rl.UnloadModelAnimations(modelAnimations, animsCount)
rl.UnloadModel(characterModel)
for i = 1, BONE_SOCKETS do
	rl.UnloadModel(equipModel[i])
end
rl.CloseWindow()
