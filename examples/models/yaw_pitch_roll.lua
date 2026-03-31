--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/models/models_yaw_pitch_roll.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - yaw pitch roll")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 0, 50, -120),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 30,
	type = rl.CAMERA_PERSPECTIVE,
})

local model = rl.LoadModel("raylib/examples/models/resources/models/obj/plane.obj")
local texture = rl.LoadTexture("raylib/examples/models/resources/models/obj/plane_diffuse.png")

rl.SetTextureWrap(texture, rl.TEXTURE_WRAP_REPEAT)

model.materials[0].maps[rl.MATERIAL_MAP_DIFFUSE].texture = texture

local pitch = 0.0
local roll = 0.0
local yaw = 0.0

local DEG2RAD = math.pi / 180.0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsKeyDown(rl.KEY_DOWN) then
		pitch = pitch + 0.6
	elseif rl.IsKeyDown(rl.KEY_UP) then
		pitch = pitch - 0.6
	else
		if pitch > 0.3 then pitch = pitch - 0.3
		elseif pitch < -0.3 then pitch = pitch + 0.3
		end
	end

	if rl.IsKeyDown(rl.KEY_S) then
		yaw = yaw - 1.0
	elseif rl.IsKeyDown(rl.KEY_A) then
		yaw = yaw + 1.0
	else
		if yaw > 0 then yaw = yaw - 0.5
		elseif yaw < 0 then yaw = yaw + 0.5
		end
	end

	if rl.IsKeyDown(rl.KEY_LEFT) then
		roll = roll - 1.0
	elseif rl.IsKeyDown(rl.KEY_RIGHT) then
		roll = roll + 1.0
	else
		if roll > 0 then roll = roll - 0.5
		elseif roll < 0 then roll = roll + 0.5
		end
	end

	model.transform = rl.MatrixRotateXYZ(rl.new("Vector3", DEG2RAD * pitch, DEG2RAD * yaw, DEG2RAD * roll))

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	rl.DrawModel(model, rl.new("Vector3", 0, -8, 0), 1.0, rl.WHITE)
	rl.DrawGrid(10, 10.0)

	rl.EndMode3D()

	rl.DrawRectangle(30, 370, 260, 70, rl.Fade(rl.GREEN, 0.5))
	rl.DrawRectangleLines(30, 370, 260, 70, rl.Fade(rl.DARKGREEN, 0.5))
	rl.DrawText("Pitch controlled with: KEY_UP / KEY_DOWN", 40, 380, 10, rl.DARKGRAY)
	rl.DrawText("Roll controlled with: KEY_LEFT / KEY_RIGHT", 40, 400, 10, rl.DARKGRAY)
	rl.DrawText("Yaw controlled with: KEY_A / KEY_S", 40, 420, 10, rl.DARKGRAY)

	rl.DrawText("(c) WWI Plane Model created by GiaHanLam", screenWidth - 240, screenHeight - 20, 10, rl.DARKGRAY)

	rl.EndDrawing()
end

rl.UnloadModel(model)
rl.UnloadTexture(texture)
rl.CloseWindow()
