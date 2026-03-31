--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_2d_camera_platformer.c

]]

local G = 400
local PLAYER_JUMP_SPD = 350.0
local PLAYER_HOR_SPD = 200.0

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera platformer")

local player = {
	position = rl.new("Vector2", 400, 280),
	speed = 0,
	canJump = false,
}

local envItems = {
	{ rect = rl.new("Rectangle", 0, 0, 1000, 400), blocking = false, color = rl.LIGHTGRAY },
	{ rect = rl.new("Rectangle", 0, 400, 1000, 200), blocking = true, color = rl.GRAY },
	{ rect = rl.new("Rectangle", 300, 200, 400, 10), blocking = true, color = rl.GRAY },
	{ rect = rl.new("Rectangle", 250, 300, 100, 10), blocking = true, color = rl.GRAY },
	{ rect = rl.new("Rectangle", 650, 300, 100, 10), blocking = true, color = rl.GRAY },
}

local envItemsLength = #envItems

local camera = rl.new("Camera2D", {
	offset = rl.new("Vector2", screenWidth / 2, screenHeight / 2),
	target = rl.new("Vector2", player.position.x, player.position.y),
	rotation = 0,
	zoom = 1,
})

local function UpdatePlayer(p, items, itemsLen, delta)
	if rl.IsKeyDown(rl.KEY_LEFT) then p.position.x = p.position.x - PLAYER_HOR_SPD * delta end
	if rl.IsKeyDown(rl.KEY_RIGHT) then p.position.x = p.position.x + PLAYER_HOR_SPD * delta end
	if rl.IsKeyDown(rl.KEY_SPACE) and p.canJump then
		p.speed = -PLAYER_JUMP_SPD
		p.canJump = false
	end

	local hitObstacle = false
	for i = 1, itemsLen do
		local ei = items[i]
		if ei.blocking and
			ei.rect.x <= p.position.x and
			ei.rect.x + ei.rect.width >= p.position.x and
			ei.rect.y >= p.position.y and
			ei.rect.y <= p.position.y + p.speed * delta then
			hitObstacle = true
			p.speed = 0.0
			p.position.y = ei.rect.y
			break
		end
	end

	if not hitObstacle then
		p.position.y = p.position.y + p.speed * delta
		p.speed = p.speed + G * delta
		p.canJump = false
	else
		p.canJump = true
	end
end

local function UpdateCameraCenter(cam, p, items, itemsLen, delta, width, height)
	cam.offset = rl.new("Vector2", width / 2, height / 2)
	cam.target = p.position
end

local function UpdateCameraCenterInsideMap(cam, p, items, itemsLen, delta, width, height)
	cam.target = p.position
	cam.offset = rl.new("Vector2", width / 2, height / 2)

	local minX, minY = 1000, 1000
	local maxX, maxY = -1000, -1000

	for i = 1, itemsLen do
		local ei = items[i]
		if ei.rect.x < minX then minX = ei.rect.x end
		if ei.rect.x + ei.rect.width > maxX then maxX = ei.rect.x + ei.rect.width end
		if ei.rect.y < minY then minY = ei.rect.y end
		if ei.rect.y + ei.rect.height > maxY then maxY = ei.rect.y + ei.rect.height end
	end

	local max = rl.GetWorldToScreen2D(rl.new("Vector2", maxX, maxY), cam)
	local min = rl.GetWorldToScreen2D(rl.new("Vector2", minX, minY), cam)

	if max.x < width then cam.offset.x = width - (max.x - width / 2) end
	if max.y < height then cam.offset.y = height - (max.y - height / 2) end
	if min.x > 0 then cam.offset.x = width / 2 - min.x end
	if min.y > 0 then cam.offset.y = height / 2 - min.y end
end

local minSpeed = 30
local minEffectLength = 10
local fractionSpeed = 0.8

local function UpdateCameraCenterSmoothFollow(cam, p, items, itemsLen, delta, width, height)
	cam.offset = rl.new("Vector2", width / 2, height / 2)
	local diff = rl.new("Vector2", p.position.x - cam.target.x, p.position.y - cam.target.y)
	local length = math.sqrt(diff.x * diff.x + diff.y * diff.y)

	if length > minEffectLength then
		local speed = math.max(fractionSpeed * length, minSpeed)
		cam.target = rl.new("Vector2",
			cam.target.x + diff.x * speed * delta / length,
			cam.target.y + diff.y * speed * delta / length)
	end
end

local evenOutSpeed = 700
local eveningOut = false
local evenOutTarget = 0

local function UpdateCameraEvenOutOnLanding(cam, p, items, itemsLen, delta, width, height)
	cam.offset = rl.new("Vector2", width / 2, height / 2)
	cam.target = rl.new("Vector2", p.position.x, cam.target.y)

	if eveningOut then
		if evenOutTarget > cam.target.y then
			cam.target = rl.new("Vector2", cam.target.x, cam.target.y + evenOutSpeed * delta)
			if cam.target.y > evenOutTarget then
				cam.target = rl.new("Vector2", cam.target.x, evenOutTarget)
				eveningOut = false
			end
		else
			cam.target = rl.new("Vector2", cam.target.x, cam.target.y - evenOutSpeed * delta)
			if cam.target.y < evenOutTarget then
				cam.target = rl.new("Vector2", cam.target.x, evenOutTarget)
				eveningOut = false
			end
		end
	else
		if p.canJump and p.speed == 0 and p.position.y ~= cam.target.y then
			eveningOut = true
			evenOutTarget = p.position.y
		end
	end
end

local bbox = { x = 0.2, y = 0.2 }

local function UpdateCameraPlayerBoundsPush(cam, p, items, itemsLen, delta, width, height)
	local bboxWorldMin = rl.GetScreenToWorld2D(
		rl.new("Vector2", (1 - bbox.x) * 0.5 * width, (1 - bbox.y) * 0.5 * height), cam)
	local bboxWorldMax = rl.GetScreenToWorld2D(
		rl.new("Vector2", (1 + bbox.x) * 0.5 * width, (1 + bbox.y) * 0.5 * height), cam)
	cam.offset = rl.new("Vector2", (1 - bbox.x) * 0.5 * width, (1 - bbox.y) * 0.5 * height)

	if p.position.x < bboxWorldMin.x then cam.target = rl.new("Vector2", p.position.x, cam.target.y) end
	if p.position.y < bboxWorldMin.y then cam.target = rl.new("Vector2", cam.target.x, p.position.y) end
	if p.position.x > bboxWorldMax.x then cam.target = rl.new("Vector2", bboxWorldMin.x + (p.position.x - bboxWorldMax.x), cam.target.y) end
	if p.position.y > bboxWorldMax.y then cam.target = rl.new("Vector2", cam.target.x, bboxWorldMin.y + (p.position.y - bboxWorldMax.y)) end
end

local cameraUpdaters = {
	UpdateCameraCenter,
	UpdateCameraCenterInsideMap,
	UpdateCameraCenterSmoothFollow,
	UpdateCameraEvenOutOnLanding,
	UpdateCameraPlayerBoundsPush,
}

local cameraOption = 1
local cameraUpdatersLength = #cameraUpdaters

local cameraDescriptions = {
	"Follow player center",
	"Follow player center, but clamp to map edges",
	"Follow player center; smoothed",
	"Follow player center horizontally; update player center vertically after landing",
	"Player push camera on getting too close to screen edge",
}

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	local deltaTime = rl.GetFrameTime()

	UpdatePlayer(player, envItems, envItemsLength, deltaTime)

	camera.zoom = camera.zoom + rl.GetMouseWheelMove() * 0.05

	if camera.zoom > 3.0 then camera.zoom = 3.0
	elseif camera.zoom < 0.25 then camera.zoom = 0.25
	end

	if rl.IsKeyPressed(rl.KEY_R) then
		camera.zoom = 1.0
		player.position = rl.new("Vector2", 400, 280)
	end

	if rl.IsKeyPressed(rl.KEY_C) then
		cameraOption = (cameraOption % cameraUpdatersLength) + 1
	end

	cameraUpdaters[cameraOption](camera, player, envItems, envItemsLength, deltaTime, screenWidth, screenHeight)

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.LIGHTGRAY)

	rl.BeginMode2D(camera)

	for i = 1, envItemsLength do
		rl.DrawRectangleRec(envItems[i].rect, envItems[i].color)
	end

	local playerRect = rl.new("Rectangle", player.position.x - 20, player.position.y - 40, 40, 40)
	rl.DrawRectangleRec(playerRect, rl.RED)

	rl.DrawCircleV(player.position, 5.0, rl.GOLD)

	rl.EndMode2D()

	rl.DrawText("Controls:", 20, 20, 10, rl.BLACK)
	rl.DrawText("- Right/Left to move", 40, 40, 10, rl.DARKGRAY)
	rl.DrawText("- Space to jump", 40, 60, 10, rl.DARKGRAY)
	rl.DrawText("- Mouse Wheel to Zoom in-out", 40, 80, 10, rl.DARKGRAY)
	rl.DrawText("- R to reset position + zoom", 40, 100, 10, rl.DARKGRAY)
	rl.DrawText("- C to change camera mode", 40, 120, 10, rl.DARKGRAY)
	rl.DrawText("Current camera mode:", 20, 140, 10, rl.BLACK)
	rl.DrawText(cameraDescriptions[cameraOption], 40, 160, 10, rl.DARKGRAY)

	rl.EndDrawing()
end

rl.CloseWindow()
