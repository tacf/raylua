rl.InitWindow(800, 450, "raylib [text] example - sprite fonts")

local MAX_FONTS = 8

local fonts = {}

fonts[1] = rl.LoadFont("resources/sprite_fonts/alagard.png")
fonts[2] = rl.LoadFont("resources/sprite_fonts/pixelplay.png")
fonts[3] = rl.LoadFont("resources/sprite_fonts/mecha.png")
fonts[4] = rl.LoadFont("resources/sprite_fonts/setback.png")
fonts[5] = rl.LoadFont("resources/sprite_fonts/romulus.png")
fonts[6] = rl.LoadFont("resources/sprite_fonts/pixantiqua.png")
fonts[7] = rl.LoadFont("resources/sprite_fonts/alpha_beta.png")
fonts[8] = rl.LoadFont("resources/sprite_fonts/jupiter_crash.png")

local messages = {
	"ALAGARD FONT designed by Hewett Tsoi",
	"PIXELPLAY FONT designed by Aleksander Shevchuk",
	"MECHA FONT designed by Captain Falcon",
	"SETBACK FONT designed by Brian Kent (AEnigma)",
	"ROMULUS FONT designed by Hewett Tsoi",
	"PIXANTIQUA FONT designed by Gerhard Grossmann",
	"ALPHA_BETA FONT designed by Brian Kent (AEnigma)",
	"JUPITER_CRASH FONT designed by Brian Kent (AEnigma)"
}

local spacings = { 2, 4, 8, 4, 3, 4, 4, 1 }

local positions = {}

for i = 1, MAX_FONTS do
	positions[i] = {
		x = rl.GetScreenWidth() / 2.0 - rl.MeasureTextEx(fonts[i], messages[i], fonts[i].baseSize * 2.0, spacings[i]).x / 2.0,
		y = 60.0 + fonts[i].baseSize + 45.0 * (i - 1)
	}
end

positions[4].y = positions[4].y + 8
positions[5].y = positions[5].y + 2
positions[8].y = positions[8].y - 8

local colors = { rl.MAROON, rl.ORANGE, rl.DARKGREEN, rl.DARKBLUE, rl.DARKPURPLE, rl.LIME, rl.GOLD, rl.RED }

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawText("free sprite fonts included with raylib", 220, 20, 20, rl.DARKGRAY)
		rl.DrawLine(220, 50, 600, 50, rl.DARKGRAY)

		for i = 1, MAX_FONTS do
			rl.DrawTextEx(fonts[i], messages[i], positions[i], fonts[i].baseSize * 2.0, spacings[i], colors[i])
		end
	rl.EndDrawing()
end

for i = 1, MAX_FONTS do
	rl.UnloadFont(fonts[i])
end

rl.CloseWindow()