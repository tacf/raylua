local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - decals")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 5.0, 5.0, 5.0),
	target = rl.new("Vector3", 0.0, 1.0, 0.0),
	up = rl.new("Vector3", 0.0, 1.6, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local model = rl.LoadModel("resources/models/obj/character.obj")

local modelTexture = rl.LoadTexture("resources/models/obj/character_diffuse.png")
rl.SetTextureFilter(modelTexture, rl.TEXTURE_FILTER_BILINEAR)
model.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = modelTexture

local modelBBox = rl.GetMeshBoundingBox(model.meshes[0])

camera.target = rl.Vector3Lerp(modelBBox.min, modelBBox.max, 0.5)
camera.position = rl.Vector3Scale(modelBBox.max, 1.0)
camera.position.x = camera.position.x * 0.1

local modelSize = math.min(
	math.min(math.abs(modelBBox.max.x - modelBBox.min.x), math.abs(modelBBox.max.y - modelBBox.min.y)),
	math.abs(modelBBox.max.z - modelBBox.min.z))

camera.position = rl.new("Vector3", 0.0, modelBBox.max.y * 1.2, modelSize * 3.0)

local decalSize = modelSize * 0.25
local decalOffset = 0.01

local placementCube = rl.LoadModelFromMesh(rl.GenMeshCube(decalSize, decalSize, decalSize))
placementCube.materials[0].maps[0].color = rl.LIME

local decalMaterial = rl.LoadMaterialDefault()
decalMaterial.maps[0].color = rl.YELLOW

local decalImage = rl.LoadImage("resources/raylib_logo.png")
local decalTexture = rl.LoadTextureFromImage(decalImage)

rl.UnloadImage(decalImage)

rl.SetTextureFilter(decalTexture, rl.TEXTURE_FILTER_BILINEAR)
decalMaterial.maps[rl.MATERIAL_MAP_DIFFUSE].texture = decalTexture
decalMaterial.maps[rl.MATERIAL_MAP_DIFFUSE].color = rl.RAYWHITE

local showModel = true
local decalModels = {}
local decalCount = 0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsMouseButtonDown(rl.MOUSE_RIGHT_BUTTON) then
		rl.UpdateCamera(camera, rl.CAMERA_THIRD_PERSON)
	end

	local collision = { hit = false, distance = 340282346638528859811704183484516925440.0 }

	local ray = rl.GetScreenToWorldRay(rl.GetMousePosition(), camera)

	local boxHitInfo = rl.GetRayCollisionBox(ray, modelBBox)

	if boxHitInfo.hit and decalCount < 256 then
		local meshHitInfo = { hit = false }
		for m = 0, model.meshCount - 1 do
			meshHitInfo = rl.GetRayCollisionMesh(ray, model.meshes[m], model.transform)
			if meshHitInfo.hit then
				if not collision.hit or collision.distance > meshHitInfo.distance then
					collision = meshHitInfo
				end
			end
		end

		if meshHitInfo.hit then
			collision = meshHitInfo
		end
	end

	if collision.hit and rl.IsMouseButtonPressed(rl.MOUSE_LEFT_BUTTON) and decalCount < 256 then
		local origin = rl.Vector3Add(collision.point, rl.Vector3Scale(collision.normal, 1.0))
		local splat = rl.MatrixLookAt(collision.point, origin, rl.new("Vector3", 0.0, 1.0, 0.0))

		local decalMesh = { vertexCount = 0 }

		if decalMesh.vertexCount > 0 then
			decalCount = decalCount + 1
			decalModels[decalCount] = rl.LoadModelFromMesh(decalMesh)
			decalModels[decalCount].materials[0].maps[0] = decalMaterial.maps[0]
		end
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	if showModel then
		rl.DrawModel(model, rl.new("Vector3", 0.0, 0.0, 0.0), 1.0, rl.WHITE)
	end

	for i = 1, decalCount do
		rl.DrawModel(decalModels[i], rl.new("Vector3", 0.0, 0.0, 0.0), 1.0, rl.WHITE)
	end

	if collision.hit then
		local origin = rl.Vector3Add(collision.point, rl.Vector3Scale(collision.normal, 1.0))
		local splat = rl.MatrixLookAt(collision.point, origin, rl.new("Vector3", 0.0, 1.0, 0.0))
		placementCube.transform = rl.MatrixInvert(splat)
		rl.DrawModel(placementCube, rl.new("Vector3", 0.0, 0.0, 0.0), 1.0, rl.Fade(rl.WHITE, 0.5))
	end

	rl.DrawGrid(10, 10.0)
	rl.EndMode3D()

	local yPos = 10
	local x0 = screenWidth - 300.0
	local x1 = x0 + 100
	local x2 = x1 + 100

	rl.DrawText("Vertices", x1, yPos, 10, rl.LIME)
	rl.DrawText("Triangles", x2, yPos, 10, rl.LIME)
	yPos = yPos + 15

	local vertexCount = 0
	local triangleCount = 0

	for i = 0, model.meshCount - 1 do
		vertexCount = vertexCount + model.meshes[i].vertexCount
		triangleCount = triangleCount + model.meshes[i].triangleCount
	end

	rl.DrawText("Main model", x0, yPos, 10, rl.LIME)
	rl.DrawText(string.format("%d", vertexCount), x1, yPos, 10, rl.LIME)
	rl.DrawText(string.format("%d", triangleCount), x2, yPos, 10, rl.LIME)
	yPos = yPos + 15

	rl.DrawText("Hold RMB to move camera", 10, 430, 10, rl.GRAY)
	rl.DrawText("(c) Character model and texture from kenney.nl", screenWidth - 260, screenHeight - 20, 10, rl.GRAY)

	rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.UnloadModel(model)
rl.UnloadTexture(modelTexture)

for i = 1, decalCount do
	rl.UnloadModel(decalModels[i])
end

rl.UnloadTexture(decalTexture)

rl.CloseWindow()