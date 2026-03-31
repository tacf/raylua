rl.InitWindow(800, 450, "raylib [text] example - writing anim")

local message = "This sample illustrates a text writing\nanimation effect! Check it out! ;)"

local framesCounter = 0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsKeyDown(rl.KEY_SPACE) then
		framesCounter = framesCounter + 8
	else
		framesCounter = framesCounter + 1
	end

	if rl.IsKeyPressed(rl.KEY_ENTER) then
		framesCounter = 0
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		local textToDraw = message:sub(1, math.floor(framesCounter / 10))
		rl.DrawText(textToDraw, 210, 160, 20, rl.MAROON)

		rl.DrawText("PRESS [ENTER] to RESTART!", 240, 260, 20, rl.LIGHTGRAY)
		rl.DrawText("HOLD [SPACE] to SPEED UP!", 239, 300, 20, rl.LIGHTGRAY)
	rl.EndDrawing()
end

rl.CloseWindow()