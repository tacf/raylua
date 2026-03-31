--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_simple_particles.c

]]

-- raylib [shapes] example - simple particles

local MAX_PARTICLES = 3000

local WATER = 0
local SMOKE = 1
local FIRE = 2

local particleTypeNames = { "WATER", "SMOKE", "FIRE" }

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - simple particles")

-- Particle data stored as flat tables
local particles = {}
for i = 1, MAX_PARTICLES do
	particles[i] = {
		ptype = WATER,
		x = 0, y = 0,
		vx = 0, vy = 0,
		radius = 0,
		r = 255, g = 255, b = 255, a = 255,
		lifeTime = 0,
		alive = false,
	}
end

local head = 1
local tail = 1

local emissionRate = -2
local currentType = WATER
local emitterX = screenWidth / 2.0
local emitterY = screenHeight / 2.0

local function emitParticle()
	local nextHead = (head % MAX_PARTICLES) + 1
	if nextHead == tail then return end -- buffer full

	local p = particles[head]
	p.alive = true
	p.lifeTime = 0.0
	p.ptype = currentType
	p.x = emitterX
	p.y = emitterY

	local speed = math.random(0, 9) / 5.0

	if currentType == WATER then
		p.radius = 5.0
		p.r, p.g, p.b, p.a = 0, 0, 255, 255
	elseif currentType == SMOKE then
		p.radius = 7.0
		p.r, p.g, p.b, p.a = 128, 128, 128, 255
	elseif currentType == FIRE then
		p.radius = 10.0
		p.r, p.g, p.b, p.a = 255, 255, 0, 255
		speed = speed / 10.0
	end

	local direction = math.random(0, 359)
	p.vx = speed * math.cos(math.rad(direction))
	p.vy = speed * math.sin(math.rad(direction))

	head = nextHead
end

local function updateParticles()
	local i = tail
	while i ~= head do
		local p = particles[i]
		p.lifeTime = p.lifeTime + 1.0 / 60.0

		if p.ptype == WATER then
			p.x = p.x + p.vx
			p.vy = p.vy + 0.2
			p.y = p.y + p.vy
		elseif p.ptype == SMOKE then
			p.x = p.x + p.vx
			p.vy = p.vy - 0.05
			p.y = p.y + p.vy
			p.radius = p.radius + 0.5
			p.a = p.a - 4
			if p.a < 4 then p.alive = false end
		elseif p.ptype == FIRE then
			p.x = p.x + p.vx + math.cos(p.lifeTime * 215.0)
			p.vy = p.vy - 0.05
			p.y = p.y + p.vy
			p.radius = p.radius - 0.15
			p.g = p.g - 3
			if p.radius <= 0.02 then p.alive = false end
		end

		if p.x < -p.radius or p.x > screenWidth + p.radius
			or p.y < -p.radius or p.y > screenHeight + p.radius then
			p.alive = false
		end

		i = (i % MAX_PARTICLES) + 1
	end
end

local function updateCircularBuffer()
	while tail ~= head and not particles[tail].alive do
		tail = (tail % MAX_PARTICLES) + 1
	end
end

local function drawParticles()
	local i = tail
	while i ~= head do
		local p = particles[i]
		if p.alive then
			rl.DrawCircleV(rl.new("Vector2", p.x, p.y), p.radius, rl.new("Color", p.r, p.g, p.b, p.a))
		end
		i = (i % MAX_PARTICLES) + 1
	end
end

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if emissionRate < 0 then
		if math.random(1, -emissionRate) == 1 then emitParticle() end
	else
		for _ = 0, emissionRate do emitParticle() end
	end

	updateParticles()
	updateCircularBuffer()

	if rl.IsKeyPressed(rl.KEY_UP) then emissionRate = emissionRate + 1 end
	if rl.IsKeyPressed(rl.KEY_DOWN) then emissionRate = emissionRate - 1 end

	if rl.IsKeyPressed(rl.KEY_RIGHT) then
		currentType = (currentType == FIRE) and WATER or (currentType + 1)
	end
	if rl.IsKeyPressed(rl.KEY_LEFT) then
		currentType = (currentType == WATER) and FIRE or (currentType - 1)
	end

	if rl.IsMouseButtonDown(rl.MOUSE_LEFT_BUTTON) then
		local mp = rl.GetMousePosition()
		emitterX = mp.x
		emitterY = mp.y
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		drawParticles()

		rl.DrawRectangle(5, 5, 315, 75, rl.Fade(rl.SKYBLUE, 0.5))
		rl.DrawRectangleLines(5, 5, 315, 75, rl.BLUE)

		rl.DrawText("CONTROLS:", 15, 15, 10, rl.BLACK)
		rl.DrawText("UP/DOWN: Change Particle Emission Rate", 15, 35, 10, rl.BLACK)
		rl.DrawText("LEFT/RIGHT: Change Particle Type (Water, Smoke, Fire)", 15, 55, 10, rl.BLACK)

		if emissionRate < 0 then
			rl.DrawText(string.format("Particles every %d frames | Type: %s", -emissionRate, particleTypeNames[currentType + 1]), 15, 95, 10, rl.DARKGRAY)
		else
			rl.DrawText(string.format("%d Particles per frame | Type: %s", emissionRate + 1, particleTypeNames[currentType + 1]), 15, 95, 10, rl.DARKGRAY)
		end

		rl.DrawFPS(screenWidth - 80, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
