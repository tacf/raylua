local screenWidth = 800
local screenHeight = 450

local NUM_MODELS = 9

local modelNames = { "PLANE", "CUBE", "SPHERE", "HEMISPHERE", "CYLINDER", "TORUS", "KNOT", "POLY", "Custom (triangle)" }

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - mesh generation")

local checked = rl.GenImageChecked(2, 2, 1, 1, rl.RED, rl.GREEN)
local texture = rl.LoadTextureFromImage(checked)
rl.UnloadImage(checked)

local models = {}

models[1] = rl.LoadModelFromMesh(rl.GenMeshPlane(2, 2, 4, 3))
models[2] = rl.LoadModelFromMesh(rl.GenMeshCube(2.0, 1.0, 2.0))
models[3] = rl.LoadModelFromMesh(rl.GenMeshSphere(2, 32, 32))
models[4] = rl.LoadModelFromMesh(rl.GenMeshHemiSphere(2, 16, 16))
models[5] = rl.LoadModelFromMesh(rl.GenMeshCylinder(1, 2, 16))
models[6] = rl.LoadModelFromMesh(rl.GenMeshTorus(0.25, 4.0, 16, 32))
models[7] = rl.LoadModelFromMesh(rl.GenMeshKnot(1.0, 2.0, 16, 128))
models[8] = rl.LoadModelFromMesh(rl.GenMeshPoly(5, 2.0))
models[9] = rl.LoadModelFromMesh(rl.GenMeshCustom())

for i = 1, NUM_MODELS do
	models[i].materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = texture
end

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 5, 5, 5),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local position = rl.new("Vector3", 0, 0, 0)
local currentModel = 1

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then
		currentModel = (currentModel % NUM_MODELS) + 1
	end

	if rl.IsKeyPressed(rl.KEY_RIGHT) then
		currentModel = currentModel + 1
		if currentModel > NUM_MODELS then currentModel = 1 end
	elseif rl.IsKeyPressed(rl.KEY_LEFT) then
		currentModel = currentModel - 1
		if currentModel < 1 then currentModel = NUM_MODELS end
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawModel(models[currentModel], position, 1.0, rl.WHITE)
	rl.DrawGrid(10, 1.0)
	rl.EndMode3D()

	rl.DrawRectangle(30, 400, 310, 30, rl.Fade(rl.SKYBLUE, 0.5))
	rl.DrawRectangleLines(30, 400, 310, 30, rl.Fade(rl.DARKBLUE, 0.5))
	rl.DrawText("MOUSE LEFT BUTTON to CYCLE PROCEDURAL MODELS", 40, 410, 10, rl.BLUE)

	local name = modelNames[currentModel]
	local xOff = (currentModel == 4) and 640 or 580
	rl.DrawText(name, xOff, 10, 20, rl.DARKBLUE)

	rl.EndDrawing()
end

rl.UnloadTexture(texture)
for i = 1, NUM_MODELS do
	rl.UnloadModel(models[i])
end
rl.CloseWindow()
