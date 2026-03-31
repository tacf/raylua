--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_highdpi_demo.c

]]

-- raylib [core] example - highdpi demo

local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_WINDOW_HIGHDPI | rl.FLAG_WINDOW_RESIZABLE)
rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - highdpi demo")
rl.SetWindowMinSize(450, 450)

local logicalGridDescY = 120
local logicalGridLabelY = logicalGridDescY + 30
local logicalGridTop = logicalGridLabelY + 30
local logicalGridBottom = logicalGridTop + 80
local pixelGridTop = logicalGridBottom - 20
local pixelGridBottom = pixelGridTop + 80
local pixelGridLabelY = pixelGridBottom + 30
local pixelGridDescY = pixelGridLabelY + 30
local cellSize = 50
local cellSizePx = cellSize

local function DrawTextCenter(text, x, y, fontSize, color)
	local size = rl.MeasureTextEx(rl.GetFontDefault(), text, fontSize, 3)
	local pos = rl.new("Vector2", x - size.x / 2, y - size.y / 2)
	rl.DrawTextEx(rl.GetFontDefault(), text, pos, fontSize, 3, color)
end

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	local monitorCount = rl.GetMonitorCount()

	if monitorCount > 1 and rl.IsKeyPressed(rl.KEY_N) then
		rl.SetWindowMonitor((rl.GetCurrentMonitor() + 1) % monitorCount)
	end

	local currentMonitor = rl.GetCurrentMonitor()
	local dpiScale = rl.GetWindowScaleDPI()
	cellSizePx = cellSize / dpiScale.x

	-- Draw
	rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		local windowCenter = rl.GetScreenWidth() / 2
		DrawTextCenter(string.format("Dpi Scale: %f", dpiScale.x), windowCenter, 30, 40, rl.DARKGRAY)
		DrawTextCenter(string.format("Monitor: %d/%d ([N] next monitor)", currentMonitor + 1, monitorCount), windowCenter, 70, 20, rl.LIGHTGRAY)
		DrawTextCenter(string.format('Window is %d "logical points" wide', rl.GetScreenWidth()), windowCenter, logicalGridDescY, 20, rl.ORANGE)

		local odd = true
		for i = cellSize, rl.GetScreenWidth(), cellSize do
			if odd then
				rl.DrawRectangle(i, logicalGridTop, cellSize, logicalGridBottom - logicalGridTop, rl.ORANGE)
			end

			DrawTextCenter(string.format("%d", i), i, logicalGridLabelY, 10, rl.LIGHTGRAY)
			rl.DrawLine(i, logicalGridLabelY + 10, i, logicalGridBottom, rl.GRAY)

			odd = not odd
		end

		odd = true
		local minTextSpace = 30
		local lastTextX = -minTextSpace
		for i = cellSize, rl.GetRenderWidth(), cellSize do
			local x = math.floor(i / dpiScale.x)
			if odd then
				rl.DrawRectangle(x, pixelGridTop, math.floor(cellSizePx), pixelGridBottom - pixelGridTop, rl.new("Color", 0, 121, 241, 100))
			end

			rl.DrawLine(x, pixelGridTop, math.floor(i / dpiScale.x), pixelGridLabelY - 10, rl.GRAY)

			if (x - lastTextX) >= minTextSpace then
				DrawTextCenter(string.format("%d", i), x, pixelGridLabelY, 10, rl.LIGHTGRAY)
				lastTextX = x
			end

			odd = not odd
		end

		DrawTextCenter(string.format('Window is %d "physical pixels" wide', rl.GetRenderWidth()), windowCenter, pixelGridDescY, 20, rl.BLUE)

		local text = "Can you see this?"
		local size = rl.MeasureTextEx(rl.GetFontDefault(), text, 20, 3)
		local pos = rl.new("Vector2", rl.GetScreenWidth() - size.x - 5, rl.GetScreenHeight() - size.y - 5)
		rl.DrawTextEx(rl.GetFontDefault(), text, pos, 20, 3, rl.LIGHTGRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
