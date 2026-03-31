--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_top_down_lights.c

]]

-- raylib [shapes] example - top down lights

local RLGL_SRC_ALPHA = 0x0302
local RLGL_MIN = 0x8007
local RLGL_MAX = 0x8008

local MAX_BOXES = 20
local MAX_SHADOWS = MAX_BOXES * 3
local MAX_LIGHTS = 16

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - top down lights")

-- Lights data
local lights = {}
for i = 1, MAX_LIGHTS do
	lights[i] = {
		active = false,
		dirty = false,
		valid = false,
		x = 0, y = 0,
		mask = nil,
		outerRadius = 0,
		bounds = rl.new("Rectangle", 0, 0, 0, 0),
		shadows = {},
		shadowCount = 0,
	}
end

-- Boxes
local boxes = {}
local boxCount = 0

local function setupBoxes()
	boxes[1] = rl.new("Rectangle", 150, 80, 40, 40)
	boxes[2] = rl.new("Rectangle", 1200, 700, 40, 40)
	boxes[3] = rl.new("Rectangle", 200, 600, 40, 40)
	boxes[4] = rl.new("Rectangle", 1000, 50, 40, 40)
	boxes[5] = rl.new("Rectangle", 500, 350, 40, 40)

	for i = 6, MAX_BOXES do
		boxes[i] = rl.new("Rectangle",
			rl.GetRandomValue(0, screenWidth),
			rl.GetRandomValue(0, screenHeight),
			rl.GetRandomValue(10, 100),
			rl.GetRandomValue(10, 100))
	end
	boxCount = MAX_BOXES
end

local function moveLight(slot, x, y)
	local lt = lights[slot]
	lt.dirty = true
	lt.x = x
	lt.y = y
	lt.bounds = rl.new("Rectangle", x - lt.outerRadius, y - lt.outerRadius, lt.bounds.width, lt.bounds.height)
end

local function computeShadowVolumeForEdge(slot, sp, ep)
	local lt = lights[slot]
	if lt.shadowCount >= MAX_SHADOWS then return end

	local extension = lt.outerRadius * 2

	local spDiff = rl.new("Vector2", sp.x - lt.x, sp.y - lt.y)
	local spLen = math.sqrt(spDiff.x * spDiff.x + spDiff.y * spDiff.y)
	local spNorm = rl.new("Vector2", spDiff.x / spLen, spDiff.y / spLen)
	local spProjection = rl.new("Vector2", sp.x + spNorm.x * extension, sp.y + spNorm.y * extension)

	local epDiff = rl.new("Vector2", ep.x - lt.x, ep.y - lt.y)
	local epLen = math.sqrt(epDiff.x * epDiff.x + epDiff.y * epDiff.y)
	local epNorm = rl.new("Vector2", epDiff.x / epLen, epDiff.y / epLen)
	local epProjection = rl.new("Vector2", ep.x + epNorm.x * extension, ep.y + epNorm.y * extension)

	lt.shadowCount = lt.shadowCount + 1
	lt.shadows[lt.shadowCount] = {
		rl.new("Vector2", sp.x, sp.y),
		rl.new("Vector2", ep.x, ep.y),
		epProjection,
		spProjection,
	}
end

local function drawLightMask(slot)
	local lt = lights[slot]

	rl.BeginTextureMode(lt.mask)
		rl.ClearBackground(rl.WHITE)

		rl.rlSetBlendFactors(RLGL_SRC_ALPHA, RLGL_SRC_ALPHA, RLGL_MIN)
		rl.rlSetBlendMode(rl.BLEND_CUSTOM)

		if lt.valid then
			rl.DrawCircleGradient(math.floor(lt.x), math.floor(lt.y), lt.outerRadius, rl.ColorAlpha(rl.WHITE, 0), rl.WHITE)
		end

		rl.rlDrawRenderBatchActive()

		rl.rlSetBlendMode(rl.BLEND_ALPHA)
		rl.rlSetBlendFactors(RLGL_SRC_ALPHA, RLGL_SRC_ALPHA, RLGL_MAX)
		rl.rlSetBlendMode(rl.BLEND_CUSTOM)

		for i = 1, lt.shadowCount do
			rl.DrawTriangleFan(lt.shadows[i], 4, rl.WHITE)
		end

		rl.rlDrawRenderBatchActive()
		rl.rlSetBlendMode(rl.BLEND_ALPHA)

	rl.EndTextureMode()
end

local function setupLight(slot, x, y, radius)
	local lt = lights[slot]
	lt.active = true
	lt.valid = false
	lt.mask = rl.LoadRenderTexture(screenWidth, screenHeight)
	lt.outerRadius = radius
	lt.bounds = rl.new("Rectangle", x - radius, y - radius, radius * 2, radius * 2)

	moveLight(slot, x, y)
	drawLightMask(slot)
end

local function updateLight(slot, boxes, count)
	local lt = lights[slot]
	if not lt.active or not lt.dirty then return false end

	lt.dirty = false
	lt.shadowCount = 0
	lt.valid = false

	for i = 1, count do
		local b = boxes[i]
		if rl.CheckCollisionPointRec(rl.new("Vector2", lt.x, lt.y), b) then return false end
		if not rl.CheckCollisionRecs(lt.bounds, b) then goto continue end

		-- Top
		local sp = rl.new("Vector2", b.x, b.y)
		local ep = rl.new("Vector2", b.x + b.width, b.y)
		if lt.y > ep.y then computeShadowVolumeForEdge(slot, sp, ep) end

		-- Right
		sp = rl.new("Vector2", ep.x, ep.y)
		ep = rl.new("Vector2", ep.x, ep.y + b.height)
		if lt.x < ep.x then computeShadowVolumeForEdge(slot, sp, ep) end

		-- Bottom
		sp = rl.new("Vector2", ep.x, ep.y)
		ep = rl.new("Vector2", ep.x - b.width, ep.y)
		if lt.y < ep.y then computeShadowVolumeForEdge(slot, sp, ep) end

		-- Left
		sp = rl.new("Vector2", ep.x, ep.y)
		ep = rl.new("Vector2", ep.x, ep.y - b.height)
		if lt.x > ep.x then computeShadowVolumeForEdge(slot, sp, ep) end

		-- The box itself
		lt.shadowCount = lt.shadowCount + 1
		lt.shadows[lt.shadowCount] = {
			rl.new("Vector2", b.x, b.y),
			rl.new("Vector2", b.x, b.y + b.height),
			rl.new("Vector2", b.x + b.width, b.y + b.height),
			rl.new("Vector2", b.x + b.width, b.y),
		}

		::continue::
	end

	lt.valid = true
	drawLightMask(slot)
	return true
end

setupBoxes()

local img = rl.GenImageChecked(64, 64, 32, 32, rl.DARKBROWN, rl.DARKGRAY)
local backgroundTexture = rl.LoadTextureFromImage(img)
rl.UnloadImage(img)

local lightMask = rl.LoadRenderTexture(screenWidth, screenHeight)

setupLight(1, 600, 400, 300)
local nextLight = 2
local showLines = false

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) then
		local mp = rl.GetMousePosition()
		moveLight(1, mp.x, mp.y)
	end

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT) and nextLight <= MAX_LIGHTS then
		local mp = rl.GetMousePosition()
		setupLight(nextLight, mp.x, mp.y, 200)
		nextLight = nextLight + 1
	end

	if rl.IsKeyPressed(rl.KEY_F1) then showLines = not showLines end

	local dirtyLights = false
	for i = 1, MAX_LIGHTS do
		if updateLight(i, boxes, boxCount) then dirtyLights = true end
	end

	if dirtyLights then
		rl.BeginTextureMode(lightMask)
			rl.ClearBackground(rl.BLACK)

			rl.rlSetBlendFactors(RLGL_SRC_ALPHA, RLGL_SRC_ALPHA, RLGL_MIN)
			rl.rlSetBlendMode(rl.BLEND_CUSTOM)

			for i = 1, MAX_LIGHTS do
				if lights[i].active then
					rl.DrawTextureRec(lights[i].mask.texture,
						rl.new("Rectangle", 0, 0, screenWidth, -screenHeight),
						rl.new("Vector2", 0, 0), rl.WHITE)
				end
			end

			rl.rlDrawRenderBatchActive()
			rl.rlSetBlendMode(rl.BLEND_ALPHA)

		rl.EndTextureMode()
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		rl.DrawTextureRec(backgroundTexture,
			rl.new("Rectangle", 0, 0, screenWidth, screenHeight),
			rl.new("Vector2", 0, 0), rl.WHITE)

		rl.DrawTextureRec(lightMask.texture,
			rl.new("Rectangle", 0, 0, screenWidth, -screenHeight),
			rl.new("Vector2", 0, 0), rl.ColorAlpha(rl.WHITE, showLines and 0.75 or 1.0))

		for i = 1, MAX_LIGHTS do
			if lights[i].active then
				rl.DrawCircle(math.floor(lights[i].x), math.floor(lights[i].y), 10, (i == 1) and rl.YELLOW or rl.WHITE)
			end
		end

		if showLines then
			for s = 1, lights[1].shadowCount do
				rl.DrawTriangleFan(lights[1].shadows[s], 4, rl.DARKPURPLE)
			end

			for b = 1, boxCount do
				if rl.CheckCollisionRecs(boxes[b], lights[1].bounds) then
					rl.DrawRectangleRec(boxes[b], rl.PURPLE)
				end
				rl.DrawRectangleLines(math.floor(boxes[b].x), math.floor(boxes[b].y),
					math.floor(boxes[b].width), math.floor(boxes[b].height), rl.DARKBLUE)
			end

			rl.DrawText("(F1) Hide Shadow Volumes", 10, 50, 10, rl.GREEN)
		else
			rl.DrawText("(F1) Show Shadow Volumes", 10, 50, 10, rl.GREEN)
		end

		rl.DrawFPS(screenWidth - 80, 10)
		rl.DrawText("Drag to move light #1", 10, 10, 10, rl.DARKGREEN)
		rl.DrawText("Right click to add new light", 10, 30, 10, rl.DARKGREEN)

	rl.EndDrawing()
end

rl.UnloadTexture(backgroundTexture)
rl.UnloadRenderTexture(lightMask)
for i = 1, MAX_LIGHTS do
	if lights[i].active and lights[i].mask then
		rl.UnloadRenderTexture(lights[i].mask)
	end
end

rl.CloseWindow()
