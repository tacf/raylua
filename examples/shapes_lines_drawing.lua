-- raylib [shapes] example - lines drawing

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - lines drawing")

local startText = true
local mousePositionPrevious = rl.GetMousePosition()

local canvas = rl.LoadRenderTexture(screenWidth, screenHeight)

local lineThickness = 8.0
local lineHue = 0.0

rl.BeginTextureMode(canvas)
	rl.ClearBackground(rl.RAYWHITE)
rl.EndTextureMode()

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and startText then startText = false end

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_MIDDLE) then
		rl.BeginTextureMode(canvas)
			rl.ClearBackground(rl.RAYWHITE)
		rl.EndTextureMode()
	end

	local leftButtonDown = rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT)
	local rightButtonDown = rl.IsMouseButtonDown(rl.MOUSE_BUTTON_RIGHT)

	if leftButtonDown or rightButtonDown then
		local drawColor = rl.WHITE

		if leftButtonDown then
			lineHue = lineHue + rl.Vector2Distance(mousePositionPrevious, rl.GetMousePosition()) / 3.0

			while lineHue >= 360.0 do lineHue = lineHue - 360.0 end

			drawColor = rl.ColorFromHSV(lineHue, 1.0, 1.0)
		elseif rightButtonDown then
			drawColor = rl.RAYWHITE
		end

		rl.BeginTextureMode(canvas)
			rl.DrawCircleV(mousePositionPrevious, lineThickness / 2.0, drawColor)
			rl.DrawCircleV(rl.GetMousePosition(), lineThickness / 2.0, drawColor)
			rl.DrawLineEx(mousePositionPrevious, rl.GetMousePosition(), lineThickness, drawColor)
		rl.EndTextureMode()
	end

	lineThickness = lineThickness + rl.GetMouseWheelMove()
	if lineThickness < 1.0 then lineThickness = 1.0 end
	if lineThickness > 500.0 then lineThickness = 500.0 end

	mousePositionPrevious = rl.GetMousePosition()

	rl.BeginDrawing()
		rl.DrawTextureRec(canvas.texture, rl.new("Rectangle", 0, 0, canvas.texture.width, -canvas.texture.height), rl.new("Vector2", 0, 0), rl.WHITE)

		if not leftButtonDown then
			rl.DrawCircleLinesV(rl.GetMousePosition(), lineThickness / 2.0, rl.new("Color", 127, 127, 127, 127))
		end

		if startText then
			rl.DrawText("try clicking and dragging!", 275, 215, 20, rl.LIGHTGRAY)
		end
	rl.EndDrawing()
end

rl.UnloadRenderTexture(canvas)
rl.CloseWindow()
