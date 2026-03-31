rl.InitWindow(800, 450, "raylib [text] example - font loading")

local msg = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI\nJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmn\nopqrstuvwxyz{|}~¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓ\nÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷\nøùúûüýþÿ"

local fontBm = rl.LoadFont("resources/pixantiqua.fnt")

local fontTtf = rl.LoadFontEx("resources/NotoSans-Medium.ttf", 32, nil, 250)

rl.SetTextLineSpacing(16)

local useTtf = false

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsKeyDown(rl.KEY_SPACE) then
		useTtf = true
	else
		useTtf = false
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawText("Hold SPACE to use TTF generated font", 20, 20, 20, rl.LIGHTGRAY)

		if not useTtf then
			rl.DrawTextEx(fontBm, msg, rl.rlVertex2f(20, 100), fontBm.baseSize, 2, rl.MAROON)
			rl.DrawText("Using BMFont (Angelcode) imported", 20, rl.GetScreenHeight() - 30, 20, rl.GRAY)
		else
			rl.DrawTextEx(fontTtf, msg, rl.rlVertex2f(20, 100), fontTtf.baseSize, 2, rl.LIME)
			rl.DrawText("Using TTF font generated", 20, rl.GetScreenHeight() - 30, 20, rl.GRAY)
		end
	rl.EndDrawing()
end

rl.UnloadFont(fontBm)
rl.UnloadFont(fontTtf)
rl.CloseWindow()