--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/models/models_skybox_rendering.c

]]

local screenWidth = 800
local screenHeight = 450

local GLSL_VERSION = 330

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - skybox rendering")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 1, 1, 1),
	target = rl.new("Vector3", 4, 1, 4),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local cube = rl.GenMeshCube(1, 1, 1)
local skybox = rl.LoadModelFromMesh(cube)

local useHDR = false

skybox.materials[0].shader = rl.LoadShader(
	string.format("raylib/examples/models/resources/shaders/glsl%i/skybox.vs", GLSL_VERSION),
	string.format("raylib/examples/models/resources/shaders/glsl%i/skybox.fs", GLSL_VERSION))

rl.SetShaderValue(skybox.materials[0].shader,
	rl.GetShaderLocation(skybox.materials[0].shader, "environmentMap"),
	{ rl.MATERIAL_MAP_CUBEMAP }, rl.SHADER_UNIFORM_INT)
rl.SetShaderValue(skybox.materials[0].shader,
	rl.GetShaderLocation(skybox.materials[0].shader, "doGamma"),
	{ useHDR and 1 or 0 }, rl.SHADER_UNIFORM_INT)
rl.SetShaderValue(skybox.materials[0].shader,
	rl.GetShaderLocation(skybox.materials[0].shader, "vflipped"),
	{ useHDR and 1 or 0 }, rl.SHADER_UNIFORM_INT)

local shdrCubemap = rl.LoadShader(
	string.format("raylib/examples/models/resources/shaders/glsl%i/cubemap.vs", GLSL_VERSION),
	string.format("raylib/examples/models/resources/shaders/glsl%i/cubemap.fs", GLSL_VERSION))

rl.SetShaderValue(shdrCubemap,
	rl.GetShaderLocation(shdrCubemap, "equirectangularMap"),
	{ 0 }, rl.SHADER_UNIFORM_INT)

local skyboxFileName = ""

if useHDR then
	skyboxFileName = "raylib/examples/models/resources/dresden_square_2k.hdr"
	local panorama = rl.LoadTexture(skyboxFileName)
	skybox.materials[0].maps[rl.MATERIAL_MAP_CUBEMAP].texture = rl.GenTextureCubemap(shdrCubemap, panorama, 1024, rl.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)
	rl.UnloadTexture(panorama)
else
	skyboxFileName = "raylib/examples/models/resources/skybox.png"
	local image = rl.LoadImage(skyboxFileName)
	skybox.materials[0].maps[rl.MATERIAL_MAP_CUBEMAP].texture = rl.LoadTextureCubemap(image, rl.CUBEMAP_LAYOUT_AUTO_DETECT)
	rl.UnloadImage(image)
end

rl.DisableCursor()
rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_FIRST_PERSON)

	if rl.IsFileDropped() then
		local droppedFiles = rl.LoadDroppedFiles()

		if droppedFiles.count == 1 then
			if rl.IsFileExtension(droppedFiles.paths[0], ".png;.jpg;.hdr;.bmp;.tga") then
				rl.UnloadTexture(skybox.materials[0].maps[rl.MATERIAL_MAP_CUBEMAP].texture)

				if useHDR then
					local panorama = rl.LoadTexture(droppedFiles.paths[0])
					skybox.materials[0].maps[rl.MATERIAL_MAP_CUBEMAP].texture = rl.GenTextureCubemap(shdrCubemap, panorama, 1024, rl.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)
					rl.UnloadTexture(panorama)
				else
					local image = rl.LoadImage(droppedFiles.paths[0])
					skybox.materials[0].maps[rl.MATERIAL_MAP_CUBEMAP].texture = rl.LoadTextureCubemap(image, rl.CUBEMAP_LAYOUT_AUTO_DETECT)
					rl.UnloadImage(image)
				end

				skyboxFileName = droppedFiles.paths[0]
			end
		end

		rl.UnloadDroppedFiles(droppedFiles)
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	rl.rlDisableBackfaceCulling()
	rl.rlDisableDepthMask()
	rl.DrawModel(skybox, rl.new("Vector3", 0, 0, 0), 1.0, rl.WHITE)
	rl.rlEnableBackfaceCulling()
	rl.rlEnableDepthMask()

	rl.DrawGrid(10, 1.0)

	rl.EndMode3D()

	if useHDR then
		rl.DrawText(string.format("Panorama image from hdrihaven.com: %s", rl.GetFileName(skyboxFileName)), 10, screenHeight - 20, 10, rl.BLACK)
	else
		rl.DrawText(string.format(": %s", rl.GetFileName(skyboxFileName)), 10, screenHeight - 20, 10, rl.BLACK)
	end

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.UnloadShader(skybox.materials[0].shader)
rl.UnloadTexture(skybox.materials[0].maps[rl.MATERIAL_MAP_CUBEMAP].texture)
rl.UnloadModel(skybox)
rl.CloseWindow()
