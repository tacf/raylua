--[[
    raylib [shapes] example - ball physics

    Example complexity rating: [★★☆☆] 2/4

    Example originally created with raylib 6.0, last time updated with raylib 6.0

    Example contributed by David Buzatto (@davidbuzatto) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2025 David Buzatto (@davidbuzatto)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - ball physics")

local MAX_BALLS = 5000

local balls = {}
balls[0] = {
	position = rl.new("Vector2", screenWidth/2.0, screenHeight/2.0),
	speed = rl.new("Vector2", 200, 200),
	prevPosition = rl.new("Vector2", 0, 0),
	radius = 40,
	friction = 0.99,
	elasticity = 0.9,
	color = rl.BLUE,
	grabbed = false,
}

local ballCount = 1
local grabbedBall = nil
local pressOffset = rl.new("Vector2", 0, 0)
local gravity = 100

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	local delta = rl.GetFrameTime()
	local mousePos = rl.GetMousePosition()

	-- Checks if a ball was grabbed
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then
		for i = ballCount - 1, 0, -1 do
			local ball = balls[i]
			pressOffset.x = mousePos.x - ball.position.x
			pressOffset.y = mousePos.y - ball.position.y

			local dist = math.sqrt(pressOffset.x * pressOffset.x + pressOffset.y * pressOffset.y)
			if dist <= ball.radius then
				ball.grabbed = true
				grabbedBall = ball
				break
			end
		end
	end

	-- Releases any ball that was grabbed
	if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then
		if grabbedBall ~= nil then
			grabbedBall.grabbed = false
			grabbedBall = nil
		end
	end

	-- Creates a new ball
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT) or (rl.IsKeyDown(rl.KEY_LEFT_CONTROL) and rl.IsMouseButtonDown(rl.MOUSE_BUTTON_RIGHT)) then
		if ballCount < MAX_BALLS then
			balls[ballCount] = {
				position = rl.new("Vector2", mousePos.x, mousePos.y),
				speed = rl.new("Vector2", rl.GetRandomValue(-300, 300), rl.GetRandomValue(-300, 300)),
				prevPosition = rl.new("Vector2", 0, 0),
				radius = 20.0 + rl.GetRandomValue(0, 30),
				friction = 0.99,
				elasticity = 0.9,
				color = rl.new("Color", rl.GetRandomValue(0, 255), rl.GetRandomValue(0, 255), rl.GetRandomValue(0, 255), 255),
				grabbed = false,
			}
			ballCount = ballCount + 1
		end
	end

	-- Shake balls
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_MIDDLE) then
		for i = 0, ballCount - 1 do
			if not balls[i].grabbed then
				balls[i].speed = rl.new("Vector2", rl.GetRandomValue(-2000, 2000), rl.GetRandomValue(-2000, 2000))
			end
		end
	end

	-- Changes gravity
	gravity = gravity + rl.GetMouseWheelMove() * 5

	-- Updates each ball state
	for i = 0, ballCount - 1 do
		local ball = balls[i]

		if not ball.grabbed then
			ball.position.x = ball.position.x + ball.speed.x * delta
			ball.position.y = ball.position.y + ball.speed.y * delta

			if (ball.position.x + ball.radius) >= screenWidth then
				ball.position.x = screenWidth - ball.radius
				ball.speed.x = -ball.speed.x * ball.elasticity
			elseif (ball.position.x - ball.radius) <= 0 then
				ball.position.x = ball.radius
				ball.speed.x = -ball.speed.x * ball.elasticity
			end

			if (ball.position.y + ball.radius) >= screenHeight then
				ball.position.y = screenHeight - ball.radius
				ball.speed.y = -ball.speed.y * ball.elasticity
			elseif (ball.position.y - ball.radius) <= 0 then
				ball.position.y = ball.radius
				ball.speed.y = -ball.speed.y * ball.elasticity
			end

			ball.speed.x = ball.speed.x * ball.friction
			ball.speed.y = ball.speed.y * ball.friction + gravity
		else
			ball.position.x = mousePos.x - pressOffset.x
			ball.position.y = mousePos.y - pressOffset.y

			ball.speed.x = (ball.position.x - ball.prevPosition.x) / delta
			ball.speed.y = (ball.position.y - ball.prevPosition.y) / delta
			ball.prevPosition = rl.new("Vector2", ball.position.x, ball.position.y)
		end
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	for i = 0, ballCount - 1 do
		rl.DrawCircleV(balls[i].position, balls[i].radius, balls[i].color)
		rl.DrawCircleLinesV(balls[i].position, balls[i].radius, rl.BLACK)
	end

	rl.DrawText("grab a ball by pressing with the mouse and throw it by releasing", 10, 10, 10, rl.DARKGRAY)
	rl.DrawText("right click to create new balls (keep left control pressed to create a lot)", 10, 30, 10, rl.DARKGRAY)
	rl.DrawText("use mouse wheel to change gravity", 10, 50, 10, rl.DARKGRAY)
	rl.DrawText("middle click to shake", 10, 70, 10, rl.DARKGRAY)
	rl.DrawText(string.format("BALL COUNT: %d", ballCount), 10, rl.GetScreenHeight() - 70, 20, rl.BLACK)
	rl.DrawText(string.format("GRAVITY: %.2f", gravity), 10, rl.GetScreenHeight() - 40, 20, rl.BLACK)

	rl.EndDrawing()
end

rl.CloseWindow()
