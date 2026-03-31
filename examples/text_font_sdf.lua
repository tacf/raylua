rl.InitWindow(800, 450, "raylib [text] example - font sdf")

local msg = "Signed Distance Fields"

local fileSize = 0
local fileData = rl.LoadFileData("resources/NotoSans-Medium.ttf", fileSize)

local fontDefault = {
	baseSize = 16,
	glyphCount = 95
}

fontDefault.glyphs = rl.LoadFontData(fileData, fileSize, 16, nil, 95, rl.FONT_DEFAULT)
fontDefault.glyphCount = 95

local atlas = rl.GenImageFontAtlas(fontDefault.glyphs, nil, 95, 16, 4, 0)
fontDefault.texture = rl.LoadTextureFromImage(atlas)
rl.UnloadImage(atlas)

local fontSDF = {
	baseSize = 16,
	glyphCount = 95
}

fontSDF.glyphs = rl.LoadFontData(fileData, fileSize, 16, nil, 0, rl.FONT_SDF)
fontSDF.glyphCount = 95

atlas = rl.GenImageFontAtlas(fontSDF.glyphs, nil, 95, 16, 0, 1)
fontSDF.texture = rl.LoadTextureFromImage(atlas)
rl.UnloadImage(atlas)

rl.UnloadFileData(fileData)

local shader = rl.LoadShader(0, "resources/glsl430/sdf.fs")
rl.SetTextureFilter(fontSDF.texture, rl.TEXTURE_FILTER_BILINEAR)

local fontPosition = rl.rlVertex2f(40, rl.GetScreenHeight() / 2.0 - 50)
local textSize = { x = 0.0, y = 0.0 }
local fontSize = 16.0
local currentFont = 0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	fontSize = fontSize + rl.GetMouseWheelMove() * 8.0

	if fontSize < 6 then
		fontSize = 6
	end

	if rl.IsKeyDown(rl.KEY_SPACE) then
		currentFont = 1
	else
		currentFont = 0
	end

	if currentFont == 0 then
		textSize = rl.MeasureTextEx(fontDefault, msg, fontSize, 0)
	else
		textSize = rl.MeasureTextEx(fontSDF, msg, fontSize, 0)
	end

	fontPosition.x = rl.GetScreenWidth() / 2.0 - textSize.x / 2.0
	fontPosition.y = rl.GetScreenHeight() / 2.0 - textSize.y / 2.0 + 80

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		if currentFont == 1 then
			rl.BeginShaderMode(shader)
				rl.DrawTextEx(fontSDF, msg, fontPosition, fontSize, 0, rl.BLACK)
			rl.EndShaderMode()

			rl.DrawTexture(fontSDF.texture, 10, 10, rl.BLACK)
		else
			rl.DrawTextEx(fontDefault, msg, fontPosition, fontSize, 0, rl.BLACK)
			rl.DrawTexture(fontDefault.texture, 10, 10, rl.BLACK)
		end

		if currentFont == 1 then
			rl.DrawText("SDF!", 320, 20, 80, rl.RED)
		else
			rl.DrawText("default font", 315, 40, 30, rl.GRAY)
		end

		rl.DrawText("FONT SIZE: 16.0", rl.GetScreenWidth() - 240, 20, 20, rl.DARKGRAY)
		rl.DrawText(string.format("RENDER SIZE: %02.02f", fontSize), rl.GetScreenWidth() - 240, 50, 20, rl.DARKGRAY)
		rl.DrawText("Use MOUSE WHEEL to SCALE TEXT!", rl.GetScreenWidth() - 240, 90, 10, rl.DARKGRAY)

		rl.DrawText("HOLD SPACE to USE SDF FONT VERSION!", 340, rl.GetScreenHeight() - 30, 20, rl.MAROON)
	rl.EndDrawing()
end

rl.UnloadFont(fontDefault)
rl.UnloadFont(fontSDF)
rl.UnloadShader(shader)
rl.CloseWindow()