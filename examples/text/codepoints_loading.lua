--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/text/text_codepoints_loading.c

]]

rl.InitWindow(800, 450, "raylib [text] example - codepoints loading")

local text = "いろはにほへと　ちりぬるを\nわかよたれそ　つねならむ\nうゐのおくやま　けふこえて\nあさきゆめみし　ゑひもせす"

local codepointCount = 0
local codepoints = rl.LoadCodepoints(text, codepointCount)

local function CodepointRemoveDuplicates(codepoints, codepointCount)
	local codepointsNoDupsCount = codepointCount
	local codepointsNoDups = {}
	for i = 1, codepointCount do
		codepointsNoDups[i] = codepoints[i]
	end

	for i = 1, codepointsNoDupsCount do
		for j = i + 1, codepointsNoDupsCount do
			if codepointsNoDups[i] == codepointsNoDups[j] then
				for k = j, codepointsNoDupsCount - 1 do
					codepointsNoDups[k] = codepointsNoDups[k + 1]
				end
				codepointsNoDupsCount = codepointsNoDupsCount - 1
				j = j - 1
			end
		end
	end

	return codepointsNoDups, codepointsNoDupsCount
end

local codepointsNoDups, codepointsNoDupsCount = CodepointRemoveDuplicates(codepoints, codepointCount)
rl.UnloadCodepoints(codepoints)

local font = rl.LoadFontEx("resources/NotoSans-Medium.ttf", 36, codepointsNoDups, codepointsNoDupsCount)

rl.SetTextureFilter(font.texture, rl.TEXTURE_FILTER_BILINEAR)

rl.SetTextLineSpacing(20)

local showFontAtlas = false

local codepointSize = 0
local ptr = text

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsKeyPressed(rl.KEY_SPACE) then
		showFontAtlas = not showFontAtlas
	end

	if rl.IsKeyPressed(rl.KEY_RIGHT) then
		local nextCodepoint, size = rl.GetCodepointNext(ptr, codepointSize)
		ptr = ptr:sub(codepointSize + 1)
		codepointSize = size
	elseif rl.IsKeyPressed(rl.KEY_LEFT) then
		local prevCodepoint, size = rl.GetCodepointPrevious(ptr, codepointSize)
		ptr = ptr:sub(1, codepointSize - 1)
		codepointSize = size
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawRectangle(0, 0, rl.GetScreenWidth(), 70, rl.BLACK)
		rl.DrawText(string.format("Total codepoints contained in provided text: %i", codepointCount), 10, 10, 20, rl.GREEN)
		rl.DrawText(string.format("Total codepoints required for font atlas (duplicates excluded): %i", codepointsNoDupsCount), 10, 40, 20, rl.GREEN)

		if showFontAtlas then
			rl.DrawTexture(font.texture, 150, 100, rl.BLACK)
			rl.DrawRectangleLines(150, 100, font.texture.width, font.texture.height, rl.BLACK)
		else
			rl.DrawTextEx(font, text, rl.rlVertex2f(160, 110), 48, 5, rl.BLACK)
		end

		rl.DrawText("Press SPACE to toggle font atlas view!", 10, rl.GetScreenHeight() - 30, 20, rl.GRAY)
	rl.EndDrawing()
end

rl.UnloadFont(font)
rl.CloseWindow()