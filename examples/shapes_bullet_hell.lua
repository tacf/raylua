--[[
    raylib [shapes] example - bullet hell

    Example complexity rating: [★☆☆☆] 1/4

    Example originally created with raylib 5.6, last time updated with raylib 5.6

    Example contributed by Zero (@zerohorsepower) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2025 Zero (@zerohorsepower)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - bullet hell")

local MAX_BULLETS = 500000

-- Bullets definition
local bullets = {}
local bulletCount = 0
local bulletDisabledCount = 0
local bulletRadius = 10
local bulletSpeed = 3.0
local bulletRows = 6
local bulletColor = { rl.RED, rl.BLUE }

-- Spawner variables
local baseDirection = 0
local angleIncrement = 5
local spawnCooldown = 2
local spawnCooldownTimer = spawnCooldown

-- Magic circle
local magicCircleRotation = 0

-- Used on performance drawing
local bulletTexture = rl.LoadRenderTexture(24, 24)

-- Draw circle to bullet texture, then draw bullet using DrawTexture()
rl.BeginTextureMode(bulletTexture)
rl.DrawCircle(12, 12, bulletRadius, rl.WHITE)
rl.DrawCircleLines(12, 12, bulletRadius, rl.BLACK)
rl.EndTextureMode()

local drawInPerformanceMode = true

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- Reset the bullet index
	if bulletCount >= MAX_BULLETS then
		bulletCount = 0
		bulletDisabledCount = 0
	end

	spawnCooldownTimer = spawnCooldownTimer - 1
	if spawnCooldownTimer < 0 then
		spawnCooldownTimer = spawnCooldown

		-- Spawn bullets
		local degreesPerRow = 360.0 / bulletRows
		for row = 0, bulletRows - 1 do
			if bulletCount < MAX_BULLETS then
				local bulletDirection = baseDirection + (degreesPerRow * row)
				local radDir = math.rad(bulletDirection)

				bullets[bulletCount] = {
					position = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0),
					acceleration = rl.new("Vector2",
						bulletSpeed * math.cos(radDir),
						bulletSpeed * math.sin(radDir)
					),
					disabled = false,
					color = bulletColor[row % 2 + 1],
				}

				bulletCount = bulletCount + 1
			end
		end

		baseDirection = baseDirection + angleIncrement
	end

	-- Update bullets position based on its acceleration
	for i = 0, bulletCount - 1 do
		if not bullets[i].disabled then
			bullets[i].position.x = bullets[i].position.x + bullets[i].acceleration.x
			bullets[i].position.y = bullets[i].position.y + bullets[i].acceleration.y

			if (bullets[i].position.x < -bulletRadius * 2) or
				(bullets[i].position.x > screenWidth + bulletRadius * 2) or
				(bullets[i].position.y < -bulletRadius * 2) or
				(bullets[i].position.y > screenHeight + bulletRadius * 2) then
				bullets[i].disabled = true
				bulletDisabledCount = bulletDisabledCount + 1
			end
		end
	end

	-- Input logic
	if (rl.IsKeyPressed(rl.KEY_RIGHT) or rl.IsKeyPressed(rl.KEY_D)) and (bulletRows < 359) then bulletRows = bulletRows + 1 end
	if (rl.IsKeyPressed(rl.KEY_LEFT) or rl.IsKeyPressed(rl.KEY_A)) and (bulletRows > 1) then bulletRows = bulletRows - 1 end
	if rl.IsKeyPressed(rl.KEY_UP) or rl.IsKeyPressed(rl.KEY_W) then bulletSpeed = bulletSpeed + 0.25 end
	if (rl.IsKeyPressed(rl.KEY_DOWN) or rl.IsKeyPressed(rl.KEY_S)) and (bulletSpeed > 0.50) then bulletSpeed = bulletSpeed - 0.25 end
	if rl.IsKeyPressed(rl.KEY_Z) and (spawnCooldown > 1) then spawnCooldown = spawnCooldown - 1 end
	if rl.IsKeyPressed(rl.KEY_X) then spawnCooldown = spawnCooldown + 1 end
	if rl.IsKeyPressed(rl.KEY_ENTER) then drawInPerformanceMode = not drawInPerformanceMode end

	if rl.IsKeyDown(rl.KEY_SPACE) then
		angleIncrement = angleIncrement + 1
		angleIncrement = angleIncrement % 360
	end

	if rl.IsKeyPressed(rl.KEY_C) then
		bulletCount = 0
		bulletDisabledCount = 0
	end

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	-- Draw magic circle
	magicCircleRotation = magicCircleRotation + 1
	rl.DrawRectanglePro(
		rl.new("Rectangle", screenWidth / 2.0, screenHeight / 2.0, 120, 120),
		rl.new("Vector2", 60.0, 60.0), magicCircleRotation, rl.PURPLE)
	rl.DrawRectanglePro(
		rl.new("Rectangle", screenWidth / 2.0, screenHeight / 2.0, 120, 120),
		rl.new("Vector2", 60.0, 60.0), magicCircleRotation + 45, rl.PURPLE)
	rl.DrawCircleLines(screenWidth / 2, screenHeight / 2, 70, rl.BLACK)
	rl.DrawCircleLines(screenWidth / 2, screenHeight / 2, 50, rl.BLACK)
	rl.DrawCircleLines(screenWidth / 2, screenHeight / 2, 30, rl.BLACK)

	-- Draw bullets
	if drawInPerformanceMode then
		for i = 0, bulletCount - 1 do
			if not bullets[i].disabled then
				rl.DrawTexture(bulletTexture.texture,
					math.floor(bullets[i].position.x - bulletTexture.texture.width * 0.5),
					math.floor(bullets[i].position.y - bulletTexture.texture.height * 0.5),
					bullets[i].color)
			end
		end
	else
		for i = 0, bulletCount - 1 do
			if not bullets[i].disabled then
				rl.DrawCircleV(bullets[i].position, bulletRadius, bullets[i].color)
				rl.DrawCircleLinesV(bullets[i].position, bulletRadius, rl.BLACK)
			end
		end
	end

	-- Draw UI
	rl.DrawRectangle(10, 10, 280, 150, rl.new("Color", 0, 0, 0, 200))
	rl.DrawText("Controls:", 20, 20, 10, rl.LIGHTGRAY)
	rl.DrawText("- Right/Left or A/D: Change rows number", 40, 40, 10, rl.LIGHTGRAY)
	rl.DrawText("- Up/Down or W/S: Change bullet speed", 40, 60, 10, rl.LIGHTGRAY)
	rl.DrawText("- Z or X: Change spawn cooldown", 40, 80, 10, rl.LIGHTGRAY)
	rl.DrawText("- Space (Hold): Change the angle increment", 40, 100, 10, rl.LIGHTGRAY)
	rl.DrawText("- Enter: Switch draw method (Performance)", 40, 120, 10, rl.LIGHTGRAY)
	rl.DrawText("- C: Clear bullets", 40, 140, 10, rl.LIGHTGRAY)

	rl.DrawRectangle(610, 10, 170, 30, rl.new("Color", 0, 0, 0, 200))
	if drawInPerformanceMode then
		rl.DrawText("Draw method: DrawTexture(*)", 620, 20, 10, rl.GREEN)
	else
		rl.DrawText("Draw method: DrawCircle(*)", 620, 20, 10, rl.RED)
	end

	rl.DrawRectangle(135, 410, 530, 30, rl.new("Color", 0, 0, 0, 200))
	rl.DrawText(string.format("[ FPS: %d, Bullets: %d, Rows: %d, Bullet speed: %.2f, Angle increment per frame: %d, Cooldown: %.0f ]",
		rl.GetFPS(), bulletCount - bulletDisabledCount, bulletRows, bulletSpeed, angleIncrement, spawnCooldown),
		155, 420, 10, rl.GREEN)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadRenderTexture(bulletTexture)

rl.CloseWindow()
