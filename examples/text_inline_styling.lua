rl.InitWindow(800, 450, "raylib [text] example - inline styling")

local textSize = { x = 0, y = 0 }
local colRandom = rl.RED
local frameCounter = 0

rl.SetTargetFPS(60)

local function DrawTextStyled(font, text, position, fontSize, spacing, color)
	if font.texture.id == 0 then
		font = rl.GetFontDefault()
	end

	local textLen = #text

	local colFront = color
	local colBack = rl.BLANK
	local backRecPadding = 4

	local textOffsetY = 0.0
	local textOffsetX = 0.0
	local textLineSpacing = 0.0
	local scaleFactor = fontSize / font.baseSize

	local i = 1
	while i <= textLen do
		local codepoint, codepointByteCount = rl.GetCodepointNext(text, i)

		if codepoint == 10 then
			textOffsetY = textOffsetY + fontSize + textLineSpacing
			textOffsetX = 0.0
		else
			if codepoint == 91 then
				if (i + 2 <= textLen) and (text:sub(i + 1, i + 1) == "r") and (text:sub(i + 2, i + 2) == "]") then
					colFront = color
					colBack = rl.BLANK
					i = i + 3
				elseif (i + 1 <= textLen) and ((text:sub(i + 1, i + 1) == "c") or (text:sub(i + 1, i + 1) == "b")) then
					i = i + 2

					local colHexText = ""
					local textPtr = text:sub(i)

					local colHexCount = 0
					local j = 1
					while j <= #textPtr do
						local c = textPtr:sub(j, j)
						if ((c >= "0") and (c <= "9")) or ((c >= "A") and (c <= "F")) or ((c >= "a") and (c <= "f")) then
							colHexText = colHexText .. c
							colHexCount = colHexCount + 1
						elseif c == "]" then
							break
						else
							break
						end
						j = j + 1
					end

					local function hexToColor(hex)
						local r = tonumber(hex:sub(1, 2), 16) or 0
						local g = tonumber(hex:sub(3, 4), 16) or 0
						local b = tonumber(hex:sub(5, 6), 16) or 0
						local a = tonumber(hex:sub(7, 8), 16) or 255
						return { r = r, g = g, b = b, a = a }
					end

					local colHexValue = tonumber(colHexText, 16) or 0
					if text:sub(i - 1, i - 1) == "c" then
						colFront = rl.GetColor(colHexValue)
					elseif text:sub(i - 1, i - 1) == "b" then
						colBack = rl.GetColor(colHexValue)
					end

					i = i + colHexCount + 1
				else
					local index = rl.GetGlyphIndex(font, codepoint)
					local increaseX = 0.0

					if font.glyphs[index].advanceX == 0 then
						increaseX = font.recs[index].width * scaleFactor + spacing
					else
						increaseX = increaseX + font.glyphs[index].advanceX * scaleFactor + spacing
					end

					if colBack.a > 0 then
						rl.DrawRectangle(position.x + textOffsetX, position.y + textOffsetY - backRecPadding, increaseX, fontSize + 2 * backRecPadding, colBack)
					end

					if (codepoint ~= 32) and (codepoint ~= 9) then
						rl.DrawTextCodepoint(font, codepoint, { x = position.x + textOffsetX, y = position.y + textOffsetY }, fontSize, colFront)
					end

					textOffsetX = textOffsetX + increaseX
				end
			else
				local index = rl.GetGlyphIndex(font, codepoint)
				local increaseX = 0.0

				if font.glyphs[index].advanceX == 0 then
					increaseX = font.recs[index].width * scaleFactor + spacing
				else
					increaseX = increaseX + font.glyphs[index].advanceX * scaleFactor + spacing
				end

				if colBack.a > 0 then
					rl.DrawRectangle(position.x + textOffsetX, position.y + textOffsetY - backRecPadding, increaseX, fontSize + 2 * backRecPadding, colBack)
				end

				if (codepoint ~= 32) and (codepoint ~= 9) then
					rl.DrawTextCodepoint(font, codepoint, { x = position.x + textOffsetX, y = position.y + textOffsetY }, fontSize, colFront)
				end

				textOffsetX = textOffsetX + increaseX
			end
		end

		i = i + codepointByteCount
	end
end

local function MeasureTextStyled(font, text, fontSize, spacing)
	local textSize = { x = 0, y = 0 }

	if (font.texture.id == 0) or (text == nil) or (text == "") then
		return textSize
	end

	local textLen = #text

	local textWidth = 0.0
	local textHeight = fontSize
	local scaleFactor = fontSize / font.baseSize

	local codepoint = 0
	local index = 0
	local validCodepointCounter = 0

	local i = 1
	while i <= textLen do
		local codepointByteCount = 0
		codepoint = rl.GetCodepointNext(text, i)

		if codepoint == 91 then
			if (i + 2 <= textLen) and (text:sub(i + 1, i + 1) == "r") and (text:sub(i + 2, i + 2) == "]") then
				i = i + 3
			elseif (i + 1 <= textLen) and ((text:sub(i + 1, i + 1) == "c") or (text:sub(i + 1, i + 1) == "b")) then
				i = i + 2

				local textPtr = text:sub(i)
				local colHexCount = 0
				local j = 1
				while j <= #textPtr do
					local c = textPtr:sub(j, j)
					if ((c >= "0") and (c <= "9")) or ((c >= "A") and (c <= "F")) or ((c >= "a") and (c <= "f")) then
						colHexCount = colHexCount + 1
					elseif c == "]" then
						break
					else
						break
					end
					j = j + 1
				end

				i = i + colHexCount + 1
			else
				i = i + codepointByteCount
			end
		elseif codepoint ~= 10 then
			index = rl.GetGlyphIndex(font, codepoint)

			if font.glyphs[index].advanceX > 0 then
				textWidth = textWidth + font.glyphs[index].advanceX
			else
				textWidth = textWidth + font.recs[index].width + font.glyphs[index].offsetX
			end

			validCodepointCounter = validCodepointCounter + 1
			i = i + codepointByteCount
		end
	end

	textSize.x = textWidth * scaleFactor + (validCodepointCounter - 1) * spacing
	textSize.y = textHeight

	return textSize
end

while not rl.WindowShouldClose() do
	frameCounter = frameCounter + 1

	if (frameCounter % 20) == 0 then
		colRandom.r = rl.GetRandomValue(0, 255)
		colRandom.g = rl.GetRandomValue(0, 255)
		colRandom.b = rl.GetRandomValue(0, 255)
		colRandom.a = 255
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		DrawTextStyled(rl.GetFontDefault(), "This changes the [cFF0000FF]foreground color[r] of provided text!!!", rl.rlVertex2f(100, 80), 20.0, 2.0, rl.BLACK)
		DrawTextStyled(rl.GetFontDefault(), "This changes the [bFF00FFFF]background color[r] of provided text!!!", rl.rlVertex2f(100, 120), 20.0, 2.0, rl.BLACK)
		DrawTextStyled(rl.GetFontDefault(), "This changes the [c00ff00ff][bff0000ff]foreground and background colors[r]!!!", rl.rlVertex2f(100, 160), 20.0, 2.0, rl.BLACK)
		DrawTextStyled(rl.GetFontDefault(), "This changes the [c00ff00ff]alpha[r] relative [cffffffff][b000000ff]from source[r] [cff000088]color[r]!!!", rl.rlVertex2f(100, 200), 20.0, 2.0, { r = 0, g = 0, b = 0, a = 100 })

		local txt = string.format("Let's be [c%02x%02x%02xFF]CREATIVE[r] !!!", colRandom.r, colRandom.g, colRandom.b)
		DrawTextStyled(rl.GetFontDefault(), txt, rl.rlVertex2f(100, 240), 40.0, 2.0, rl.BLACK)

		textSize = MeasureTextStyled(rl.GetFontDefault(), txt, 40.0, 2.0)
		rl.DrawRectangleLines(100, 240, textSize.x, textSize.y, rl.GREEN)
	rl.EndDrawing()
end

rl.CloseWindow()