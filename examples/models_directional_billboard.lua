local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylua [models] example - directional billboard")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 2.0, 1.0, 2.0),
	target = rl.new("Vector3", 0.0, 0.5, 0.0),
	up = rl.new("Vector3", 0.0, 1.0, 0.0),
	fovy = 45.0,
	type = rl.CAMERA_PERSPECTIVE
})

local skillbot = rl.LoadTexture("resources/skillbot.png")

local anim_timer = 0.0
local anim = 0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, rl.CAMERA_ORBITAL)

	anim_timer = anim_timer + rl.GetFrameTime()

	if anim_timer > 0.5 then
		anim_timer = 0.0
		anim = anim + 1
	end

	if anim >= 4 then anim = 0 end

	local dir = math.floor(((rl.Vector2Angle(rl.new("Vector2", 2.0, 0.0), rl.new("Vector2", camera.position.x, camera.position.z)) / math.pi) * 4.0) + 0.25)

	if dir < 0.0 then
		dir = 8.0 - math.abs(dir)
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	rl.DrawGrid(10, 1.0)

	rl.DrawBillboardPro(camera, skillbot,
		rl.new("Rectangle", 0.0 + (anim * 24.0), 0.0 + (dir * 24.0), 24.0, 24.0),
		rl.Vector3Zero(),
		rl.new("Vector3", 0.0, 1.0, 0.0),
		rl.Vector2One(),
		rl.new("Vector2", 0.5, 0.0),
		0,
		rl.WHITE)

	rl.EndMode3D()

	rl.DrawText(string.format("animation: %d", anim), 10, 10, 20, rl.DARKGRAY)
	rl.DrawText(string.format("direction frame: %.0f", dir), 10, 40, 20, rl.DARKGRAY)

	rl.EndDrawing()
end

rl.UnloadTexture(skillbot)

rl.CloseWindow()