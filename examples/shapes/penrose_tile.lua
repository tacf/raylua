--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_penrose_tile.c

]]

-- raylib [shapes] example - penrose tile

local STR_MAX_SIZE = 10000
local TURTLE_STACK_MAX_SIZE = 50

-- Turtle state
local turtleStack = {}
local turtleTop = 0

local function pushTurtleState(state)
	if turtleTop < TURTLE_STACK_MAX_SIZE then
		turtleTop = turtleTop + 1
		turtleStack[turtleTop] = { origin = rl.new("Vector2", state.origin.x, state.origin.y), angle = state.angle }
	else
		print("TURTLE STACK OVERFLOW!")
	end
end

local function popTurtleState()
	if turtleTop >= 1 then
		local state = turtleStack[turtleTop]
		turtleTop = turtleTop - 1
		return state
	end
	print("TURTLE STACK UNDERFLOW!")
	return { origin = rl.new("Vector2", 0, 0), angle = 0 }
end

local function createPenroseLSystem(drawLength)
	local ls = {
		steps = 0,
		ruleW = "YF++ZF4-XF[-YF4-WF]++",
		ruleX = "+YF--ZF[3-WF--XF]+",
		ruleY = "-WF++XF[+++YF++ZF]-",
		ruleZ = "--YF++++WF[+ZF++++XF]--XF",
		drawLength = drawLength,
		theta = 36.0,
		production = "[X]++[X]++[X]++[X]++[X]",
	}
	return ls
end

local function buildProductionStep(ls)
	local newProduction = {}
	local productionLength = #ls.production

	for i = 1, productionLength do
		local step = ls.production:sub(i, i)
		if step == "W" then
			newProduction[#newProduction + 1] = ls.ruleW
		elseif step == "X" then
			newProduction[#newProduction + 1] = ls.ruleX
		elseif step == "Y" then
			newProduction[#newProduction + 1] = ls.ruleY
		elseif step == "Z" then
			newProduction[#newProduction + 1] = ls.ruleZ
		elseif step ~= "F" then
			newProduction[#newProduction + 1] = step
		end
	end

	ls.drawLength = ls.drawLength * 0.5
	ls.production = table.concat(newProduction)
end

local function drawPenroseLSystem(ls)
	local screenX = rl.GetScreenWidth() / 2.0
	local screenY = rl.GetScreenHeight() / 2.0

	local turtle = {
		origin = rl.new("Vector2", 0, 0),
		angle = -90.0,
	}

	local repeats = 1
	local productionLength = #ls.production
	ls.steps = ls.steps + 12

	if ls.steps > productionLength then ls.steps = productionLength end

	for i = 1, ls.steps do
		local step = ls.production:sub(i, i)

		if step == "F" then
			for _ = 1, repeats do
				local startPosX = turtle.origin.x
				local startPosY = turtle.origin.y
				local radAngle = math.rad(turtle.angle)
				turtle.origin = rl.new("Vector2",
					turtle.origin.x + ls.drawLength * math.cos(radAngle),
					turtle.origin.y + ls.drawLength * math.sin(radAngle))

				rl.DrawLineEx(
					rl.new("Vector2", startPosX + screenX, startPosY + screenY),
					rl.new("Vector2", turtle.origin.x + screenX, turtle.origin.y + screenY),
					2, rl.Fade(rl.BLACK, 0.2))
			end
			repeats = 1
		elseif step == "+" then
			for _ = 1, repeats do turtle.angle = turtle.angle + ls.theta end
			repeats = 1
		elseif step == "-" then
			for _ = 1, repeats do turtle.angle = turtle.angle - ls.theta end
			repeats = 1
		elseif step == "[" then
			pushTurtleState(turtle)
		elseif step == "]" then
			turtle = popTurtleState()
		else
			local code = string.byte(step)
			if code >= 48 and code <= 57 then
				repeats = code - 48
			end
		end
	end

	turtleTop = 0
end

local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - penrose tile")

local drawLength = 460.0
local maxGenerations = 4
local generations = 0

local ls = createPenroseLSystem(drawLength * (generations / maxGenerations))
for _ = 1, generations do buildProductionStep(ls) end

rl.SetTargetFPS(120)

while not rl.WindowShouldClose() do
	local rebuild = false

	if rl.IsKeyPressed(rl.KEY_UP) then
		if generations < maxGenerations then
			generations = generations + 1
			rebuild = true
		end
	elseif rl.IsKeyPressed(rl.KEY_DOWN) then
		if generations > 0 then
			generations = generations - 1
			if generations > 0 then rebuild = true end
		end
	end

	if rebuild then
		ls = createPenroseLSystem(drawLength * (generations / maxGenerations))
		for _ = 1, generations do buildProductionStep(ls) end
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		if generations > 0 then drawPenroseLSystem(ls) end

		rl.DrawText("penrose l-system", 10, 10, 20, rl.DARKGRAY)
		rl.DrawText("press up or down to change generations", 10, 30, 20, rl.DARKGRAY)
		rl.DrawText(string.format("generations: %d", generations), 10, 50, 20, rl.DARKGRAY)

	rl.EndDrawing()
end

rl.CloseWindow()
