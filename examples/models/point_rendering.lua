--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/models/models_point_rendering.c

]]

local screenWidth = 800
local screenHeight = 450

local MAX_POINTS = 10000000
local MIN_POINTS = 1000

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - point rendering")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 3, 3, 3),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local position = rl.new("Vector3", 0, 0, 0)
local useDrawModelPoints = true
local numPointsChanged = false
local numPoints = 1000

local function GenMeshPoints(n)
	local mesh = rl.new("Mesh", {
		triangleCount = 1,
		vertexCount = n,
	})

	-- Allocate and fill vertex and color data
	local verts = {}
	local cols = {}
	math.randomseed(42)
	for i = 0, n - 1 do
		local theta = math.pi * math.random()
		local phi = 2.0 * math.pi * math.random()
		local r = 10.0 * math.random()

		verts[i * 3 + 1] = r * math.sin(theta) * math.cos(phi)
		verts[i * 3 + 2] = r * math.sin(theta) * math.sin(phi)
		verts[i * 3 + 3] = r * math.cos(theta)

		local color = rl.ColorFromHSV(r * 360.0, 1.0, 1.0)
		cols[i * 4 + 1] = color.r
		cols[i * 4 + 2] = color.g
		cols[i * 4 + 3] = color.b
		cols[i * 4 + 4] = color.a
	end

	mesh.vertices = verts
	mesh.colors = cols

	rl.UploadMesh(mesh, false)
	return mesh
end

local function DrawModelPoints(model, pos, scale, tint)
	rl.rlEnablePointMode()
	rl.rlDisableBackfaceCulling()

	rl.DrawModel(model, pos, scale, tint)

	rl.rlEnableBackfaceCulling()
	rl.rlDisablePointMode()
end

local mesh = GenMeshPoints(numPoints)
local model = rl.LoadModelFromMesh(mesh)

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	if rl.IsKeyPressed(rl.KEY_SPACE) then useDrawModelPoints = not useDrawModelPoints end
	if rl.IsKeyPressed(rl.KEY_UP) then
		local newCount = numPoints * 10
		numPoints = (newCount > MAX_POINTS) and MAX_POINTS or newCount
		numPointsChanged = true
	end
	if rl.IsKeyPressed(rl.KEY_DOWN) then
		local newCount = math.floor(numPoints / 10)
		numPoints = (newCount < MIN_POINTS) and MIN_POINTS or newCount
		numPointsChanged = true
	end

	if numPointsChanged then
		rl.UnloadModel(model)
		mesh = GenMeshPoints(numPoints)
		model = rl.LoadModelFromMesh(mesh)
		numPointsChanged = false
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode3D(camera)

	if useDrawModelPoints then
		DrawModelPoints(model, position, 1.0, rl.WHITE)
	else
		local verts = mesh.vertices
		local cols = mesh.colors
		for i = 0, numPoints - 1 do
			local pos = rl.new("Vector3",
				verts[i * 3 + 1],
				verts[i * 3 + 2],
				verts[i * 3 + 3])
			local color = rl.new("Color",
				cols[i * 4 + 1],
				cols[i * 4 + 2],
				cols[i * 4 + 3],
				cols[i * 4 + 4])
			rl.DrawPoint3D(pos, color)
		end
	end

	rl.DrawSphereWires(position, 1.0, 10, 10, rl.YELLOW)
	rl.EndMode3D()

	rl.DrawText(string.format("Point Count: %d", numPoints), 10, screenHeight - 50, 40, rl.WHITE)
	rl.DrawText("UP - Increase points", 10, 40, 20, rl.WHITE)
	rl.DrawText("DOWN - Decrease points", 10, 70, 20, rl.WHITE)
	rl.DrawText("SPACE - Drawing function", 10, 100, 20, rl.WHITE)

	if useDrawModelPoints then
		rl.DrawText("Using: DrawModelPoints()", 10, 130, 20, rl.GREEN)
	else
		rl.DrawText("Using: DrawPoint3D()", 10, 130, 20, rl.RED)
	end

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.UnloadModel(model)
rl.CloseWindow()
