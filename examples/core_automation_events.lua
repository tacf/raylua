-- raylib [core] example - automation events

local GRAVITY = 400
local PLAYER_JUMP_SPD = 350.0
local PLAYER_HOR_SPD = 200.0
local MAX_ENVIRONMENT_ELEMENTS = 5

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - automation events")

-- Define player
local player = {
	position = rl.new("Vector2", 400, 280),
	speed = 0,
	canJump = false
}

-- Define environment elements (platforms)
local envElements = {
	{ rect = rl.new("Rectangle", 0, 0, 1000, 400), blocking = 0, color = rl.LIGHTGRAY },
	{ rect = rl.new("Rectangle", 0, 400, 1000, 200), blocking = 1, color = rl.GRAY },
	{ rect = rl.new("Rectangle", 300, 200, 400, 10), blocking = 1, color = rl.GRAY },
	{ rect = rl.new("Rectangle", 250, 300, 100, 10), blocking = 1, color = rl.GRAY },
	{ rect = rl.new("Rectangle", 650, 300, 100, 10), blocking = 1, color = rl.GRAY }
}

-- Define camera
local camera = rl.new("Camera2D", {
	offset = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0),
	target = rl.new("Vector2", player.position.x, player.position.y),
	rotation = 0,
	zoom = 1
})

-- Automation events
local aelist = rl.LoadAutomationEventList(0)
rl.SetAutomationEventList(aelist)
local eventRecording = false
local eventPlaying = false

local frameCounter = 0
local playFrameCounter = 0
local currentPlayFrame = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	local deltaTime = 0.015

	-- Dropped files logic
	if rl.IsFileDropped() then
		local droppedFiles = rl.LoadDroppedFiles()

		if rl.IsFileExtension(droppedFiles.paths[0], ".txt;.rae") then
			rl.UnloadAutomationEventList(aelist)
			aelist = rl.LoadAutomationEventList(droppedFiles.paths[0])

			eventRecording = false
			eventPlaying = true
			playFrameCounter = 0
			currentPlayFrame = 0

			player.position = rl.new("Vector2", 400, 280)
			player.speed = 0
			player.canJump = false

			camera.target = rl.new("Vector2", player.position.x, player.position.y)
			camera.offset = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0)
			camera.rotation = 0
			camera.zoom = 1
		end

		rl.UnloadDroppedFiles(droppedFiles)
	end

	-- Update player
	if rl.IsKeyDown(rl.KEY_LEFT) then player.position.x = player.position.x - PLAYER_HOR_SPD * deltaTime end
	if rl.IsKeyDown(rl.KEY_RIGHT) then player.position.x = player.position.x + PLAYER_HOR_SPD * deltaTime end
	if rl.IsKeyDown(rl.KEY_SPACE) and player.canJump then
		player.speed = -PLAYER_JUMP_SPD
		player.canJump = false
	end

	local hitObstacle = false
	for i = 1, MAX_ENVIRONMENT_ELEMENTS do
		local element = envElements[i]
		if element.blocking == 1 and
			element.rect.x <= player.position.x and
			element.rect.x + element.rect.width >= player.position.x and
			element.rect.y >= player.position.y and
			element.rect.y <= player.position.y + player.speed * deltaTime then
			hitObstacle = true
			player.speed = 0.0
			player.position.y = element.rect.y
		end
	end

	if not hitObstacle then
		player.position.y = player.position.y + player.speed * deltaTime
		player.speed = player.speed + GRAVITY * deltaTime
		player.canJump = false
	else
		player.canJump = true
	end

	if rl.IsKeyPressed(rl.KEY_R) then
		player.position = rl.new("Vector2", 400, 280)
		player.speed = 0
		player.canJump = false

		camera.target = rl.new("Vector2", player.position.x, player.position.y)
		camera.offset = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0)
		camera.rotation = 0
		camera.zoom = 1
	end

	-- Events playing
	if eventPlaying then
		while playFrameCounter == aelist.events[currentPlayFrame].frame do
			rl.PlayAutomationEvent(aelist.events[currentPlayFrame])
			currentPlayFrame = currentPlayFrame + 1

			if currentPlayFrame == aelist.count then
				eventPlaying = false
				currentPlayFrame = 0
				playFrameCounter = 0
				rl.TraceLog(rl.LOG_INFO, "FINISH PLAYING!")
				break
			end
		end
		playFrameCounter = playFrameCounter + 1
	end

	-- Update camera
	camera.target = rl.new("Vector2", player.position.x, player.position.y)
	camera.offset = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0)
	local minX, minY = 1000, 1000
	local maxX, maxY = -1000, -1000

	camera.zoom = camera.zoom + rl.GetMouseWheelMove() * 0.05
	if camera.zoom > 3.0 then camera.zoom = 3.0
	elseif camera.zoom < 0.25 then camera.zoom = 0.25 end

	for i = 1, MAX_ENVIRONMENT_ELEMENTS do
		local element = envElements[i]
		if element.rect.x < minX then minX = element.rect.x end
		if element.rect.x + element.rect.width > maxX then maxX = element.rect.x + element.rect.width end
		if element.rect.y < minY then minY = element.rect.y end
		if element.rect.y + element.rect.height > maxY then maxY = element.rect.y + element.rect.height end
	end

	local max = rl.GetWorldToScreen2D(rl.new("Vector2", maxX, maxY), camera)
	local min = rl.GetWorldToScreen2D(rl.new("Vector2", minX, minY), camera)

	if max.x < screenWidth then camera.offset.x = screenWidth - (max.x - screenWidth / 2) end
	if max.y < screenHeight then camera.offset.y = screenHeight - (max.y - screenHeight / 2) end
	if min.x > 0 then camera.offset.x = screenWidth / 2 - min.x end
	if min.y > 0 then camera.offset.y = screenHeight / 2 - min.y end

	-- Events management
	if rl.IsKeyPressed(rl.KEY_S) then
		if not eventPlaying then
			if eventRecording then
				rl.StopAutomationEventRecording()
				eventRecording = false
				rl.ExportAutomationEventList(aelist, "automation.rae")
				rl.TraceLog(rl.LOG_INFO, "RECORDED FRAMES: " .. aelist.count)
			else
				rl.SetAutomationEventBaseFrame(180)
				rl.StartAutomationEventRecording()
				eventRecording = true
			end
		end
	elseif rl.IsKeyPressed(rl.KEY_A) then
		if not eventRecording and aelist.count > 0 then
			eventPlaying = true
			playFrameCounter = 0
			currentPlayFrame = 0

			player.position = rl.new("Vector2", 400, 280)
			player.speed = 0
			player.canJump = false

			camera.target = rl.new("Vector2", player.position.x, player.position.y)
			camera.offset = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0)
			camera.rotation = 0
			camera.zoom = 1
		end
	end

	if eventRecording or eventPlaying then
		frameCounter = frameCounter + 1
	else
		frameCounter = 0
	end

	-- Draw
	rl.BeginDrawing()
		rl.ClearBackground(rl.LIGHTGRAY)

		rl.BeginMode2D(camera)
			-- Draw environment elements
			for i = 1, MAX_ENVIRONMENT_ELEMENTS do
				rl.DrawRectangleRec(envElements[i].rect, envElements[i].color)
			end

			-- Draw player rectangle
			rl.DrawRectangleRec(rl.new("Rectangle", player.position.x - 20, player.position.y - 40, 40, 40), rl.RED)
		rl.EndMode2D()

		-- Draw game controls
		rl.DrawRectangle(10, 10, 290, 145, rl.Fade(rl.SKYBLUE, 0.5))
		rl.DrawRectangleLines(10, 10, 290, 145, rl.Fade(rl.BLUE, 0.8))

		rl.DrawText("Controls:", 20, 20, 10, rl.BLACK)
		rl.DrawText("- RIGHT | LEFT: Player movement", 30, 40, 10, rl.DARKGRAY)
		rl.DrawText("- SPACE: Player jump", 30, 60, 10, rl.DARKGRAY)
		rl.DrawText("- R: Reset game state", 30, 80, 10, rl.DARKGRAY)

		rl.DrawText("- S: START/STOP RECORDING INPUT EVENTS", 30, 110, 10, rl.BLACK)
		rl.DrawText("- A: REPLAY LAST RECORDED INPUT EVENTS", 30, 130, 10, rl.BLACK)

		-- Draw automation events recording indicator
		if eventRecording then
			rl.DrawRectangle(10, 160, 290, 30, rl.Fade(rl.RED, 0.3))
			rl.DrawRectangleLines(10, 160, 290, 30, rl.Fade(rl.MAROON, 0.8))
			rl.DrawCircle(30, 175, 10, rl.MAROON)

			if math.floor(frameCounter / 15) % 2 == 1 then
				rl.DrawText("RECORDING EVENTS... [" .. aelist.count .. "]", 50, 170, 10, rl.MAROON)
			end
		elseif eventPlaying then
			rl.DrawRectangle(10, 160, 290, 30, rl.Fade(rl.LIME, 0.3))
			rl.DrawRectangleLines(10, 160, 290, 30, rl.Fade(rl.DARKGREEN, 0.8))
			rl.DrawTriangle(
				rl.new("Vector2", 20, 165),
				rl.new("Vector2", 20, 185),
				rl.new("Vector2", 40, 175),
				rl.DARKGREEN
			)

			if math.floor(frameCounter / 15) % 2 == 1 then
				rl.DrawText("PLAYING RECORDED EVENTS... [" .. currentPlayFrame .. "]", 50, 170, 10, rl.DARKGREEN)
			end
		end
	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
