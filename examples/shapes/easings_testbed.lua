--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_easings_testbed.c

]]

--[[
    raylib [shapes] example - easings testbed

    Example complexity rating: [★★★☆] 3/4

    Example originally created with raylib 2.5, last time updated with raylib 2.5

    Example contributed by Juan Miguel Lopez (@flashback-fx) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2019-2025 Juan Miguel Lopez (@flashback-fx) and Ramon Santamaria (@raysan5)
]]

-- Initialization
local FONT_SIZE = 20

local D_STEP = 20.0
local D_STEP_FINE = 2.0
local D_MIN = 1.0
local D_MAX = 10000.0

-- NoEase function, used when "no easing" is selected for any axis
local function NoEase(t, b, c, d)
	return b
end

-- Easing functions reference data
local EASING_NONE = 28

local easings = {
	[0] = { name = "EaseLinearNone", func = rl.EaseLinearNone },
	[1] = { name = "EaseLinearIn", func = rl.EaseLinearIn },
	[2] = { name = "EaseLinearOut", func = rl.EaseLinearOut },
	[3] = { name = "EaseLinearInOut", func = rl.EaseLinearInOut },
	[4] = { name = "EaseSineIn", func = rl.EaseSineIn },
	[5] = { name = "EaseSineOut", func = rl.EaseSineOut },
	[6] = { name = "EaseSineInOut", func = rl.EaseSineInOut },
	[7] = { name = "EaseCircIn", func = rl.EaseCircIn },
	[8] = { name = "EaseCircOut", func = rl.EaseCircOut },
	[9] = { name = "EaseCircInOut", func = rl.EaseCircInOut },
	[10] = { name = "EaseCubicIn", func = rl.EaseCubicIn },
	[11] = { name = "EaseCubicOut", func = rl.EaseCubicOut },
	[12] = { name = "EaseCubicInOut", func = rl.EaseCubicInOut },
	[13] = { name = "EaseQuadIn", func = rl.EaseQuadIn },
	[14] = { name = "EaseQuadOut", func = rl.EaseQuadOut },
	[15] = { name = "EaseQuadInOut", func = rl.EaseQuadInOut },
	[16] = { name = "EaseExpoIn", func = rl.EaseExpoIn },
	[17] = { name = "EaseExpoOut", func = rl.EaseExpoOut },
	[18] = { name = "EaseExpoInOut", func = rl.EaseExpoInOut },
	[19] = { name = "EaseBackIn", func = rl.EaseBackIn },
	[20] = { name = "EaseBackOut", func = rl.EaseBackOut },
	[21] = { name = "EaseBackInOut", func = rl.EaseBackInOut },
	[22] = { name = "EaseBounceOut", func = rl.EaseBounceOut },
	[23] = { name = "EaseBounceIn", func = rl.EaseBounceIn },
	[24] = { name = "EaseBounceInOut", func = rl.EaseBounceInOut },
	[25] = { name = "EaseElasticIn", func = rl.EaseElasticIn },
	[26] = { name = "EaseElasticOut", func = rl.EaseElasticOut },
	[27] = { name = "EaseElasticInOut", func = rl.EaseElasticInOut },
	[EASING_NONE] = { name = "None", func = NoEase },
}

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - easings testbed")

local ballPosition = rl.new("Vector2", 100.0, 100.0)

local t = 0.0
local d = 300.0
local paused = true
local boundedT = true

local easingX = EASING_NONE
local easingY = EASING_NONE

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyPressed(rl.KEY_T) then boundedT = not boundedT end

	-- Choose easing for the X axis
	if rl.IsKeyPressed(rl.KEY_RIGHT) then
		easingX = easingX + 1
		if easingX > EASING_NONE then easingX = 0 end
	elseif rl.IsKeyPressed(rl.KEY_LEFT) then
		if easingX == 0 then easingX = EASING_NONE
		else easingX = easingX - 1 end
	end

	-- Choose easing for the Y axis
	if rl.IsKeyPressed(rl.KEY_DOWN) then
		easingY = easingY + 1
		if easingY > EASING_NONE then easingY = 0 end
	elseif rl.IsKeyPressed(rl.KEY_UP) then
		if easingY == 0 then easingY = EASING_NONE
		else easingY = easingY - 1 end
	end

	-- Change d (duration) value
	if rl.IsKeyPressed(rl.KEY_W) and (d < D_MAX - D_STEP) then d = d + D_STEP end
	if rl.IsKeyPressed(rl.KEY_Q) and (d > D_MIN + D_STEP) then d = d - D_STEP end

	if rl.IsKeyDown(rl.KEY_S) and (d < D_MAX - D_STEP_FINE) then d = d + D_STEP_FINE end
	if rl.IsKeyDown(rl.KEY_A) and (d > D_MIN + D_STEP_FINE) then d = d - D_STEP_FINE end

	-- Play, pause and restart controls
	if rl.IsKeyPressed(rl.KEY_SPACE) or rl.IsKeyPressed(rl.KEY_T) or
		rl.IsKeyPressed(rl.KEY_RIGHT) or rl.IsKeyPressed(rl.KEY_LEFT) or
		rl.IsKeyPressed(rl.KEY_DOWN) or rl.IsKeyPressed(rl.KEY_UP) or
		rl.IsKeyPressed(rl.KEY_W) or rl.IsKeyPressed(rl.KEY_Q) or
		rl.IsKeyDown(rl.KEY_S) or rl.IsKeyDown(rl.KEY_A) or
		(rl.IsKeyPressed(rl.KEY_ENTER) and boundedT and t >= d) then
		t = 0.0
		ballPosition = rl.new("Vector2", 100.0, 100.0)
		paused = true
	end

	if rl.IsKeyPressed(rl.KEY_ENTER) then paused = not paused end

	-- Movement computation
	if not paused and ((boundedT and t < d) or not boundedT) then
		ballPosition.x = easings[easingX].func(t, 100.0, 700.0 - 170.0, d)
		ballPosition.y = easings[easingY].func(t, 100.0, 400.0 - 170.0, d)
		t = t + 1.0
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	-- Draw information text
	rl.DrawText(string.format("Easing x: %s", easings[easingX].name), 20, FONT_SIZE, FONT_SIZE, rl.LIGHTGRAY)
	rl.DrawText(string.format("Easing y: %s", easings[easingY].name), 20, FONT_SIZE*2, FONT_SIZE, rl.LIGHTGRAY)
	rl.DrawText(string.format("t (%c) = %.2f d = %.2f", boundedT and 'b' or 'u', t, d), 20, FONT_SIZE*3, FONT_SIZE, rl.LIGHTGRAY)

	-- Draw instructions text
	rl.DrawText("Use ENTER to play or pause movement, use SPACE to restart", 20, rl.GetScreenHeight() - FONT_SIZE*2, FONT_SIZE, rl.LIGHTGRAY)
	rl.DrawText("Use Q and W or A and S keys to change duration", 20, rl.GetScreenHeight() - FONT_SIZE*3, FONT_SIZE, rl.LIGHTGRAY)
	rl.DrawText("Use LEFT or RIGHT keys to choose easing for the x axis", 20, rl.GetScreenHeight() - FONT_SIZE*4, FONT_SIZE, rl.LIGHTGRAY)
	rl.DrawText("Use UP or DOWN keys to choose easing for the y axis", 20, rl.GetScreenHeight() - FONT_SIZE*5, FONT_SIZE, rl.LIGHTGRAY)

	-- Draw ball
	rl.DrawCircleV(ballPosition, 16.0, rl.MAROON)

	rl.EndDrawing()
end

rl.CloseWindow()
