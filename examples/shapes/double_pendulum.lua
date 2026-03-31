--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_double_pendulum.c

]]

--[[
    raylib [shapes] example - double pendulum

    Example complexity rating: [★★☆☆] 2/4

    Example originally created with raylib 5.5, last time updated with raylib 5.5

    Example contributed by JoeCheong (@Joecheong2006) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2025 JoeCheong (@Joecheong2006)
]]

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_WINDOW_HIGHDPI)
rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - double pendulum")

-- Simulation Parameters
local SIMULATION_STEPS = 30
local G = 9.81

local l1, m1, theta1, w1 = 15.0, 0.2, math.rad(170), 0
local l2, m2, theta2, w2 = 15.0, 0.1, math.rad(0), 0
local lengthScaler = 0.1
local totalM = m1 + m2

-- Scale length
local L1 = l1 * lengthScaler
local L2 = l2 * lengthScaler

-- Calculate pendulum end point
local function CalculatePendulumEndPoint(l, theta)
	return rl.new("Vector2", 10 * l * math.sin(theta), 10 * l * math.cos(theta))
end

-- Calculate double pendulum end point
local function CalculateDoublePendulumEndPoint(l1, theta1, l2, theta2)
	local ep1 = CalculatePendulumEndPoint(l1, theta1)
	local ep2 = CalculatePendulumEndPoint(l2, theta2)
	return rl.new("Vector2", ep1.x + ep2.x, ep1.y + ep2.y)
end

local previousPosition = CalculateDoublePendulumEndPoint(l1, theta1, l2, theta2)
previousPosition = rl.new("Vector2", previousPosition.x + screenWidth/2.0, previousPosition.y + screenHeight/2.0 - 100)

-- Draw parameters
local lineThick = 20
local trailThick = 2
local fateAlpha = 0.01

-- Create framebuffer
local target = rl.LoadRenderTexture(screenWidth, screenHeight)
rl.SetTextureFilter(target.texture, rl.TEXTURE_FILTER_BILINEAR)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	local dt = rl.GetFrameTime()
	local step = dt / SIMULATION_STEPS
	local step2 = step * step

	-- Update Physics - larger steps = better approximation
	for i = 0, SIMULATION_STEPS - 1 do
		local delta = theta1 - theta2
		local sinD = math.sin(delta)
		local cosD = math.cos(delta)
		local cos2D = math.cos(2 * delta)
		local ww1 = w1 * w1
		local ww2 = w2 * w2

		-- Calculate a1
		local a1 = (-G * (2*m1 + m2) * math.sin(theta1)
			- m2 * G * math.sin(theta1 - 2*theta2)
			- 2 * sinD * m2 * (ww2*L2 + ww1*L1*cosD))
			/ (L1 * (2*m1 + m2 - m2*cos2D))

		-- Calculate a2
		local a2 = (2 * sinD * (ww1*L1*totalM
			+ G*totalM*math.cos(theta1)
			+ ww2*L2*m2*cosD))
			/ (L2 * (2*m1 + m2 - m2*cos2D))

		-- Update thetas
		theta1 = theta1 + w1*step + 0.5*a1*step2
		theta2 = theta2 + w2*step + 0.5*a2*step2

		-- Update omegas
		w1 = w1 + a1*step
		w2 = w2 + a2*step
	end

	-- Calculate position
	local currentPosition = CalculateDoublePendulumEndPoint(l1, theta1, l2, theta2)
	currentPosition = rl.new("Vector2", currentPosition.x + screenWidth/2.0, currentPosition.y + screenHeight/2.0 - 100)

	-- Draw to render texture
	rl.BeginTextureMode(target)
		-- Draw a transparent rectangle - smaller alpha = longer trails
		rl.DrawRectangle(0, 0, screenWidth, screenHeight, rl.Fade(rl.BLACK, fateAlpha))

		-- Draw trail
		rl.DrawCircleV(previousPosition, trailThick, rl.RED)
		rl.DrawLineEx(previousPosition, currentPosition, trailThick*2, rl.RED)
	rl.EndTextureMode()

	-- Update previous position
	previousPosition = currentPosition

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.BLACK)

	-- Draw trails texture
	rl.DrawTextureRec(target.texture,
		rl.new("Rectangle", 0, 0, target.texture.width, -target.texture.height),
		rl.new("Vector2", 0, 0), rl.WHITE)

	-- Draw double pendulum
	rl.DrawRectanglePro(
		rl.new("Rectangle", screenWidth/2.0, screenHeight/2.0 - 100, 10*l1, lineThick),
		rl.new("Vector2", 0, lineThick*0.5), 90 - math.deg(theta1), rl.RAYWHITE)

	local endpoint1 = CalculatePendulumEndPoint(l1, theta1)
	rl.DrawRectanglePro(
		rl.new("Rectangle", screenWidth/2.0 + endpoint1.x, screenHeight/2.0 - 100 + endpoint1.y, 10*l2, lineThick),
		rl.new("Vector2", 0, lineThick*0.5), 90 - math.deg(theta2), rl.RAYWHITE)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadRenderTexture(target)

rl.CloseWindow()
