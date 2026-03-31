local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - animation timing")

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

local animIndex = 10
local animCurrentFrame = 0.0
local animFrameSpeed = 0.5
local animPause = false

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	if rl.IsKeyPressed(rl.KEY_P) then
		animPause = not animPause
	end

	if not animPause and animIndex < animCount then
		animCurrentFrame = animCurrentFrame + animFrameSpeed
		if animCurrentFrame >= anims[animIndex].keyframeCount then animCurrentFrame = 0.0 end
		rl.UpdateModelAnimation(model, anims[animIndex], animCurrentFrame)
	end

	local animFrameProgress = animCurrentFrame

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawModel(model, position, 1.0, rl.WHITE)
	rl.DrawGrid(10, 1.0)
	rl.EndMode3D()

	rl.DrawText(string.format("CURRENT FRAME: %.2f / %i", animFrameProgress, anims[animIndex].keyframeCount), 10, screenHeight - 64, 10, rl.GRAY)
	rl.DrawText(string.format("FRAME SPEED: x%.1f", animFrameSpeed), 260, 10, 10, rl.GRAY)

	rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.UnloadModelAnimations(anims, animCount)
rl.UnloadModel(model)

rl.CloseWindow()