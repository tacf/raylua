--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_2d_camera_mouse_zoom.c

]]

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera mouse zoom")

local camera = rl.new("Camera2D", {
	offset = rl.new("Vector2", 0, 0),
	target = rl.new("Vector2", 0, 0),
	rotation = 0,
	zoom = 1,
})

local zoomMode = 0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyPressed(rl.KEY_ONE) then zoomMode = 0
	elseif rl.IsKeyPressed(rl.KEY_TWO) then zoomMode = 1
	end

	if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) then
		local delta = rl.GetMouseDelta()
		local scale = -1.0 / camera.zoom
		camera.target = rl.new("Vector2",
			camera.target.x + delta.x * scale,
			camera.target.y + delta.y * scale)
	end

	if zoomMode == 0 then
		local wheel = rl.GetMouseWheelMove()
		if wheel ~= 0 then
			local mouseWorldPos = rl.GetScreenToWorld2D(rl.GetMousePosition(), camera)
			camera.offset = rl.GetMousePosition()
			camera.target = mouseWorldPos

			local scale = 0.2 * wheel
			camera.zoom = rl.Clamp(math.exp(math.log(camera.zoom) + scale), 0.125, 64.0)
		end
	else
		if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT) then
			local mouseWorldPos = rl.GetScreenToWorld2D(rl.GetMousePosition(), camera)
			camera.offset = rl.GetMousePosition()
			camera.target = mouseWorldPos
		end

		if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_RIGHT) then
			local deltaX = rl.GetMouseDelta().x
			local scale = 0.005 * deltaX
			camera.zoom = rl.Clamp(math.exp(math.log(camera.zoom) + scale), 0.125, 64.0)
		end
	end

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode2D(camera)
	rl.rlPushMatrix()
	rl.rlTranslatef(0, 25 * 50, 0)
	rl.rlRotatef(90, 1, 0, 0)
	rl.DrawGrid(100, 50)
	rl.rlPopMatrix()

	rl.DrawCircle(rl.GetScreenWidth() / 2, rl.GetScreenHeight() / 2, 50, rl.MAROON)
	rl.EndMode2D()

	rl.DrawCircleV(rl.GetMousePosition(), 4, rl.DARKGRAY)
	rl.DrawTextEx(rl.GetFontDefault(),
		string.format("[%d, %d]", rl.GetMouseX(), rl.GetMouseY()),
		rl.new("Vector2", rl.GetMouseX() - 44, rl.GetMouseY() - 24), 20, 2, rl.BLACK)

	rl.DrawText("[1][2] Select mouse zoom mode (Wheel or Move)", 20, 20, 20, rl.DARKGRAY)
	if zoomMode == 0 then
		rl.DrawText("Mouse left button drag to move, mouse wheel to zoom", 20, 50, 20, rl.DARKGRAY)
	else
		rl.DrawText("Mouse left button drag to move, mouse press and move to zoom", 20, 50, 20, rl.DARKGRAY)
	end

	rl.EndDrawing()
end

rl.CloseWindow()
