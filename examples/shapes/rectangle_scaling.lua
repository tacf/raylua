--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/shapes/shapes_rectangle_scaling.c

]]

-- raylib [shapes] example - rectangle scaling

local MOUSE_SCALE_MARK_SIZE = 12

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - rectangle scaling")

local rec = rl.new("Rectangle", 100, 100, 200, 80)

local mouseScaleReady = false
local mouseScaleMode = false

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	local mousePosition = rl.GetMousePosition()

	if rl.CheckCollisionPointRec(mousePosition, rl.new("Rectangle", rec.x + rec.width - MOUSE_SCALE_MARK_SIZE, rec.y + rec.height - MOUSE_SCALE_MARK_SIZE, MOUSE_SCALE_MARK_SIZE, MOUSE_SCALE_MARK_SIZE)) then
		mouseScaleReady = true
		if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then mouseScaleMode = true end
	else
		mouseScaleReady = false
	end

	if mouseScaleMode then
		mouseScaleReady = true

		rec.width = mousePosition.x - rec.x
		rec.height = mousePosition.y - rec.y

		if rec.width < MOUSE_SCALE_MARK_SIZE then rec.width = MOUSE_SCALE_MARK_SIZE end
		if rec.height < MOUSE_SCALE_MARK_SIZE then rec.height = MOUSE_SCALE_MARK_SIZE end

		if rec.width > (rl.GetScreenWidth() - rec.x) then rec.width = rl.GetScreenWidth() - rec.x end
		if rec.height > (rl.GetScreenHeight() - rec.y) then rec.height = rl.GetScreenHeight() - rec.y end

		if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then mouseScaleMode = false end
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawText("Scale rectangle dragging from bottom-right corner!", 10, 10, 20, rl.GRAY)

		rl.DrawRectangleRec(rec, rl.Fade(rl.GREEN, 0.5))

		if mouseScaleReady then
			rl.DrawRectangleLinesEx(rec, 1, rl.RED)
			rl.DrawTriangle(
				rl.new("Vector2", rec.x + rec.width - MOUSE_SCALE_MARK_SIZE, rec.y + rec.height),
				rl.new("Vector2", rec.x + rec.width, rec.y + rec.height),
				rl.new("Vector2", rec.x + rec.width, rec.y + rec.height - MOUSE_SCALE_MARK_SIZE),
				rl.RED
			)
		end
	rl.EndDrawing()
end

rl.CloseWindow()
