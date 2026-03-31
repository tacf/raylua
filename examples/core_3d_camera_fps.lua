local GRAVITY = 32.0
local MAX_SPEED = 20.0
local CROUCH_SPEED = 5.0
local JUMP_FORCE = 12.0
local MAX_ACCEL = 150.0
local FRICTION = 0.86
local AIR_DRAG = 0.98
local CONTROL = 15.0
local CROUCH_HEIGHT = 0.0
local STAND_HEIGHT = 1.0
local BOTTOM_HEIGHT = 0.5

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera fps")

local sensitivity = rl.new("Vector2", 0.001, 0.001)

local player = {
	position = rl.new("Vector3", 0, 0, 0),
	velocity = rl.new("Vector3", 0, 0, 0),
	dir = rl.new("Vector3", 0, 0, 0),
	isGrounded = false,
}

local lookRotation = rl.new("Vector2", 0, 0)
local headTimer = 0.0
local walkLerp = 0.0
local headLerp = STAND_HEIGHT
local lean = rl.new("Vector2", 0, 0)

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 0, BOTTOM_HEIGHT + headLerp, 0),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 60,
	type = rl.CAMERA_PERSPECTIVE,
})

local function UpdateBody(body, rot, side, forward, jumpPressed, crouchHold)
	local input = rl.new("Vector2", side, -forward)

	local delta = rl.GetFrameTime()

	if not body.isGrounded then
		body.velocity = rl.new("Vector3", body.velocity.x, body.velocity.y - GRAVITY * delta, body.velocity.z)
	end

	if body.isGrounded and jumpPressed then
		body.velocity = rl.new("Vector3", body.velocity.x, JUMP_FORCE, body.velocity.z)
		body.isGrounded = false
	end

	local front = rl.new("Vector3", math.sin(rot), 0, math.cos(rot))
	local right = rl.new("Vector3", math.cos(-rot), 0, math.sin(-rot))

	local desiredDir = rl.new("Vector3",
		input.x * right.x + input.y * front.x,
		0,
		input.x * right.z + input.y * front.z)

	body.dir = rl.Vector3Lerp(body.dir, desiredDir, CONTROL * delta)

	local decel = body.isGrounded and FRICTION or AIR_DRAG
	local hvel = rl.new("Vector3", body.velocity.x * decel, 0, body.velocity.z * decel)

	local hvelLength = rl.Vector3Length(hvel)
	if hvelLength < MAX_SPEED * 0.01 then
		hvel = rl.new("Vector3", 0, 0, 0)
	end

	local speed = rl.Vector3DotProduct(hvel, body.dir)

	local maxSpeed = crouchHold and CROUCH_SPEED or MAX_SPEED
	local accel = rl.Clamp(maxSpeed - speed, 0, MAX_ACCEL * delta)
	hvel = rl.new("Vector3", hvel.x + body.dir.x * accel, hvel.y, hvel.z + body.dir.z * accel)

	body.velocity = rl.new("Vector3", hvel.x, body.velocity.y, hvel.z)

	body.position = rl.new("Vector3",
		body.position.x + body.velocity.x * delta,
		body.position.y + body.velocity.y * delta,
		body.position.z + body.velocity.z * delta)

	if body.position.y <= 0.0 then
		body.position = rl.new("Vector3", body.position.x, 0, body.position.z)
		body.velocity = rl.new("Vector3", body.velocity.x, 0, body.velocity.z)
		body.isGrounded = true
	end
end

local function UpdateCameraFPS(cam)
	local up = rl.new("Vector3", 0, 1, 0)
	local targetOffset = rl.new("Vector3", 0, 0, -1)

	local yaw = rl.Vector3RotateByAxisAngle(targetOffset, up, lookRotation.x)

	local maxAngleUp = rl.Vector3Angle(up, yaw)
	maxAngleUp = maxAngleUp - 0.001
	if -lookRotation.y > maxAngleUp then
		lookRotation = rl.new("Vector2", lookRotation.x, -maxAngleUp)
	end

	local maxAngleDown = rl.Vector3Angle(rl.Vector3Negate(up), yaw)
	maxAngleDown = maxAngleDown * -1.0
	maxAngleDown = maxAngleDown + 0.001
	if -lookRotation.y < maxAngleDown then
		lookRotation = rl.new("Vector2", lookRotation.x, -maxAngleDown)
	end

	local right = rl.Vector3Normalize(rl.Vector3CrossProduct(yaw, up))

	local pitchAngle = -lookRotation.y - lean.y
	pitchAngle = rl.Clamp(pitchAngle, -math.pi / 2 + 0.0001, math.pi / 2 - 0.0001)
	local pitch = rl.Vector3RotateByAxisAngle(yaw, right, pitchAngle)

	local headSin = math.sin(headTimer * math.pi)
	local headCos = math.cos(headTimer * math.pi)
	local stepRotation = 0.01
	cam.up = rl.Vector3RotateByAxisAngle(up, pitch, headSin * stepRotation + lean.x)

	local bobSide = 0.1
	local bobUp = 0.15
	local bobbing = rl.Vector3Scale(right, headSin * bobSide)
	bobbing = rl.new("Vector3", bobbing.x, math.abs(headCos * bobUp), bobbing.z)

	cam.position = rl.Vector3Add(cam.position, rl.Vector3Scale(bobbing, walkLerp))
	cam.target = rl.Vector3Add(cam.position, pitch)
end

local function DrawLevel()
	local floorExtent = 25
	local tileSize = 5.0
	local tileColor1 = rl.new("Color", 150, 200, 200, 255)

	for y = -floorExtent, floorExtent - 1 do
		for x = -floorExtent, floorExtent - 1 do
			if (y % 2 == 1) and (x % 2 == 1) then
				rl.DrawPlane(rl.new("Vector3", x * tileSize, 0, y * tileSize),
					rl.new("Vector2", tileSize, tileSize), tileColor1)
			elseif (y % 2 == 0) and (x % 2 == 0) then
				rl.DrawPlane(rl.new("Vector3", x * tileSize, 0, y * tileSize),
					rl.new("Vector2", tileSize, tileSize), rl.LIGHTGRAY)
			end
		end
	end

	local towerSize = rl.new("Vector3", 16, 32, 16)
	local towerColor = rl.new("Color", 150, 200, 200, 255)

	local towerPos = rl.new("Vector3", 16, 16, 16)
	rl.DrawCubeV(towerPos, towerSize, towerColor)
	rl.DrawCubeWiresV(towerPos, towerSize, rl.DARKBLUE)

	towerPos = rl.new("Vector3", -16, 16, 16)
	rl.DrawCubeV(towerPos, towerSize, towerColor)
	rl.DrawCubeWiresV(towerPos, towerSize, rl.DARKBLUE)

	towerPos = rl.new("Vector3", -16, 16, -16)
	rl.DrawCubeV(towerPos, towerSize, towerColor)
	rl.DrawCubeWiresV(towerPos, towerSize, rl.DARKBLUE)

	towerPos = rl.new("Vector3", 16, 16, -16)
	rl.DrawCubeV(towerPos, towerSize, towerColor)
	rl.DrawCubeWiresV(towerPos, towerSize, rl.DARKBLUE)

	rl.DrawSphere(rl.new("Vector3", 300, 300, 0), 100, rl.new("Color", 255, 0, 0, 255))
end

rl.DisableCursor()
rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	-- Update
	local mouseDelta = rl.GetMouseDelta()
	lookRotation = rl.new("Vector2",
		lookRotation.x - mouseDelta.x * sensitivity.x,
		lookRotation.y + mouseDelta.y * sensitivity.y)

	local sideway = (rl.IsKeyDown(rl.KEY_D) and 1 or 0) - (rl.IsKeyDown(rl.KEY_A) and 1 or 0)
	local forward = (rl.IsKeyDown(rl.KEY_W) and 1 or 0) - (rl.IsKeyDown(rl.KEY_S) and 1 or 0)
	local crouching = rl.IsKeyDown(rl.KEY_LEFT_CONTROL)
	UpdateBody(player, lookRotation.x, sideway, forward, rl.IsKeyPressed(rl.KEY_SPACE), crouching)

	local delta = rl.GetFrameTime()
	headLerp = rl.Lerp(headLerp, crouching and CROUCH_HEIGHT or STAND_HEIGHT, 20.0 * delta)
	camera.position = rl.new("Vector3",
		player.position.x,
		player.position.y + (BOTTOM_HEIGHT + headLerp),
		player.position.z)

	if player.isGrounded and ((forward ~= 0) or (sideway ~= 0)) then
		headTimer = headTimer + delta * 3.0
		walkLerp = rl.Lerp(walkLerp, 1.0, 10.0 * delta)
		camera.fovy = rl.Lerp(camera.fovy, 55.0, 5.0 * delta)
	else
		walkLerp = rl.Lerp(walkLerp, 0.0, 10.0 * delta)
		camera.fovy = rl.Lerp(camera.fovy, 60.0, 5.0 * delta)
	end

	lean = rl.new("Vector2",
		rl.Lerp(lean.x, sideway * 0.02, 10.0 * delta),
		rl.Lerp(lean.y, forward * 0.015, 10.0 * delta))

	UpdateCameraFPS(camera)

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	DrawLevel()
	rl.EndMode3D()

	rl.DrawRectangle(5, 5, 330, 75, rl.Fade(rl.SKYBLUE, 0.5))
	rl.DrawRectangleLines(5, 5, 330, 75, rl.BLUE)

	rl.DrawText("Camera controls:", 15, 15, 10, rl.BLACK)
	rl.DrawText("- Move keys: W, A, S, D, Space, Left-Ctrl", 15, 30, 10, rl.BLACK)
	rl.DrawText("- Look around: arrow keys or mouse", 15, 45, 10, rl.BLACK)
	rl.DrawText(string.format("- Velocity Len: (%06.3f)", rl.Vector2Length(rl.new("Vector2", player.velocity.x, player.velocity.z))), 15, 60, 10, rl.BLACK)

	rl.EndDrawing()
end

rl.CloseWindow()
