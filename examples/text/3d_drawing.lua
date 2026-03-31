--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/text/text_3d_drawing.c

]]

rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT + rl.FLAG_VSYNC_HINT)

rl.InitWindow(800, 450, "raylib [text] example - 3d drawing")

local spin = true
local multicolor = false

local camera = rl.new("Camera3D", {
	x = -10.0, y = 15.0, z = -10.0,
	target = { x = 0.0, y = 0.0, z = 0.0 },
	up = { x = 0.0, y = 1.0, z = 0.0 },
	fovy = 45.0,
	projection = rl.CAMERA_PERSPECTIVE
})

local camera_mode = rl.CAMERA_ORBITAL

local cubePosition = { x = 0.0, y = 1.0, z = 0.0 }
local cubeSize = { x = 2.0, y = 2.0, z = 2.0 }

local font = rl.GetFontDefault()
local fontSize = 0.8
local fontSpacing = 0.05
local lineSpacing = -0.1

local text = "Hello ~~World~~ in 3D!"
local tbox = { x = 0, y = 0, z = 0 }
local layers = 1
local quads = 0
local layerDistance = 0.01

local wcfg = {
	waveSpeed = { x = 3.0, y = 3.0, z = 0.5 },
	waveOffset = { x = 0.35, y = 0.35, z = 0.35 },
	waveRange = { x = 0.45, y = 0.45, z = 0.45 }
}

local time = 0.0

local light = rl.MAROON
local dark = rl.RED

local SHOW_LETTER_BOUNDRY = false
local SHOW_TEXT_BOUNDRY = false

local LETTER_BOUNDRY_SIZE = 0.25
local LETTER_BOUNDRY_COLOR = rl.VIOLET
local TEXT_MAX_LAYERS = 32

rl.DisableCursor()
rl.SetTargetFPS(60)

local function GenerateRandomColor(s, v)
	local Phi = 0.618033988749895
	local h = rl.GetRandomValue(0, 360)
	h = (h + h * Phi) % 360.0
	return rl.ColorFromHSV(h, s, v)
end

local function DrawTextCodepoint3D(font, codepoint, position, fontSize, backface, tint)
	local index = rl.GetGlyphIndex(font, codepoint)
	local scale = fontSize / font.baseSize

	position.x = position.x + (font.glyphs[index].offsetX - font.glyphPadding) * scale
	position.z = position.z + (font.glyphs[index].offsetY - font.glyphPadding) * scale

	local srcRec = {
		x = font.recs[index].x - font.glyphPadding,
		y = font.recs[index].y - font.glyphPadding,
		width = font.recs[index].width + 2.0 * font.glyphPadding,
		height = font.recs[index].height + 2.0 * font.glyphPadding
	}

	local width = (font.recs[index].width + 2.0 * font.glyphPadding) * scale
	local height = (font.recs[index].height + 2.0 * font.glyphPadding) * scale

	if font.texture.id > 0 then
		local x = 0.0
		local y = 0.0
		local z = 0.0

		local tx = srcRec.x / font.texture.width
		local ty = srcRec.y / font.texture.height
		local tw = (srcRec.x + srcRec.width) / font.texture.width
		local th = (srcRec.y + srcRec.height) / font.texture.height

		if SHOW_LETTER_BOUNDRY then
			rl.DrawCubeWiresV({
				x = position.x + width / 2,
				y = position.y,
				z = position.z + height / 2
			}, { x = width, y = LETTER_BOUNDRY_SIZE, z = height }, LETTER_BOUNDRY_COLOR)
		end

		rl.rlCheckRenderBatchLimit(4 + (backface and 4 or 0))
		rl.rlSetTexture(font.texture.id)

		rl.rlPushMatrix()
			rl.rlTranslatef(position.x, position.y, position.z)

			rl.rlBegin(rl.RL_QUADS)
				rl.rlColor4ub(tint.r, tint.g, tint.b, tint.a)

				rl.rlNormal3f(0.0, 1.0, 0.0)
				rl.rlTexCoord2f(tx, ty)
				rl.rlVertex3f(x, y, z)
				rl.rlTexCoord2f(tx, th)
				rl.rlVertex3f(x, y, z + height)
				rl.rlTexCoord2f(tw, th)
				rl.rlVertex3f(x + width, y, z + height)
				rl.rlTexCoord2f(tw, ty)
				rl.rlVertex3f(x + width, y, z)

				if backface then
					rl.rlNormal3f(0.0, -1.0, 0.0)
					rl.rlTexCoord2f(tx, ty)
					rl.rlVertex3f(x, y, z)
					rl.rlTexCoord2f(tw, ty)
					rl.rlVertex3f(x + width, y, z)
					rl.rlTexCoord2f(tw, th)
					rl.rlVertex3f(x + width, y, z + height)
					rl.rlTexCoord2f(tx, th)
					rl.rlVertex3f(x, y, z + height)
				end
			rl.rlEnd()
		rl.rlPopMatrix()

		rl.rlSetTexture(0)
	end
end

local function DrawText3D(font, text, position, fontSize, fontSpacing, lineSpacing, backface, tint)
	local length = #text

	local textOffsetY = 0.0
	local textOffsetX = 0.0

	local scale = fontSize / font.baseSize

	local i = 1
	while i <= length do
		local codepoint, codepointByteCount = rl.GetCodepoint(text, i)
		local index = rl.GetGlyphIndex(font, codepoint)

		if codepoint == 0x3f then
			codepointByteCount = 1
		end

		if codepoint == 10 then
			textOffsetY = textOffsetY + fontSize + lineSpacing
			textOffsetX = 0.0
		else
			if (codepoint ~= 32) and (codepoint ~= 9) then
				DrawTextCodepoint3D(font, codepoint, {
					x = position.x + textOffsetX,
					y = position.y,
					z = position.z + textOffsetY
				}, fontSize, backface, tint)
			end

			if font.glyphs[index].advanceX == 0 then
				textOffsetX = textOffsetX + font.recs[index].width * scale + fontSpacing
			else
				textOffsetX = textOffsetX + font.glyphs[index].advanceX * scale + fontSpacing
			end
		end

		i = i + codepointByteCount
	end
end

local function DrawTextWave3D(font, text, position, fontSize, fontSpacing, lineSpacing, backface, config, time, tint)
	local length = #text

	local textOffsetY = 0.0
	local textOffsetX = 0.0

	local scale = fontSize / font.baseSize

	local wave = false

	local i = 1
	local k = 0
	while i <= length do
		local codepoint, codepointByteCount = rl.GetCodepoint(text, i)
		local index = rl.GetGlyphIndex(font, codepoint)

		if codepoint == 0x3f then
			codepointByteCount = 1
		end

		if codepoint == 10 then
			textOffsetY = textOffsetY + fontSize + lineSpacing
			textOffsetX = 0.0
			k = 0
		elseif codepoint == 126 then
			local nextCodepoint, _ = rl.GetCodepoint(text, i + 1)
			if nextCodepoint == 126 then
				codepointByteCount = codepointByteCount + 1
				wave = not wave
			end
		else
			if (codepoint ~= 32) and (codepoint ~= 9) then
				local pos = { x = position.x, y = position.y, z = position.z }
				if wave then
					pos.x = pos.x + math.sin(time * config.waveSpeed.x - k * config.waveOffset.x) * config.waveRange.x
					pos.y = pos.y + math.sin(time * config.waveSpeed.y - k * config.waveOffset.y) * config.waveRange.y
					pos.z = pos.z + math.sin(time * config.waveSpeed.z - k * config.waveOffset.z) * config.waveRange.z
				end

				DrawTextCodepoint3D(font, codepoint, {
					x = pos.x + textOffsetX,
					y = pos.y,
					z = pos.z + textOffsetY
				}, fontSize, backface, tint)
			end

			if font.glyphs[index].advanceX == 0 then
				textOffsetX = textOffsetX + font.recs[index].width * scale + fontSpacing
			else
				textOffsetX = textOffsetX + font.glyphs[index].advanceX * scale + fontSpacing
			end
		end

		i = i + codepointByteCount
		k = k + 1
	end
end

local function MeasureTextWave3D(font, text, fontSize, fontSpacing, lineSpacing)
	local len = #text
	local tempLen = 0
	local lenCounter = 0

	local tempTextWidth = 0.0

	local scale = fontSize / font.baseSize
	local textHeight = scale
	local textWidth = 0.0

	local i = 1
	while i <= len do
		local next = 0
		local letter = rl.GetCodepoint(text, i)
		local index = rl.GetGlyphIndex(font, letter)

		if letter == 0x3f then
			next = 1
		end
		i = i + next - 1

		if letter ~= 10 then
			if letter == 126 then
				local nextCp, _ = rl.GetCodepoint(text, i + 1)
				if nextCp == 126 then
					i = i + 1
				end
			else
				lenCounter = lenCounter + 1
				if font.glyphs[index].advanceX ~= 0 then
					textWidth = textWidth + font.glyphs[index].advanceX * scale
				else
					textWidth = textWidth + (font.recs[index].width + font.glyphs[index].offsetX) * scale
				end
			end
		else
			if tempTextWidth < textWidth then
				tempTextWidth = textWidth
			end
			lenCounter = 0
			textWidth = 0.0
			textHeight = textHeight + fontSize + lineSpacing
		end

		if tempLen < lenCounter then
			tempLen = lenCounter
		end

		i = i + 1
	end

	if tempTextWidth < textWidth then
		tempTextWidth = textWidth
	end

	local vec = { x = 0, y = 0, z = 0 }
	vec.x = tempTextWidth + (tempLen - 1) * fontSpacing
	vec.y = 0.25
	vec.z = textHeight

	return vec
end

while not rl.WindowShouldClose() do
	rl.UpdateCamera(camera, camera_mode)

	if rl.IsFileDropped() then
		local droppedFiles = rl.LoadDroppedFiles()
		local filepath = droppedFiles.paths[0]
		if rl.IsFileExtension(filepath, ".ttf") then
			rl.UnloadFont(font)
			font = rl.LoadFontEx(filepath, fontSize, nil, 0)
		elseif rl.IsFileExtension(filepath, ".fnt") then
			rl.UnloadFont(font)
			font = rl.LoadFont(filepath)
			fontSize = font.baseSize
		end
		rl.UnloadDroppedFiles(droppedFiles)
	end

	if rl.IsKeyPressed(rl.KEY_F1) then
		SHOW_LETTER_BOUNDRY = not SHOW_LETTER_BOUNDRY
	end
	if rl.IsKeyPressed(rl.KEY_F2) then
		SHOW_TEXT_BOUNDRY = not SHOW_TEXT_BOUNDRY
	end
	if rl.IsKeyPressed(rl.KEY_F3) then
		spin = not spin
		camera = rl.new("Camera3D", {
			x = spin and -10.0 or 10.0,
			y = 15.0,
			z = spin and -10.0 or -10.0,
			target = { x = 0.0, y = 0.0, z = 0.0 },
			up = { x = 0.0, y = 1.0, z = 0.0 },
			fovy = 45.0,
			projection = rl.CAMERA_PERSPECTIVE
		})
		camera_mode = spin and rl.CAMERA_ORBITAL or rl.CAMERA_FREE
	end

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then
		local ray = rl.GetScreenToWorldRay(rl.GetMousePosition(), camera)
		local collision = rl.GetRayCollisionBox(ray, {
			min = {
				x = cubePosition.x - cubeSize.x / 2,
				y = cubePosition.y - cubeSize.y / 2,
				z = cubePosition.z - cubeSize.z / 2
			},
			max = {
				x = cubePosition.x + cubeSize.x / 2,
				y = cubePosition.y + cubeSize.y / 2,
				z = cubePosition.z + cubeSize.z / 2
			}
		})
		if collision.hit then
			light = GenerateRandomColor(0.5, 0.78)
			dark = GenerateRandomColor(0.4, 0.58)
		end
	end

	if rl.IsKeyPressed(rl.KEY_HOME) then
		if layers > 1 then layers = layers - 1 end
	elseif rl.IsKeyPressed(rl.KEY_END) then
		if layers < TEXT_MAX_LAYERS then layers = layers + 1 end
	end

	if rl.IsKeyPressed(rl.KEY_LEFT) then
		fontSize = fontSize - 0.5
	elseif rl.IsKeyPressed(rl.KEY_RIGHT) then
		fontSize = fontSize + 0.5
	elseif rl.IsKeyPressed(rl.KEY_UP) then
		fontSpacing = fontSpacing - 0.1
	elseif rl.IsKeyPressed(rl.KEY_DOWN) then
		fontSpacing = fontSpacing + 0.1
	elseif rl.IsKeyPressed(rl.KEY_PAGE_UP) then
		lineSpacing = lineSpacing - 0.1
	elseif rl.IsKeyPressed(rl.KEY_PAGE_DOWN) then
		lineSpacing = lineSpacing + 0.1
	elseif rl.IsKeyDown(rl.KEY_INSERT) then
		layerDistance = layerDistance - 0.001
	elseif rl.IsKeyDown(rl.KEY_DELETE) then
		layerDistance = layerDistance + 0.001
	elseif rl.IsKeyPressed(rl.KEY_TAB) then
		multicolor = not multicolor
	end

	local ch = rl.GetCharPressed()
	if rl.IsKeyPressed(rl.KEY_BACKSPACE) then
		local len = #text
		if len > 0 then
			text = text:sub(1, len - 1)
		end
	elseif rl.IsKeyPressed(rl.KEY_ENTER) then
		local len = #text
		if len < 63 then
			text = text .. "\n"
		end
	else
		local len = #text
		if len < 63 and ch > 0 then
			text = text .. string.char(ch)
		end
	end

	tbox = MeasureTextWave3D(font, text, fontSize, fontSpacing, lineSpacing)

	quads = 0
	time = time + rl.GetFrameTime()

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.BeginMode3D(camera)
			rl.DrawCubeV(cubePosition, cubeSize, dark)
			rl.DrawCubeWires(cubePosition, 2.1, 2.1, 2.1, light)

			rl.DrawGrid(10, 2.0)

			rl.rlPushMatrix()
				rl.rlRotatef(90.0, 1.0, 0.0, 0.0)
				rl.rlRotatef(90.0, 0.0, 0.0, -1.0)

				for i = 0, layers - 1 do
					local clr = light
					if multicolor then
						clr = GenerateRandomColor(0.5, 0.8)
						clr.a = rl.GetRandomValue(0, 255)
					end
					DrawTextWave3D(font, text, {
						x = -tbox.x / 2.0,
						y = layerDistance * i,
						z = -4.5
					}, fontSize, fontSpacing, lineSpacing, true, wcfg, time, clr)
				end

				if SHOW_TEXT_BOUNDRY then
					rl.DrawCubeWiresV({ x = 0.0, y = 0.0, z = -4.5 + tbox.z / 2 }, tbox, dark)
				end
			rl.rlPopMatrix()

			local slb = SHOW_LETTER_BOUNDRY
			SHOW_LETTER_BOUNDRY = false

			rl.rlPushMatrix()
				rl.rlRotatef(180.0, 0.0, 1.0, 0.0)

				local opt = string.format("< SIZE: %2.1f >", fontSize)
				quads = quads + #opt
				local m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 0.8, 0.1)
				local pos = { x = -m.x / 2.0, y = 0.01, z = 2.0 }
				rl.DrawText3D(rl.GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, rl.BLUE)
				pos.z = pos.z + 0.5 + m.y

				opt = string.format("< SPACING: %2.1f >", fontSpacing)
				quads = quads + #opt
				m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 0.8, 0.1)
				pos.x = -m.x / 2.0
				rl.DrawText3D(rl.GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, rl.BLUE)
				pos.z = pos.z + 0.5 + m.y

				opt = string.format("< LINE: %2.1f >", lineSpacing)
				quads = quads + #opt
				m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 0.8, 0.1)
				pos.x = -m.x / 2.0
				rl.DrawText3D(rl.GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, rl.BLUE)
				pos.z = pos.z + 0.5 + m.y

				opt = string.format("< LBOX: %3s >", slb and "ON" or "OFF")
				quads = quads + #opt
				m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 0.8, 0.1)
				pos.x = -m.x / 2.0
				rl.DrawText3D(rl.GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, rl.RED)
				pos.z = pos.z + 0.5 + m.y

				opt = string.format("< TBOX: %3s >", SHOW_TEXT_BOUNDRY and "ON" or "OFF")
				quads = quads + #opt
				m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 0.8, 0.1)
				pos.x = -m.x / 2.0
				rl.DrawText3D(rl.GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, rl.RED)
				pos.z = pos.z + 0.5 + m.y

				opt = string.format("< LAYER DISTANCE: %.3f >", layerDistance)
				quads = quads + #opt
				m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 0.8, 0.1)
				pos.x = -m.x / 2.0
				rl.DrawText3D(rl.GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, rl.DARKPURPLE)
			rl.rlPopMatrix()

			opt = "All the text displayed here is in 3D"
			quads = quads + 36
			m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 1.0, 0.05)
			pos = { x = -m.x / 2.0, y = 0.01, z = 2.0 }
			rl.DrawText3D(rl.GetFontDefault(), opt, pos, 1.0, 0.05, 0.0, false, rl.DARKBLUE)
			pos.z = pos.z + 1.5 + m.y

			opt = "press [Left]/[Right] to change the font size"
			quads = quads + 44
			m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 0.6, 0.05)
			pos.x = -m.x / 2.0
			rl.DrawText3D(rl.GetFontDefault(), opt, pos, 0.6, 0.05, 0.0, false, rl.DARKBLUE)
			pos.z = pos.z + 0.5 + m.y

			opt = "press [Up]/[Down] to change the font spacing"
			quads = quads + 44
			m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 0.6, 0.05)
			pos.x = -m.x / 2.0
			rl.DrawText3D(rl.GetFontDefault(), opt, pos, 0.6, 0.05, 0.0, false, rl.DARKBLUE)
			pos.z = pos.z + 0.5 + m.y

			opt = "press [PgUp]/[PgDown] to change the line spacing"
			quads = quads + 48
			m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 0.6, 0.05)
			pos.x = -m.x / 2.0
			rl.DrawText3D(rl.GetFontDefault(), opt, pos, 0.6, 0.05, 0.0, false, rl.DARKBLUE)
			pos.z = pos.z + 0.5 + m.y

			opt = "press [F1] to toggle the letter boundry"
			quads = quads + 39
			m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 0.6, 0.05)
			pos.x = -m.x / 2.0
			rl.DrawText3D(rl.GetFontDefault(), opt, pos, 0.6, 0.05, 0.0, false, rl.DARKBLUE)
			pos.z = pos.z + 0.5 + m.y

			opt = "press [F2] to toggle the text boundry"
			quads = quads + 37
			m = rl.MeasureTextEx(rl.GetFontDefault(), opt, 0.6, 0.05)
			pos.x = -m.x / 2.0
			rl.DrawText3D(rl.GetFontDefault(), opt, pos, 0.6, 0.05, 0.0, false, rl.DARKBLUE)

			SHOW_LETTER_BOUNDRY = slb
		rl.EndMode3D()

		rl.DrawText("Drag & drop a font file to change the font!\nType something, see what happens!\n\nPress [F3] to toggle the camera", 10, 35, 10, rl.BLACK)

		quads = quads + #text * 2 * layers
		local tmp = string.format("%2i layer(s) | %s camera | %4i quads (%4i verts)", layers, spin and "ORBITAL" or "FREE", quads, quads * 4)
		local width = rl.MeasureText(tmp, 10)
		rl.DrawText(tmp, rl.GetScreenWidth() - 20 - width, 10, 10, rl.DARKGREEN)

		tmp = "[Home]/[End] to add/remove 3D text layers"
		width = rl.MeasureText(tmp, 10)
		rl.DrawText(tmp, rl.GetScreenWidth() - 20 - width, 25, 10, rl.DARKGRAY)

		tmp = "[Insert]/[Delete] to increase/decrease distance between layers"
		width = rl.MeasureText(tmp, 10)
		rl.DrawText(tmp, rl.GetScreenWidth() - 20 - width, 40, 10, rl.DARKGRAY)

		tmp = "click the [CUBE] for a random color"
		width = rl.MeasureText(tmp, 10)
		rl.DrawText(tmp, rl.GetScreenWidth() - 20 - width, 55, 10, rl.DARKGRAY)

		tmp = "[Tab] to toggle multicolor mode"
		width = rl.MeasureText(tmp, 10)
		rl.DrawText(tmp, rl.GetScreenWidth() - 20 - width, 70, 10, rl.DARKGRAY)

		rl.DrawFPS(10, 10)
	rl.EndDrawing()
end

rl.UnloadFont(font)
rl.CloseWindow()