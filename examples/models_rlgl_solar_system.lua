local screenWidth = 800
local screenHeight = 450

local sunRadius = 4.0
local earthRadius = 0.6
local earthOrbitRadius = 8.0
local moonRadius = 0.16
local moonOrbitRadius = 1.5

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - rlgl solar system")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 16, 16, 16),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local rotationSpeed = 0.2
local earthRotation = 0.0
local earthOrbitRotation = 0.0
local moonRotation = 0.0
local moonOrbitRotation = 0.0

local DEG2RAD = math.pi / 180.0

local function DrawSphereBasic(color)
	local rings = 16
	local slices = 16

	rl.rlCheckRenderBatchLimit((rings + 2) * slices * 6)

	rl.rlBegin(rl.RL_TRIANGLES)
	rl.rlColor4ub(color.r, color.g, color.b, color.a)

	for i = 0, rings + 1 do
		for j = 0, slices - 1 do
			rl.rlVertex3f(
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * i)) * math.sin(DEG2RAD * (j * 360.0 / slices)),
				math.sin(DEG2RAD * (270 + (180.0 / (rings + 1)) * i)),
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * i)) * math.cos(DEG2RAD * (j * 360.0 / slices)))
			rl.rlVertex3f(
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * (i + 1))) * math.sin(DEG2RAD * ((j + 1) * 360.0 / slices)),
				math.sin(DEG2RAD * (270 + (180.0 / (rings + 1)) * (i + 1))),
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * (i + 1))) * math.cos(DEG2RAD * ((j + 1) * 360.0 / slices)))
			rl.rlVertex3f(
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * (i + 1))) * math.sin(DEG2RAD * (j * 360.0 / slices)),
				math.sin(DEG2RAD * (270 + (180.0 / (rings + 1)) * (i + 1))),
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * (i + 1))) * math.cos(DEG2RAD * (j * 360.0 / slices)))

			rl.rlVertex3f(
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * i)) * math.sin(DEG2RAD * (j * 360.0 / slices)),
				math.sin(DEG2RAD * (270 + (180.0 / (rings + 1)) * i)),
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * i)) * math.cos(DEG2RAD * (j * 360.0 / slices)))
			rl.rlVertex3f(
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * i)) * math.sin(DEG2RAD * ((j + 1) * 360.0 / slices)),
				math.sin(DEG2RAD * (270 + (180.0 / (rings + 1)) * i)),
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * i)) * math.cos(DEG2RAD * ((j + 1) * 360.0 / slices)))
			rl.rlVertex3f(
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * (i + 1))) * math.sin(DEG2RAD * ((j + 1) * 360.0 / slices)),
				math.sin(DEG2RAD * (270 + (180.0 / (rings + 1)) * (i + 1))),
				math.cos(DEG2RAD * (270 + (180.0 / (rings + 1)) * (i + 1))) * math.cos(DEG2RAD * ((j + 1) * 360.0 / slices)))
		end
	end
	rl.rlEnd()
end

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	earthRotation = earthRotation + (5.0 * rotationSpeed)
	earthOrbitRotation = earthOrbitRotation + (365 / 360.0 * (5.0 * rotationSpeed) * rotationSpeed)
	moonRotation = moonRotation + (2.0 * rotationSpeed)
	moonOrbitRotation = moonOrbitRotation + (8.0 * rotationSpeed)

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	rl.rlPushMatrix()
	rl.rlScalef(sunRadius, sunRadius, sunRadius)
	DrawSphereBasic(rl.GOLD)
	rl.rlPopMatrix()

	rl.rlPushMatrix()
	rl.rlRotatef(earthOrbitRotation, 0, 1, 0)
	rl.rlTranslatef(earthOrbitRadius, 0, 0)

	rl.rlPushMatrix()
	rl.rlRotatef(earthRotation, 0.25, 1.0, 0.0)
	rl.rlScalef(earthRadius, earthRadius, earthRadius)
	DrawSphereBasic(rl.BLUE)
	rl.rlPopMatrix()

	rl.rlRotatef(moonOrbitRotation, 0, 1, 0)
	rl.rlTranslatef(moonOrbitRadius, 0, 0)
	rl.rlRotatef(moonRotation, 0, 1, 0)
	rl.rlScalef(moonRadius, moonRadius, moonRadius)
	DrawSphereBasic(rl.LIGHTGRAY)
	rl.rlPopMatrix()

	rl.DrawCircle3D(rl.new("Vector3", 0, 0, 0), earthOrbitRadius, rl.new("Vector3", 1, 0, 0), 90.0, rl.Fade(rl.RED, 0.5))
	rl.DrawGrid(20, 1.0)

	rl.EndMode3D()

	rl.DrawText("EARTH ORBITING AROUND THE SUN!", 400, 10, 20, rl.MAROON)
	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
