local screenWidth = 800
local screenHeight = 450
local splitWidth = screenWidth / 2

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - framebuffer rendering")
rl.SetTargetFPS(60)
rl.DisableCursor()

local subjectCamera = {
	position = { x = 5.0, y = 5.0, z = 5.0 },
	target = { x = 0.0, y = 0.0, z = 0.0 },
	up = { x = 0.0, y = 1.0, z = 0.0 },
	fovy = 45.0,
	projection = rl.CAMERA_PERSPECTIVE
}

local observerCamera = {
	position = { x = 10.0, y = 10.0, z = 10.0 },
	target = { x = 0.0, y = 0.0, z = 0.0 },
	up = { x = 0.0, y = 1.0, z = 0.0 },
	fovy = 45.0,
	projection = rl.CAMERA_PERSPECTIVE
}

local observerTarget = rl.LoadRenderTexture(splitWidth, screenHeight)
local observerSource = { x = 0.0, y = 0.0, width = observerTarget.texture.width, height = -observerTarget.texture.height }
local observerDest = { x = 0.0, y = 0.0, width = splitWidth, height = screenHeight }

local subjectTarget = rl.LoadRenderTexture(splitWidth, screenHeight)
local subjectSource = { x = 0.0, y = 0.0, width = subjectTarget.texture.width, height = -subjectTarget.texture.height }
local subjectDest = { x = splitWidth, y = 0.0, width = splitWidth, height = screenHeight }
local textureAspectRatio = subjectTarget.texture.width / subjectTarget.texture.height

local captureSize = 128.0
local cropSource = {
	x = (subjectTarget.texture.width - captureSize) / 2.0,
	y = (subjectTarget.texture.height - captureSize) / 2.0,
	width = captureSize,
	height = -captureSize
}
local cropDest = { x = splitWidth + 20.0, y = 20.0, width = captureSize, height = captureSize }

local function DrawCameraPrism(camera, aspect, color)
	local length = rl.Vector3Distance(camera.position, camera.target)

	local planeNDC = {
		{ x = -1.0, y = -1.0, z = 1.0 },
		{ x = 1.0, y = -1.0, z = 1.0 },
		{ x = 1.0, y = 1.0, z = 1.0 },
		{ x = -1.0, y = 1.0, z = 1.0 }
	}

	local view = rl.GetCameraMatrix(camera)
	local proj = rl.MatrixPerspective(camera.fovy * rl.DEG2RAD, aspect, 0.05, length)
	local viewProj = rl.MatrixMultiply(view, proj)
	local inverseViewProj = rl.MatrixInvert(viewProj)

	local corners = {}
	for i = 1, 4 do
		local x = planeNDC[i].x
		local y = planeNDC[i].y
		local z = planeNDC[i].z

		local vx = inverseViewProj.m0 * x + inverseViewProj.m4 * y + inverseViewProj.m8 * z + inverseViewProj.m12
		local vy = inverseViewProj.m1 * x + inverseViewProj.m5 * y + inverseViewProj.m9 * z + inverseViewProj.m13
		local vz = inverseViewProj.m2 * x + inverseViewProj.m6 * y + inverseViewProj.m10 * z + inverseViewProj.m14
		local vw = inverseViewProj.m3 * x + inverseViewProj.m7 * y + inverseViewProj.m11 * z + inverseViewProj.m15

		corners[i] = { x = vx / vw, y = vy / vw, z = vz / vw }
	end

	rl.DrawLine3D(corners[1], corners[2], color)
	rl.DrawLine3D(corners[2], corners[3], color)
	rl.DrawLine3D(corners[3], corners[4], color)
	rl.DrawLine3D(corners[4], corners[1], color)

	for i = 1, 4 do
		rl.DrawLine3D(camera.position, corners[i], color)
	end
end

while not rl.WindowShouldClose() do
	rl.UpdateCamera(observerCamera, rl.CAMERA_FREE)
	rl.UpdateCamera(subjectCamera, rl.CAMERA_ORBITAL)

	if rl.IsKeyPressed(rl.KEY_R) then
		observerCamera.target = { x = 0.0, y = 0.0, z = 0.0 }
	end

	rl.BeginTextureMode(observerTarget)
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(observerCamera)
	rl.DrawGrid(10, 1.0)
	rl.DrawCube({ x = 0.0, y = 0.0, z = 0.0 }, 2.0, 2.0, 2.0, rl.GOLD)
	rl.DrawCubeWires({ x = 0.0, y = 0.0, z = 0.0 }, 2.0, 2.0, 2.0, rl.PINK)
	rl.DrawCameraPrism(subjectCamera, textureAspectRatio, rl.GREEN)
	rl.EndMode3D()

	rl.DrawText("Observer View", 10, observerTarget.texture.height - 30, 20, rl.BLACK)
	rl.DrawText("WASD + Mouse to Move", 10, 10, 20, rl.DARKGRAY)
	rl.DrawText("Scroll to Zoom", 10, 30, 20, rl.DARKGRAY)
	rl.DrawText("R to Reset Observer Target", 10, 50, 20, rl.DARKGRAY)

	rl.EndTextureMode()

	rl.BeginTextureMode(subjectTarget)
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(subjectCamera)
	rl.DrawCube({ x = 0.0, y = 0.0, z = 0.0 }, 2.0, 2.0, 2.0, rl.GOLD)
	rl.DrawCubeWires({ x = 0.0, y = 0.0, z = 0.0 }, 2.0, 2.0, 2.0, rl.PINK)
	rl.DrawGrid(10, 1.0)
	rl.EndMode3D()

	rl.DrawRectangleLines(math.floor((subjectTarget.texture.width - captureSize) / 2.0), math.floor((subjectTarget.texture.height - captureSize) / 2.0), captureSize, captureSize, rl.GREEN)
	rl.DrawText("Subject View", 10, subjectTarget.texture.height - 30, 20, rl.BLACK)

	rl.EndTextureMode()

	rl.BeginDrawing()

	rl.ClearBackground(rl.BLACK)

	rl.DrawTexturePro(observerTarget.texture,
		rl.new("Rectangle", observerSource.x, observerSource.y, observerSource.width, observerSource.height),
		rl.new("Rectangle", observerDest.x, observerDest.y, observerDest.width, observerDest.height),
		rl.new("Vector2", 0.0, 0.0), 0.0, rl.WHITE)

	rl.DrawTexturePro(subjectTarget.texture,
		rl.new("Rectangle", subjectSource.x, subjectSource.y, subjectSource.width, subjectSource.height),
		rl.new("Rectangle", subjectDest.x, subjectDest.y, subjectDest.width, subjectDest.height),
		rl.new("Vector2", 0.0, 0.0), 0.0, rl.WHITE)

	rl.DrawTexturePro(subjectTarget.texture,
		rl.new("Rectangle", cropSource.x, cropSource.y, cropSource.width, cropSource.height),
		rl.new("Rectangle", cropDest.x, cropDest.y, cropDest.width, cropDest.height),
		rl.new("Vector2", 0.0, 0.0), 0.0, rl.WHITE)
	rl.DrawRectangleLinesEx(rl.new("Rectangle", cropDest.x, cropDest.y, cropDest.width, cropDest.height), 2, rl.BLACK)

	rl.DrawLine(splitWidth, 0, splitWidth, screenHeight, rl.BLACK)

	rl.EndDrawing()
end

rl.UnloadRenderTexture(observerTarget)
rl.UnloadRenderTexture(subjectTarget)

rl.CloseWindow()