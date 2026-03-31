rl.InitWindow(800, 450, "raylib [text] example - input box")

local MAX_INPUT_CHARS = 9

local name = ""
local letterCount = 0

local textBox = {
	x = rl.GetScreenWidth() / 2.0 - 100,
	y = 180,
	width = 225,
	height = 50
}
local mouseOnText = false

local framesCounter = 0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.CheckCollisionPointRec(rl.GetMousePosition(), textBox) then
		mouseOnText = true
	else
		mouseOnText = false
	end

	if mouseOnText then
		rl.SetMouseCursor(rl.MOUSE_CURSOR_IBEAM)

		local key = rl.GetCharPressed()

		while key > 0 do
			if (key >= 32) and (key <= 125) and (letterCount < MAX_INPUT_CHARS) then
				name = name .. string.char(key)
				letterCount = letterCount + 1
			end

			key = rl.GetCharPressed()
		end

		if rl.IsKeyPressed(rl.KEY_BACKSPACE) then
			letterCount = letterCount - 1
			if letterCount < 0 then
				letterCount = 0
			end
			name = name:sub(1, letterCount)
		end
	else
		rl.SetMouseCursor(rl.MOUSE_CURSOR_DEFAULT)
	end

	if mouseOnText then
		framesCounter = framesCounter + 1
	else
		framesCounter = 0
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawText("PLACE MOUSE OVER INPUT BOX!", 240, 140, 20, rl.GRAY)

		rl.DrawRectangleRec(textBox, rl.LIGHTGRAY)
		if mouseOnText then
			rl.DrawRectangleLines(textBox.x, textBox.y, textBox.width, textBox.height, rl.RED)
		else
			rl.DrawRectangleLines(textBox.x, textBox.y, textBox.width, textBox.height, rl.DARKGRAY)
		end

		rl.DrawText(name, textBox.x + 5, textBox.y + 8, 40, rl.MAROON)

		rl.DrawText(string.format("INPUT CHARS: %i/%i", letterCount, MAX_INPUT_CHARS), 315, 250, 20, rl.DARKGRAY)

		if mouseOnText then
			if letterCount < MAX_INPUT_CHARS then
				if math.floor(framesCounter / 20) % 2 == 0 then
					rl.DrawText("_", textBox.x + 8 + rl.MeasureText(name, 40), textBox.y + 12, 40, rl.MAROON)
				end
			else
				rl.DrawText("Press BACKSPACE to delete chars...", 230, 300, 20, rl.GRAY)
			end
		end
	rl.EndDrawing()
end

rl.CloseWindow()