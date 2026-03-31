--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/models/models_mesh_picking.c

]]

local screenWidth = 800
local screenHeight = 450

local FLT_MAX = 3.402823466e+38

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - mesh picking")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 20, 20, 20),
	target = rl.new("Vector3", 0, 8, 0),
	up = rl.new("Vector3", 0, 1.6, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local ray = rl.new("Ray", {
	position = rl.new("Vector3", 0, 0, 0),
	direction = rl.new("Vector3", 0, 0, 0),
})

local tower = rl.LoadModel("raylib/examples/models/resources/models/obj/turret.obj")
local texture = rl.LoadTexture("raylib/examples/models/resources/models/obj/turret_diffuse.png")
tower.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = texture

local towerPos = rl.new("Vector3", 0, 0, 0)
local towerBBox = rl.GetMeshBoundingBox(tower.meshes[0])

local g0 = rl.new("Vector3", -50, 0, -50)
local g1 = rl.new("Vector3", -50, 0, 50)
local g2 = rl.new("Vector3", 50, 0, 50)
local g3 = rl.new("Vector3", 50, 0, -50)

local ta = rl.new("Vector3", -25, 0.5, 0)
local tb = rl.new("Vector3", -4, 2.5, 1)
local tc = rl.new("Vector3", -8, 6.5, 0)

local bary = rl.new("Vector3", 0, 0, 0)

local sp = rl.new("Vector3", -30, 5, 5)
local sr = 4.0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsCursorHidden() then rl.UpdateCamera(camera, rl.CAMERA_FIRST_PERSON) end

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT) then
		if rl.IsCursorHidden() then rl.EnableCursor()
		else rl.DisableCursor()
		end
	end

	local collision = rl.new("RayCollision", {
		hit = false,
		distance = FLT_MAX,
		point = rl.new("Vector3", 0, 0, 0),
		normal = rl.new("Vector3", 0, 0, 0),
	})
	local hitObjectName = "None"
	local cursorColor = rl.WHITE

	ray = rl.GetScreenToWorldRay(rl.GetMousePosition(), camera)

	local groundHitInfo = rl.GetRayCollisionQuad(ray, g0, g1, g2, g3)
	if groundHitInfo.hit and groundHitInfo.distance < collision.distance then
		collision = groundHitInfo
		cursorColor = rl.GREEN
		hitObjectName = "Ground"
	end

	local triHitInfo = rl.GetRayCollisionTriangle(ray, ta, tb, tc)
	if triHitInfo.hit and triHitInfo.distance < collision.distance then
		collision = triHitInfo
		cursorColor = rl.PURPLE
		hitObjectName = "Triangle"
		bary = rl.Vector3Barycenter(collision.point, ta, tb, tc)
	end

	local sphereHitInfo = rl.GetRayCollisionSphere(ray, sp, sr)
	if sphereHitInfo.hit and sphereHitInfo.distance < collision.distance then
		collision = sphereHitInfo
		cursorColor = rl.ORANGE
		hitObjectName = "Sphere"
	end

	local boxHitInfo = rl.GetRayCollisionBox(ray, towerBBox)
	if boxHitInfo.hit and boxHitInfo.distance < collision.distance then
		collision = boxHitInfo
		cursorColor = rl.ORANGE
		hitObjectName = "Box"

		local meshHitInfo = rl.new("RayCollision", { hit = false, distance = 0, point = rl.new("Vector3", 0, 0, 0), normal = rl.new("Vector3", 0, 0, 0) })
		for m = 0, tower.meshCount - 1 do
			meshHitInfo = rl.GetRayCollisionMesh(ray, tower.meshes[m], tower.transform)
			if meshHitInfo.hit then
				if not collision.hit or collision.distance > meshHitInfo.distance then
					collision = meshHitInfo
				end
				break
			end
		end

		if meshHitInfo.hit then
			collision = meshHitInfo
			cursorColor = rl.ORANGE
			hitObjectName = "Mesh"
		end
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	rl.DrawModel(tower, towerPos, 1.0, rl.WHITE)

	rl.DrawLine3D(ta, tb, rl.PURPLE)
	rl.DrawLine3D(tb, tc, rl.PURPLE)
	rl.DrawLine3D(tc, ta, rl.PURPLE)

	rl.DrawSphereWires(sp, sr, 8, 8, rl.PURPLE)

	if boxHitInfo.hit then rl.DrawBoundingBox(towerBBox, rl.LIME) end

	if collision.hit then
		rl.DrawCube(collision.point, 0.3, 0.3, 0.3, cursorColor)
		rl.DrawCubeWires(collision.point, 0.3, 0.3, 0.3, rl.RED)

		local normalEnd = rl.new("Vector3",
			collision.point.x + collision.normal.x,
			collision.point.y + collision.normal.y,
			collision.point.z + collision.normal.z)
		rl.DrawLine3D(collision.point, normalEnd, rl.RED)
	end

	rl.DrawRay(ray, rl.MAROON)
	rl.DrawGrid(10, 10.0)

	rl.EndMode3D()

	rl.DrawText(string.format("Hit Object: %s", hitObjectName), 10, 50, 10, rl.BLACK)

	if collision.hit then
		local ypos = 70
		rl.DrawText(string.format("Distance: %3.2f", collision.distance), 10, ypos, 10, rl.BLACK)
		rl.DrawText(string.format("Hit Pos: %3.2f %3.2f %3.2f", collision.point.x, collision.point.y, collision.point.z), 10, ypos + 15, 10, rl.BLACK)
		rl.DrawText(string.format("Hit Norm: %3.2f %3.2f %3.2f", collision.normal.x, collision.normal.y, collision.normal.z), 10, ypos + 30, 10, rl.BLACK)

		if triHitInfo.hit and hitObjectName == "Triangle" then
			rl.DrawText(string.format("Barycenter: %3.2f %3.2f %3.2f", bary.x, bary.y, bary.z), 10, ypos + 45, 10, rl.BLACK)
		end
	end

	rl.DrawText("Right click mouse to toggle camera controls", 10, 430, 10, rl.GRAY)
	rl.DrawText("(c) Turret 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, rl.GRAY)
	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.UnloadModel(tower)
rl.UnloadTexture(texture)
rl.CloseWindow()
