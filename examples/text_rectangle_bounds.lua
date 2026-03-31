rl.InitWindow(800, 450, "raylib [text] example - rectangle bounds")

local text = "Text cannot escape\tthis container\t...word wrap also works when active so here's a long text for testing.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nec ullamcorper sit amet risus nullam eget felis eget."

local resizing = false
local wordWrap = true

local container = {
	x = 25.0,
	y = 25.0,
	width = rl.GetScreenWidth() - 50.0,
	height = rl.GetScreenHeight() - 250.0
}
local resizer = {
	x = container.x + container.width - 17,
	y = container.y + container.height - 17,
	width = 14,
	height = 14
}

local minWidth = 60
local minHeight = 60
local maxWidth = rl.GetScreenWidth() - 50.0
local maxHeight = rl.GetScreenHeight() - 160.0

local lastMouse = { x = 0.0, y = 0.0 }
local borderColor = rl.MAROON
local font = rl.GetFontDefault()

rl.SetTargetFPS(60)

local function DrawTextBoxed(font, text, rec, fontSize, spacing, wordWrap, tint)
	DrawTextBoxedSelectable(font, text, rec, fontSize, spacing, wordWrap, tint, 0, 0, rl.WHITE, rl.WHITE)
end

local function DrawTextBoxedSelectable(font, text, rec, fontSize, spacing, wordWrap, tint, selectStart, selectLength, selectTint, selectBackTint)
	local length = #text

	local textOffsetY = 0
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

		if (textOffsetX ~= 0) or (codepoint ~= 32) then
			textOffsetX = textOffsetX + glyphWidth
		end

		i = i + 1
		k = k + 1
	end
end

while not rl.WindowShouldClose() do
	if rl.IsKeyPressed(rl.KEY_SPACE) then
		wordWrap = not wordWrap
	end

	local mouse = rl.GetMousePosition()

	if rl.CheckCollisionPointRec(mouse, container) then
		borderColor = rl.Fade(rl.MAROON, 0.4)
	elseif not resizing then
		borderColor = rl.MAROON
	end

	if resizing then
		if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then
			resizing = false
		end

		local width = container.width + (mouse.x - lastMouse.x)
		if width > minWidth then
			if width < maxWidth then
				container.width = width
			else
				container.width = maxWidth
			end
		else
			container.width = minWidth
		end

		local height = container.height + (mouse.y - lastMouse.y)
		if height > minHeight then
			if height < maxHeight then
				container.height = height
			else
				container.height = maxHeight
			end
		else
			container.height = minHeight
		end
	else
		if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and rl.CheckCollisionPointRec(mouse, resizer) then
			resizing = true
		end
	end

	resizer.x = container.x + container.width - 17
	resizer.y = container.y + container.height - 17

	lastMouse = mouse

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawRectangleLinesEx(container, 3, borderColor)

		DrawTextBoxed(font, text, { x = container.x + 4, y = container.y + 4, width = container.width - 4, height = container.height - 4 }, 20.0, 2.0, wordWrap, rl.GRAY)

		rl.DrawRectangleRec(resizer, borderColor)

		rl.DrawRectangle(0, rl.GetScreenHeight() - 54, rl.GetScreenWidth(), 54, rl.GRAY)
		rl.DrawRectangleRec({ x = 382.0, y = rl.GetScreenHeight() - 34.0, width = 12.0, height = 12.0 }, rl.MAROON)

		rl.DrawText("Word Wrap: ", 313, rl.GetScreenHeight() - 115, 20, rl.BLACK)
		if wordWrap then
			rl.DrawText("ON", 447, rl.GetScreenHeight() - 115, 20, rl.RED)
		else
			rl.DrawText("OFF", 447, rl.GetScreenHeight() - 115, 20, rl.BLACK)
		end

		rl.DrawText("Press [SPACE] to toggle word wrap", 218, rl.GetScreenHeight() - 86, 20, rl.GRAY)

		rl.DrawText("Click hold & drag the    to resize the container", 155, rl.GetScreenHeight() - 38, 20, rl.RAYWHITE)
	rl.EndDrawing()
end

rl.CloseWindow()