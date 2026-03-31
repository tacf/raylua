rl.InitWindow(800, 450, "raylib [text] example - font filters")

local msg = "Loaded Font"

local font = rl.LoadFontEx("resources/NotoSans-Medium.ttf", 96, nil, 0)

rl.GenTextureMipmaps(font.texture)

local fontSize = font.baseSize
local fontPosition = rl.rlVertex2f(40.0, rl.GetScreenHeight() / 2.0 - 80.0)
local textSize = { x = 0.0, y = 0.0 }

rl.SetTextureFilter(font.texture, rl.TEXTURE_FILTER_POINT)
local currentFontFilter = 0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	fontSize = fontSize + rl.GetMouseWheelMove() * 4.0

	if rl.IsKeyPressed(rl.KEY_ONE) then
		rl.SetTextureFilter(font.texture, rl.TEXTURE_FILTER_POINT)
		currentFontFilter = 0
	elseif rl.IsKeyPressed(rl.KEY_TWO) then
		rl.SetTextureFilter(font.texture, rl.TEXTURE_FILTER_BILINEAR)
		currentFontFilter = 1
	elseif rl.IsKeyPressed(rl.KEY_THREE) then
		rl.SetTextureFilter(font.texture, rl.TEXTURE_FILTER_TRILINEAR)
		currentFontFilter = 2
	end

	textSize = rl.MeasureTextEx(font, msg, fontSize, 0)

	if rl.IsKeyDown(rl.KEY_LEFT) then
		fontPosition.x = fontPosition.x - 10
	elseif rl.IsKeyDown(rl.KEY_RIGHT) then
		fontPosition.x = fontPosition.x + 10
	end

	if rl.IsFileDropped() then
		local droppedFiles = rl.LoadDroppedFiles()
		local filepath = droppedFiles.paths[0]
		if rl.IsFileExtension(filepath, ".ttf") then
			rl.UnloadFont(font)
			font = rl.LoadFontEx(filepath, fontSize, nil, 0)
		end
		rl.UnloadDroppedFiles(droppedFiles)
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawText("Use mouse wheel to change font size", 20, 20, 10, rl.GRAY)
		rl.DrawText("Use KEY_RIGHT and KEY_LEFT to move text", 20, 40, 10, rl.GRAY)
		rl.DrawText("Use 1, 2, 3 to change texture filter", 20, 60, 10, rl.GRAY)
		rl.DrawText("Drop a new TTF font for dynamic loading", 20, 80, 10, rl.DARKGRAY)

		rl.DrawTextEx(font, msg, fontPosition, fontSize, 0, rl.BLACK)

		rl.DrawRectangle(0, rl.GetScreenHeight() - 80, rl.GetScreenWidth(), 80, rl.LIGHTGRAY)
		rl.DrawText(string.format("Font size: %02.02f", fontSize), 20, rl.GetScreenHeight() - 50, 10, rl.DARKGRAY)
		rl.DrawText(string.format("Text size: [%02.02f, %02.02f]", textSize.x, textSize.y), 20, rl.GetScreenHeight() - 30, 10, rl.DARKGRAY)
		rl.DrawText("CURRENT TEXTURE FILTER:", 250, 400, 20, rl.GRAY)

		if currentFontFilter == 0 then
			rl.DrawText("POINT", 570, 400, 20, rl.BLACK)
		elseif currentFontFilter == 1 then
			rl.DrawText("BILINEAR", 570, 400, 20, rl.BLACK)
		elseif currentFontFilter == 2 then
			rl.DrawText("TRILINEAR", 570, 400, 20, rl.BLACK)
		end
	rl.EndDrawing()
end

rl.UnloadFont(font)
rl.CloseWindow()