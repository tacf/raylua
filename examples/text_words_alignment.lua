rl.InitWindow(800, 450, "raylib [text] example - words alignment")

local TEXT_ALIGN_LEFT = 0
local TEXT_ALIGN_TOP = 0
local TEXT_ALIGN_CENTRE = 1
local TEXT_ALIGN_MIDDLE = 1
local TEXT_ALIGN_RIGHT = 2
local TEXT_ALIGN_BOTTOM = 2

local textContainerRect = {
	x = rl.GetScreenWidth() / 2 - rl.GetScreenWidth() / 4,
	y = rl.GetScreenHeight() / 2 - rl.GetScreenHeight() / 3,
	width = rl.GetScreenWidth() / 2,
	height = rl.GetScreenHeight() * 2 / 3
}

local textAlignNameH = { "Left", "Centre", "Right" }
local textAlignNameV = { "Top", "Middle", "Bottom" }

local wordIndex = 0
local wordCount = 0

local function TextSplit(text, delimiter)
	local tokens = {}
	local count = 0
	for token in text:gmatch("[^" .. delimiter .. "]+") do
		count = count + 1
		tokens[count] = token
	end
	return tokens, count
end

local words, wordCount = TextSplit("raylib is a simple and easy-to-use library to enjoy videogames programming", " ")

local fontSize = 40

local font = rl.GetFontDefault()

local hAlign = TEXT_ALIGN_CENTRE
local vAlign = TEXT_ALIGN_MIDDLE

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	if rl.IsKeyPressed(rl.KEY_LEFT) then
		if hAlign > 0 then
			hAlign = hAlign - 1
		end
	end

	if rl.IsKeyPressed(rl.KEY_RIGHT) then
		hAlign = hAlign + 1
		if hAlign > 2 then
			hAlign = 2
		end
	end

	if rl.IsKeyPressed(rl.KEY_UP) then
		if vAlign > 0 then
			vAlign = vAlign - 1
		end
	end

	if rl.IsKeyPressed(rl.KEY_DOWN) then
		vAlign = vAlign + 1
		if vAlign > 2 then
			vAlign = 2
		end
	end

	if wordCount > 0 then
		wordIndex = math.floor(rl.GetTime()) % wordCount
	else
		wordIndex = 0
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.DARKBLUE)

		rl.DrawText("Use Arrow Keys to change the text alignment", 20, 20, 20, rl.LIGHTGRAY)
		rl.DrawText(string.format("Alignment: Horizontal = %s, Vertical = %s", textAlignNameH[hAlign + 1], textAlignNameV[vAlign + 1]), 20, 40, 20, rl.LIGHTGRAY)

		rl.DrawRectangleRec(textContainerRect, rl.BLUE)

		local textSize = rl.MeasureTextEx(font, words[wordIndex + 1], fontSize, fontSize * 0.1)

		local textPos = {
			x = textContainerRect.x + (0.0 + (textContainerRect.width - textSize.x) * hAlign / 2),
			y = textContainerRect.y + (0.0 + (textContainerRect.height - textSize.y) * vAlign / 2)
		}

		rl.DrawTextEx(font, words[wordIndex + 1], textPos, fontSize, fontSize * 0.1, rl.RAYWHITE)
	rl.EndDrawing()
end

rl.CloseWindow()