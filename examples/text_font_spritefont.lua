rl.InitWindow(800, 450, "raylib [text] example - font spritefont")

local msg1 = "THIS IS A custom SPRITE FONT..."
local msg2 = "...and this is ANOTHER CUSTOM font..."
local msg3 = "...and a THIRD one! GREAT! :D"

local font1 = rl.LoadFont("resources/custom_mecha.png")
local font2 = rl.LoadFont("resources/custom_alagard.png")
local font3 = rl.LoadFont("resources/custom_jupiter_crash.png")

local fontPosition1 = {
	x = rl.GetScreenWidth() / 2.0 - rl.MeasureTextEx(font1, msg1, font1.baseSize, -3).x / 2,
	y = rl.GetScreenHeight() / 2.0 - font1.baseSize / 2.0 - 80.0
}

local fontPosition2 = {
	x = rl.GetScreenWidth() / 2.0 - rl.MeasureTextEx(font2, msg2, font2.baseSize, -2.0).x / 2.0,
	y = rl.GetScreenHeight() / 2.0 - font2.baseSize / 2.0 - 10.0
}

local fontPosition3 = {
	x = rl.GetScreenWidth() / 2.0 - rl.MeasureTextEx(font3, msg3, font3.baseSize, 2.0).x / 2.0,
	y = rl.GetScreenHeight() / 2.0 - font3.baseSize / 2.0 + 50.0
}

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawTextEx(font1, msg1, fontPosition1, font1.baseSize, -3, rl.WHITE)
		rl.DrawTextEx(font2, msg2, fontPosition2, font2.baseSize, -2, rl.WHITE)
		rl.DrawTextEx(font3, msg3, fontPosition3, font3.baseSize, 2, rl.WHITE)
	rl.EndDrawing()
end

rl.UnloadFont(font1)
rl.UnloadFont(font2)
rl.UnloadFont(font3)
rl.CloseWindow()