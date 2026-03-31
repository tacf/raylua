local screenWidth = 800
local screenHeight = 450

local MAX_VOX_FILES = 4

local GLSL_VERSION = 330

local voxFileNames = {
	"raylib/examples/models/resources/models/vox/chr_knight.vox",
	"raylib/examples/models/resources/models/vox/chr_sword.vox",
	"raylib/examples/models/resources/models/vox/monu9.vox",
	"raylib/examples/models/resources/models/vox/fez.vox",
}

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - loading vox")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 10, 10, 10),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local models = {}
for i = 1, MAX_VOX_FILES do
	local t0 = rl.GetTime() * 1000.0
	models[i] = rl.LoadModel(voxFileNames[i])
	local t1 = rl.GetTime() * 1000.0

	rl.TraceLog(rl.LOG_INFO, string.format("[%s] Model file loaded in %.3f ms", voxFileNames[i], t1 - t0))

	local bb = rl.GetModelBoundingBox(models[i])
	local centerX = bb.min.x + (bb.max.x - bb.min.x) / 2
	local centerZ = bb.min.z + (bb.max.z - bb.min.z) / 2

	local matTranslate = rl.MatrixTranslate(-centerX, 0, -centerZ)
	models[i].transform = matTranslate
end

local currentModel = 1
local modelpos = rl.new("Vector3", 0, 0, 0)
local camerarot = rl.new("Vector3", 0, 0, 0)

local shader = rl.LoadShader(
	string.format("raylib/examples/models/resources/shaders/glsl%i/voxel_lighting.vs", GLSL_VERSION),
	string.format("raylib/examples/models/resources/shaders/glsl%i/voxel_lighting.fs", GLSL_VERSION))

shader.locs[rl.SHADER_LOC_VECTOR_VIEW] = rl.GetShaderLocation(shader, "viewPos")

local ambientLoc = rl.GetShaderLocation(shader, "ambient")
rl.SetShaderValue(shader, ambientLoc, { 0.1, 0.1, 0.1, 1.0 }, rl.SHADER_UNIFORM_VEC4)

for i = 1, MAX_VOX_FILES do
	for j = 0, models[i].materialCount - 1 do
		models[i].materials[j].shader = shader
	end
end

local MAX_LIGHTS = 4
local lights = {}

lights[1] = rl.CreateLight(rl.LIGHT_POINT, rl.new("Vector3", -20, 20, -20), rl.new("Vector3", 0, 0, 0), rl.GRAY, shader)
lights[2] = rl.CreateLight(rl.LIGHT_POINT, rl.new("Vector3", 20, -20, 20), rl.new("Vector3", 0, 0, 0), rl.GRAY, shader)
lights[3] = rl.CreateLight(rl.LIGHT_POINT, rl.new("Vector3", -20, 20, 20), rl.new("Vector3", 0, 0, 0), rl.GRAY, shader)
lights[4] = rl.CreateLight(rl.LIGHT_POINT, rl.new("Vector3", 20, -20, -20), rl.new("Vector3", 0, 0, 0), rl.GRAY, shader)

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_MIDDLE) then
		local mouseDelta = rl.GetMouseDelta()
		camerarot.x = mouseDelta.x * 0.05
		camerarot.y = mouseDelta.y * 0.05
	else
		camerarot.x = 0
		camerarot.y = 0
	end

	rl.UpdateCameraPro(camera,
		rl.new("Vector3",
			(rl.IsKeyDown(rl.KEY_W) or rl.IsKeyDown(rl.KEY_UP)) and 0.1 or 0 - (rl.IsKeyDown(rl.KEY_S) or rl.IsKeyDown(rl.KEY_DOWN)) and 0.1 or 0,
			(rl.IsKeyDown(rl.KEY_D) or rl.IsKeyDown(rl.KEY_RIGHT)) and 0.1 or 0 - (rl.IsKeyDown(rl.KEY_A) or rl.IsKeyDown(rl.KEY_LEFT)) and 0.1 or 0,
			0),
		camerarot,
		rl.GetMouseWheelMove() * -2.0)

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then
		currentModel = (currentModel % MAX_VOX_FILES) + 1
	end

	local cameraPos = { camera.position.x, camera.position.y, camera.position.z }
	rl.SetShaderValue(shader, shader.locs[rl.SHADER_LOC_VECTOR_VIEW], cameraPos, rl.SHADER_UNIFORM_VEC3)

	for i = 1, MAX_LIGHTS do
		rl.UpdateLightValues(shader, lights[i])
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawModel(models[currentModel], modelpos, 1.0, rl.WHITE)
	rl.DrawGrid(10, 1.0)

	for i = 1, MAX_LIGHTS do
		if lights[i].enabled then
			rl.DrawSphereEx(lights[i].position, 0.2, 8, 8, lights[i].color)
		else
			rl.DrawSphereWires(lights[i].position, 0.2, 8, 8, rl.ColorAlpha(lights[i].color, 0.3))
		end
	end
	rl.EndMode3D()

	rl.DrawRectangle(10, 40, 340, 70, rl.Fade(rl.SKYBLUE, 0.5))
	rl.DrawRectangleLines(10, 40, 340, 70, rl.Fade(rl.DARKBLUE, 0.5))
	rl.DrawText("- MOUSE LEFT BUTTON: CYCLE VOX MODELS", 20, 50, 10, rl.BLUE)
	rl.DrawText("- MOUSE MIDDLE BUTTON: ZOOM OR ROTATE CAMERA", 20, 70, 10, rl.BLUE)
	rl.DrawText("- UP-DOWN-LEFT-RIGHT KEYS: MOVE CAMERA", 20, 90, 10, rl.BLUE)
	rl.DrawText(string.format("VOX model file: %s", rl.GetFileName(voxFileNames[currentModel])), 10, 10, 20, rl.GRAY)

	rl.EndDrawing()
end

for i = 1, MAX_VOX_FILES do
	rl.UnloadModel(models[i])
end

rl.CloseWindow()
