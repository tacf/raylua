--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/text/text_unicode_ranges.c

]]

rl.InitWindow(800, 450, "raylib [text] example - unicode ranges")

local font = rl.LoadFont("resources/NotoSansTC-Regular.ttf")
rl.SetTextureFilter(font.texture, rl.TEXTURE_FILTER_BILINEAR)

local unicodeRange = 0
local prevUnicodeRange = 0

rl.SetTargetFPS(60)

local function AddCodepointRange(font, fontPath, start, stop)
	local rangeSize = stop - start + 1
	local currentRangeSize = font.glyphCount

	local updatedCodepointCount = currentRangeSize + rangeSize
	local updatedCodepoints = {}

	for i = 1, currentRangeSize do
		updatedCodepoints[i] = font.glyphs[i].value
	end

	for i = currentRangeSize + 1, updatedCodepointCount do
		updatedCodepoints[i] = start + (i - currentRangeSize)
	end

	rl.UnloadFont(font)
	font = rl.LoadFontEx(fontPath, 32, updatedCodepoints, updatedCodepointCount)
	return font
end

while not rl.WindowShouldClose() do
	if unicodeRange ~= prevUnicodeRange then
		rl.UnloadFont(font)

		font = rl.LoadFont("resources/NotoSansTC-Regular.ttf")

		if unicodeRange == 4 then
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x4e00, 0x9fff)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x3400, 0x4dbf)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x3000, 0x303f)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x3040, 0x309f)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x30A0, 0x30ff)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x31f0, 0x31ff)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0xff00, 0xffef)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0xac00, 0xd7af)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x1100, 0x11ff)
		end

		if unicodeRange >= 3 then
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x400, 0x4ff)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x500, 0x52f)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x2de0, 0x2Dff)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0xa640, 0xA69f)
		end

		if unicodeRange >= 2 then
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x370, 0x3ff)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x1f00, 0x1fff)
		end

		if unicodeRange >= 1 then
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0xc0, 0x17f)
			font = AddCodepointRange(font, "resources/NotoSansTC-Regular.ttf", 0x180, 0x24f)
		end

		prevUnicodeRange = unicodeRange
		rl.SetTextureFilter(font.texture, rl.TEXTURE_FILTER_BILINEAR)
	end

	if rl.IsKeyPressed(rl.KEY_ZERO) then
		unicodeRange = 0
	elseif rl.IsKeyPressed(rl.KEY_ONE) then
		unicodeRange = 1
	elseif rl.IsKeyPressed(rl.KEY_TWO) then
		unicodeRange = 2
	elseif rl.IsKeyPressed(rl.KEY_THREE) then
		unicodeRange = 3
	elseif rl.IsKeyPressed(rl.KEY_FOUR) then
		unicodeRange = 4
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawText("ADD CODEPOINTS: [1][2][3][4]", 20, 20, 20, rl.MAROON)

		rl.DrawTextEx(font, "> English: Hello World!", rl.rlVertex2f(50, 70), 32, 1, rl.DARKGRAY)
		rl.DrawTextEx(font, "> Español: Hola mundo!", rl.rlVertex2f(50, 120), 32, 1, rl.DARKGRAY)
		rl.DrawTextEx(font, "> Ελληνικά: Γειά σου κόσμε!", rl.rlVertex2f(50, 170), 32, 1, rl.DARKGRAY)
		rl.DrawTextEx(font, "> Русский: Привет мир!", rl.rlVertex2f(50, 220), 32, 0, rl.DARKGRAY)
		rl.DrawTextEx(font, "> 中文: 你好世界!", rl.rlVertex2f(50, 270), 32, 1, rl.DARKGRAY)
		rl.DrawTextEx(font, "> 日本語: こんにちは世界!", rl.rlVertex2f(50, 320), 32, 1, rl.DARKGRAY)

		local atlasScale = 380.0 / font.texture.width
		rl.DrawRectangle(400.0, 16.0, font.texture.width * atlasScale, font.texture.height * atlasScale, rl.BLACK)
		rl.DrawTexturePro(font.texture, { x = 0, y = 0, width = font.texture.width, height = font.texture.height },
			{ x = 400.0, y = 16.0, width = font.texture.width * atlasScale, height = font.texture.height * atlasScale },
			{ x = 0, y = 0 }, 0.0, rl.WHITE)
		rl.DrawRectangleLines(400, 16, 380, 380, rl.RED)

		rl.DrawText(string.format("ATLAS SIZE: %ix%i px (x%02.2f)", font.texture.width, font.texture.height, atlasScale), 20, 380, 20, rl.BLUE)
		rl.DrawText(string.format("CODEPOINTS GLYPHS LOADED: %i", font.glyphCount), 20, 410, 20, rl.LIME)

		rl.DrawText("Font: Noto Sans TC. License: SIL Open Font License 1.1", rl.GetScreenWidth() - 300, rl.GetScreenHeight() - 20, 10, rl.GRAY)

		if prevUnicodeRange ~= unicodeRange then
			rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.Fade(rl.WHITE, 0.8))
			rl.DrawRectangle(0, 125, rl.GetScreenWidth(), 200, rl.GRAY)
			rl.DrawText("GENERATING FONT ATLAS...", 120, 210, 40, rl.BLACK)
		end
	rl.EndDrawing()
end

rl.UnloadFont(font)
rl.CloseWindow()