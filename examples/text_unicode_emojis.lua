rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT + rl.FLAG_VSYNC_HINT)

rl.InitWindow(800, 450, "raylib [text] example - unicode emojis")

local EMOJI_PER_WIDTH = 8
local EMOJI_PER_HEIGHT = 4

local emoji = {}
for i = 1, EMOJI_PER_WIDTH * EMOJI_PER_HEIGHT do
	emoji[i] = { index = 0, message = 0, color = { r = 0, g = 0, b = 0, a = 0 } }
end

local hovered = -1
local selected = -1

local emojiCodepoints = {
	"\xF0\x9F\x8C\x80", "\xF0\x9F\x98\x80", "\xF0\x9F\x98\x82", "\xF0\x9F\xA4\xA3", "\xF0\x9F\x98\x83", "\xF0\x9F\x98\x86", "\xF0\x9F\x98\x89",
	"\xF0\x9F\x98\x8B", "\xF0\x9F\x98\x8E", "\xF0\x9F\x98\x8D", "\xF0\x9F\x98\x98", "\xF0\x9F\x98\x97", "\xF0\x9F\x98\x99", "\xF0\x9F\x98\x9A", "\xF0\x9F\x99\x82",
	"\xF0\x9F\xA4\x97", "\xF0\x9F\xA4\xA9", "\xF0\x9F\xA4\x94", "\xF0\x9F\xA4\xA8", "\xF0\x9F\x98\x90", "\xF0\x9F\x98\x91", "\xF0\x9F\x98\xB6", "\xF0\x9F\x99\x84",
	"\xF0\x9F\x98\x8F", "\xF0\x9F\x98\xA3", "\xF0\x9F\x98\xA5", "\xF0\x9F\x98\xAE", "\xF0\x9F\xA4\x90", "\xF0\x9F\x98\xAF", "\xF0\x9F\x98\xAA", "\xF0\x9F\x98\xAB",
	"\xF0\x9F\x98\xB4", "\xF0\x9F\x98\x8C", "\xF0\x9F\x98\x9B", "\xF0\x9F\x98\x9D", "\xF0\x9F\xA4\xA4", "\xF0\x9F\x98\x92", "\xF0\x9F\x98\x95", "\xF0\x9F\x99\x83",
	"\xF0\x9F\xA4\x91", "\xF0\x9F\x98\xB2", "\xF0\x9F\x99\x81", "\xF0\x9F\x98\x96", "\xF0\x9F\x98\x9E", "\xF0\x9F\x98\x9F", "\xF0\x9F\x98\xA4", "\xF0\x9F\x98\xA2",
	"\xF0\x9F\x98\xAD", "\xF0\x9F\x98\xA6", "\xF0\x9F\x98\xA9", "\xF0\x9F\xA4\xAF", "\xF0\x9F\x98\xAC", "\xF0\x9F\x98\xB0", "\xF0\x9F\x98\xB1", "\xF0\x9F\x98\xB3",
	"\xF0\x9F\xA4\xAA", "\xF0\x9F\x98\xB5", "\xF0\x9F\x98\xA1", "\xF0\x9F\x98\xA0", "\xF0\x9F\xA4\xAC", "\xF0\x9F\x98\xB7", "\xF0\x9F\xA4\x92", "\xF0\x9F\xA4\x95",
	"\xF0\x9F\xA4\xA2", "\xF0\x9F\xA4\xAE", "\xF0\x9F\xA4\xA7", "\xF0\x9F\x98\x87", "\xF0\x9F\xA4\xA0", "\xF0\x9F\xA4\xAB", "\xF0\x9F\xA4\xAD", "\xF0\x9F\xA7\x90",
	"\xF0\x9F\xA4\x93", "\xF0\x9F\x98\x88", "\xF0\x9F\x91\xBF", "\xF0\x9F\x91\xB9", "\xF0\x9F\x91\xBA", "\xF0\x9F\x92\x80", "\xF0\x9F\x91\xBB", "\xF0\x9F\x91\xBD",
	"\xF0\x9F\x91\xBE", "\xF0\x9F\xA4\x96", "\xF0\x9F\x92\xA9", "\xF0\x9F\x98\xBA", "\xF0\x9F\x98\xB8", "\xF0\x9F\x98\xB9", "\xF0\x9F\x98\xBB", "\xF0\x9F\x98\xBD",
	"\xF0\x9F\x99\x80", "\xF0\x9F\x98\xBF", "\xF0\x9F\x8C\xBE", "\xF0\x9F\x8C\xBF", "\xF0\x9F\x8D\x80", "\xF0\x9F\x8D\x83", "\xF0\x9F\x8D\x87", "\xF0\x9F\x8D\x93",
	"\xF0\x9F\xA5\x9D", "\xF0\x9F\x8D\x85", "\xF0\x9F\xA5\xA5", "\xF0\x9F\xA5\x91", "\xF0\x9F\x8D\x86", "\xF0\x9F\xA5\x94", "\xF0\x9F\xA5\x95", "\xF0\x9F\x8C\xBD",
	"\xF0\x9F\x8C\xB6", "\xF0\x9F\xA5\x92", "\xF0\x9F\xA5\xA6", "\xF0\x9F\x8D\x84", "\xF0\x9F\xA5\x9C", "\xF0\x9F\x8C\xB0", "\xF0\x9F\x8D\x9E", "\xF0\x9F\xA5\x90",
	"\xF0\x9F\xA5\x96", "\xF0\x9F\xA5\xA8", "\xF0\x9F\xA5\x9E", "\xF0\x9F\xA7\x80", "\xF0\x9F\x8D\x96", "\xF0\x9F\x8D\x97", "\xF0\x9F\xA5\xA9", "\xF0\x9F\xA5\x93",
	"\xF0\x9F\x8D\x94", "\xF0\x9F\x8D\x9F", "\xF0\x9F\x8D\x95", "\xF0\x9F\x8C\xAD", "\xF0\x9F\xA5\xAA", "\xF0\x9F\x8C\xAE", "\xF0\x9F\x8C\xAF", "\xF0\x9F\xA5\x99",
	"\xF0\x9F\xA5\x9A", "\xF0\x9F\x8D\xB3", "\xF0\x9F\xA5\x98", "\xF0\x9F\x8D\xB2", "\xF0\x9F\xA5\xA3", "\xF0\x9F\xA5\x97", "\xF0\x9F\x8D\xBF", "\xF0\x9F\xA5\xAB",
	"\xF0\x9F\x8D\xB1", "\xF0\x9F\x8D\x98", "\xF0\x9F\x8D\x9D", "\xF0\x9F\x8D\xA0", "\xF0\x9F\x8D\xA2", "\xF0\x9F\x8D\xA5", "\xF0\x9F\x8D\xA1", "\xF0\x9F\xA5\x9F",
	"\xF0\x9F\xA5\xA1", "\xF0\x9F\x8D\xA6", "\xF0\x9F\x8D\xAA", "\xF0\x9F\x8E\x82", "\xF0\x9F\x8D\xB0", "\xF0\x9F\xA5\xA7", "\xF0\x9F\x8D\xAB", "\xF0\x9F\x8D\xAF",
	"\xF0\x9F\x8D\xBC", "\xF0\x9F\xA5\x9B", "\xF0\x9F\x8D\xB5", "\xF0\x9F\x8D\xB6", "\xF0\x9F\x8D\xBE", "\xF0\x9F\x8D\xB7", "\xF0\x9F\x8D\xBB", "\xF0\x9F\xA5\x82",
	"\xF0\x9F\xA5\x83", "\xF0\x9F\xA5\xA4", "\xF0\x9F\xA5\xA2", "\xF0\x9F\x91\x81", "\xF0\x9F\x91\x85", "\xF0\x9F\x91\x84", "\xF0\x9F\x92\x8B", "\xF0\x9F\x92\x98",
	"\xF0\x9F\x92\x93", "\xF0\x9F\x92\x97", "\xF0\x9F\x92\x99", "\xF0\x9F\x92\x9B", "\xF0\x9F\xA7\xA1", "\xF0\x9F\x92\x9C", "\xF0\x9F\x96\xA4", "\xF0\x9F\x92\x9D",
	"\xF0\x9F\x92\x9F", "\xF0\x9F\x92\x8C", "\xF0\x9F\x92\xA4", "\xF0\x9F\x92\xA2", "\xF0\x9F\x92\xA3"
}

local messages = {
	{ text = "Falsches von Xylophonsik quält jede größere Zwer", language = "German" },
	{ text = "Beich nicht in die Hand, die dich füttert.", language = "German" },
	{ text = "Außerordentlich erfordernde Mittel.", language = "German" },
	{ text = "Ողջ մնալու համար պետք է լինել հզոր", language = "Armenian" },
	{ text = "Բայց դու հետո էլ չես կարող գնալ դու էլ չես կարող գնալ", language = "Armenian" },
	{ text = "Գաղտնիք է որ դու էլ չես կարող", language = "Armenian" },
	{ text = "Jeśli kłamstwo jest piękne, szczęście jest prawdziwe", language = "Polish" },
	{ text = "Dobrymi chciami jest pieko wybrukowane.", language = "Polish" },
	{ text = "În curând totul va fi bine", language = "Romanian" },
	{ text = "Эх, чужак, обратно в будущее!", language = "Russian" },
	{ text = "Люблю raylib!", language = "Russian" },
	{ text = "Молчи, скрывайся и тайно смейся", language = "Russian" },
	{ text = "Voix ambiguë d'un cœur qui au prix d'un zephyr", language = "French" },
	{ text = "Benjamín pidió una bebida de kiwi y fresa; No, sinvergüenza, la más exquisita champaña del menú.", language = "Spanish" },
	{ text = "Ταχύτητα και ασφάλεια", language = "Greek" },
	{ text = "Η καλύτερη τιμή", language = "Greek" },
	{ text = "Χρονιά καί γραμμή!", language = "Greek" },
	{ text = "Πάσχε τά σήμερα", language = "Greek" },
	{ text = "我能吞下玻璃而不伤身体。", language = "Chinese" },
	{ text = "你好了吗？", language = "Chinese" },
	{ text = "不伤身体。", language = "Chinese" },
	{ text = "最近好吗？", language = "Chinese" },
	{ text = "塞翁失马，焉知非福。", language = "Chinese" },
	{ text = "一旦一将功成", language = "Chinese" },
	{ text = "万事开头难。", language = "Chinese" },
	{ text = "风无常态，兵无常胜。", language = "Chinese" },
	{ text = "活到老，学到老。", language = "Chinese" },
	{ text = "一箭既出，驷马难追。", language = "Chinese" },
	{ text = "路遥知马力，日久见人心。", language = "Chinese" },
	{ text = "有理走遍天下，无理寸步难行。", language = "Chinese" },
	{ text = "いろはにほへとちりぬるを", language = "Japanese" },
	{ text = "一部の者は五年後の自己的身体", language = "Japanese" },
	{ text = "うきはしめりしよりあめはれて", language = "Japanese" },
	{ text = "虎穴に入らずんば虎子を得ず", language = "Japanese" },
	{ text = "二度を追う者は一度も得ず", language = "Japanese" },
	{ text = "馬鹿は死なないが馬鹿を見る", language = "Japanese" },
	{ text = "敵は本能寺にあり", language = "Japanese" },
	{ text = "残り火の吹雪きpf節和建议", language = "Japanese" },
	{ text = "아침来临은 저의 손에 있습니다", language = "Korean" },
	{ text = "제 발에 안경입니다", language = "Korean" },
	{ text = "많고 높고 알은 것입니다", language = "Korean" },
	{ text = "로마는 하루아침에 이루어진 것이 아니다", language = "Korean" },
	{ text = "고생 끝에 낙이 온다", language = "Korean" },
	{ text = "개천에서 용난다", language = "Korean" },
	{ text = "안녕하셍?", language = "Korean" },
	{ text = "만나서 반갑습니다", language = "Korean" },
	{ text = "한글말 하실 줄 아세요?", language = "Korean" }
}

local fontDefault = rl.LoadFont("resources/dejavu.fnt")
local fontAsian = rl.LoadFont("resources/noto_cjk.fnt")
local fontEmoji = rl.LoadFont("resources/symbola.fnt")

local hoveredPos = { x = 0.0, y = 0.0 }
local selectedPos = { x = 0.0, y = 0.0 }

local function RandomizeEmoji()
	hovered = -1
	selected = -1
	local start = rl.GetRandomValue(45, 360)

	for i = 1, EMOJI_PER_WIDTH * EMOJI_PER_HEIGHT do
		emoji[i].index = rl.GetRandomValue(0, 179) * 5

		local hue = (start * (i + 1)) % 360
		emoji[i].color = rl.Fade(rl.ColorFromHSV(hue, 0.6, 0.85), 0.8)

		emoji[i].message = rl.GetRandomValue(1, #messages)
	end
end

RandomizeEmoji()

rl.SetTargetFPS(60)

local function DrawTextBoxed(font, text, rec, fontSize, spacing, wordWrap, tint)
	DrawTextBoxedSelectable(font, text, rec, fontSize, spacing, wordWrap, tint, 0, 0, rl.WHITE, rl.WHITE)
end

local function DrawTextBoxedSelectable(font, text, rec, fontSize, spacing, wordWrap, tint, selectStart, selectLength, selectTint, selectBackTint)
	local length = #text

	local textOffsetY = 0.0
	local textOffsetX = 0.0

	local scaleFactor = fontSize / font.baseSize

	local MEASURE_STATE = 0
	local DRAW_STATE = 1
	local state = wordWrap and MEASURE_STATE or DRAW_STATE

	local startLine = -1
	local endLine = -1
	local lastk = -1

	local i = 1
	local k = 1
	while i <= length do
		local codepointByteCount = 0
		local codepoint = rl.GetCodepoint(text, i)
		local index = rl.GetGlyphIndex(font, codepoint)

		if codepoint == 0x3f then
			codepointByteCount = 1
		end
		i = i + codepointByteCount - 1

		local glyphWidth = 0
		if codepoint ~= 10 then
			if font.glyphs[index].advanceX == 0 then
				glyphWidth = font.recs[index].width * scaleFactor
			else
				glyphWidth = font.glyphs[index].advanceX * scaleFactor
			end

			if i < length then
				glyphWidth = glyphWidth + spacing
			end
		end

		if state == MEASURE_STATE then
			if (codepoint == 32) or (codepoint == 9) or (codepoint == 10) then
				endLine = i
			end

			if (textOffsetX + glyphWidth) > rec.width then
				endLine = (endLine < 1) and i or endLine
				if i == endLine then
					endLine = endLine - codepointByteCount
				end
				if (startLine + codepointByteCount) == endLine then
					endLine = i - codepointByteCount
				end

				state = DRAW_STATE
			elseif (i + 1) > length then
				endLine = i
				state = DRAW_STATE
			elseif codepoint == 10 then
				state = DRAW_STATE
			end

			if state == DRAW_STATE then
				textOffsetX = 0
				i = startLine
				glyphWidth = 0

				local tmp = lastk
				lastk = k - 1
				k = tmp
			end
		else
			if codepoint == 10 then
				if not wordWrap then
					textOffsetY = textOffsetY + (font.baseSize + font.baseSize / 2.0) * scaleFactor
					textOffsetX = 0
				end
			else
				if not wordWrap and ((textOffsetX + glyphWidth) > rec.width) then
					textOffsetY = textOffsetY + (font.baseSize + font.baseSize / 2.0) * scaleFactor
					textOffsetX = 0
				end

				if (textOffsetY + font.baseSize * scaleFactor) > rec.height then
					break
				end

				local isGlyphSelected = false
				if (selectStart >= 0) and (k >= selectStart) and (k < (selectStart + selectLength)) then
					rl.DrawRectangle(rec.x + textOffsetX - 1, rec.y + textOffsetY, glyphWidth, font.baseSize * scaleFactor, selectBackTint)
					isGlyphSelected = true
				end

				if (codepoint ~= 32) and (codepoint ~= 9) then
					rl.DrawTextCodepoint(font, codepoint, { x = rec.x + textOffsetX, y = rec.y + textOffsetY }, fontSize, isGlyphSelected and selectTint or tint)
				end
			end

			if wordWrap and (i == endLine) then
				textOffsetY = textOffsetY + (font.baseSize + font.baseSize / 2.0) * scaleFactor
				textOffsetX = 0
				startLine = endLine
				endLine = -1
				glyphWidth = 0
				selectStart = selectStart + lastk - k
				k = lastk

				state = MEASURE_STATE
			end
		end

		textOffsetX = textOffsetX + glyphWidth

		i = i + 1
		k = k + 1
	end
end

while not rl.WindowShouldClose() do
	if rl.IsKeyPressed(rl.KEY_SPACE) then
		RandomizeEmoji()
	end

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and (hovered ~= -1) and (hovered ~= selected) then
		selected = hovered
		selectedPos = hoveredPos
	end

	local mouse = rl.GetMousePosition()
	local position = { x = 28.8, y = 10.0 }
	hovered = -1

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		for i = 1, EMOJI_PER_WIDTH * EMOJI_PER_HEIGHT do
			local txt = emojiCodepoints[math.floor(emoji[i].index / 5) + 1]
			local emojiRect = { x = position.x, y = position.y, width = fontEmoji.baseSize, height = fontEmoji.baseSize }

			if not rl.CheckCollisionPointRec(mouse, emojiRect) then
				rl.DrawTextEx(fontEmoji, txt, position, fontEmoji.baseSize, 1.0, selected == i and emoji[i].color or rl.Fade(rl.LIGHTGRAY, 0.4))
			else
				rl.DrawTextEx(fontEmoji, txt, position, fontEmoji.baseSize, 1.0, emoji[i].color)
				hovered = i
				hoveredPos = position
			end

			if (i ~= 1) and (i % EMOJI_PER_WIDTH == 1) then
				position.y = position.y + fontEmoji.baseSize + 24.25
				position.x = 28.8
			else
				position.x = position.x + fontEmoji.baseSize + 28.8
			end
		end

		if selected ~= -1 then
			local message = messages[emoji[selected].message]
			local horizontalPadding = 20
			local verticalPadding = 30
			local f = fontDefault

			if message.language == "Chinese" or message.language == "Korean" or message.language == "Japanese" then
				f = fontAsian
			end

			local sz = rl.MeasureTextEx(f, message.text, f.baseSize, 1.0)
			if sz.x > 300 then
				sz.y = sz.y * sz.x / 300
				sz.x = 300
			elseif sz.x < 160 then
				sz.x = 160
			end

			local msgRect = {
				x = selectedPos.x - 38.8,
				y = selectedPos.y,
				width = 2 * horizontalPadding + sz.x,
				height = 2 * verticalPadding + sz.y
			}
			msgRect.y = msgRect.y - msgRect.height

			local a = { x = selectedPos.x, y = msgRect.y + msgRect.height }
			local b = { x = a.x + 8, y = a.y + 10 }
			local c = { x = a.x + 10, y = a.y }

			if msgRect.x < 10 then
				msgRect.x = msgRect.x + 28
			end
			if msgRect.y < 10 then
				msgRect.y = selectedPos.y + 84
				a.y = msgRect.y
				c.y = a.y
				b.y = a.y - 10

				local tmp = a
				a = b
				b = tmp
			end

			if msgRect.x + msgRect.width > rl.GetScreenWidth() then
				msgRect.x = msgRect.x - (msgRect.x + msgRect.width) - rl.GetScreenWidth() + 10
			end

			rl.DrawRectangleRec(msgRect, emoji[selected].color)
			rl.DrawTriangle(a, b, c, emoji[selected].color)

			local textRect = {
				x = msgRect.x + horizontalPadding / 2,
				y = msgRect.y + verticalPadding / 2,
				width = msgRect.width - horizontalPadding,
				height = msgRect.height
			}
			DrawTextBoxed(f, message.text, textRect, f.baseSize, 1.0, true, rl.WHITE)

			local size = #message.text
			local length = rl.GetCodepointCount(message.text)
			local info = string.format("%s %u characters %i bytes", message.language, length, size)
			sz = rl.MeasureTextEx(rl.GetFontDefault(), info, 10, 1.0)

			rl.DrawText(info, textRect.x + textRect.width - sz.x, msgRect.y + msgRect.height - sz.y - 2, 10, rl.RAYWHITE)
		end

		rl.DrawText("These emojis have something to tell you, click each to find out!", (rl.GetScreenWidth() - 650) / 2, rl.GetScreenHeight() - 40, 20, rl.GRAY)
		rl.DrawText("Each emoji is a unicode character from a font, not a texture... Press [SPACEBAR] to refresh", (rl.GetScreenWidth() - 484) / 2, rl.GetScreenHeight() - 16, 10, rl.GRAY)
	rl.EndDrawing()
end

rl.UnloadFont(fontDefault)
rl.UnloadFont(fontAsian)
rl.UnloadFont(fontEmoji)
rl.CloseWindow()