--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/text/text_strings_management.c

]]

rl.InitWindow(800, 450, "raylib [text] example - strings management")

local MAX_TEXT_LENGTH = 100
local MAX_TEXT_PARTICLES = 100
local FONT_SIZE = 30

local textParticles = {}
local particleCount = 0
local grabbedTextParticle = nil
local pressOffset = { x = 0, y = 0 }

local function PrepareFirstTextParticle(text, tps, particleCount)
	tps[1] = CreateTextParticle(text, rl.GetScreenWidth() / 2.0, rl.GetScreenHeight() / 2.0, rl.RAYWHITE)
	particleCount[1] = 1
end

local function CreateTextParticle(text, x, y, color)
	local tp = {
		text = text,
		rect = { x = x, y = y, width = 30, height = 30 },
		vel = { x = rl.GetRandomValue(-200, 200), y = rl.GetRandomValue(-200, 200) },
		ppos = { x = 0, y = 0 },
		padding = 5.0,
		borderWidth = 5.0,
		friction = 0.99,
		elasticity = 0.9,
		color = color,
		grabbed = false
	}

	tp.rect.width = rl.MeasureText(text, FONT_SIZE) + tp.padding * 2
	tp.rect.height = FONT_SIZE + tp.padding * 2
	return tp
end

local function SliceTextParticle(tp, particlePos, sliceLength, tps, particleCount)
	local length = #tp.text

	if (length > 1) and ((particleCount[1] + length) < MAX_TEXT_PARTICLES) then
		for i = 1, length, sliceLength do
			local txt = nil
			if sliceLength == 1 then
				txt = tp.text:sub(i, i)
			else
				local endPos = i + sliceLength - 1
				if endPos > length then
					endPos = length
				end
				txt = tp.text:sub(i, endPos)
			end

			local newColor = {
				r = rl.GetRandomValue(0, 255),
				g = rl.GetRandomValue(0, 255),
				b = rl.GetRandomValue(0, 255),
				a = 255
			}
			particleCount[1] = particleCount[1] + 1
			tps[particleCount[1]] = CreateTextParticle(
				txt,
				tp.rect.x + (i - 1) * tp.rect.width / length,
				tp.rect.y,
				newColor
			)
		end
		RealocateTextParticles(tps, particlePos, particleCount)
	end
end

local function SliceTextParticleByChar(tp, charToSlice, tps, particleCount)
	local tokens = {}
	local tokenCount = 0

	for w in tp.text:gmatch("[^" .. charToSlice .. "]+") do
		tokenCount = tokenCount + 1
		tokens[tokenCount] = w
	end

	if tokenCount > 1 then
		local textLength = #tp.text
		for i = 1, textLength do
			if tp.text:sub(i, i) == charToSlice then
				local newColor = {
					r = rl.GetRandomValue(0, 255),
					g = rl.GetRandomValue(0, 255),
					b = rl.GetRandomValue(0, 255),
					a = 255
				}
				particleCount[1] = particleCount[1] + 1
				tps[particleCount[1]] = CreateTextParticle(
					charToSlice,
					tp.rect.x,
					tp.rect.y,
					newColor
				)
			end
		end
		for i = 1, tokenCount do
			local tokenLength = #tokens[i]
			local newColor = {
				r = rl.GetRandomValue(0, 255),
				g = rl.GetRandomValue(0, 255),
				b = rl.GetRandomValue(0, 255),
				a = 255
			}
			particleCount[1] = particleCount[1] + 1
			tps[particleCount[1]] = CreateTextParticle(
				tokens[i],
				tp.rect.x + (i - 1) * tp.rect.width / tokenLength,
				tp.rect.y,
				newColor
			)
		end
		if tokenCount > 0 then
			RealocateTextParticles(tps, 1, particleCount)
		end
	end
end

local function ShatterTextParticle(tp, particlePos, tps, particleCount)
	SliceTextParticle(tp, particlePos, 1, tps, particleCount)
end

local function GlueTextParticles(grabbed, target, tps, particleCount)
	local p1 = -1
	local p2 = -1

	for i = 1, particleCount[1] do
		if tps[i] == grabbed then
			p1 = i
		end
		if tps[i] == target then
			p2 = i
		end
	end

	if (p1 ~= -1) and (p2 ~= -1) then
		local tp = CreateTextParticle(
			grabbed.text .. target.text,
			grabbed.rect.x,
			grabbed.rect.y,
			rl.RAYWHITE
		)
		tp.grabbed = true
		particleCount[1] = particleCount[1] + 1
		tps[particleCount[1]] = tp
		grabbed.grabbed = false
		if p1 < p2 then
			RealocateTextParticles(tps, p2, particleCount)
			RealocateTextParticles(tps, p1, particleCount)
		else
			RealocateTextParticles(tps, p1, particleCount)
			RealocateTextParticles(tps, p2, particleCount)
		end
	end
end

local function RealocateTextParticles(tps, particlePos, particleCount)
	for i = particlePos + 1, particleCount[1] do
		tps[i - 1] = tps[i]
	end
	particleCount[1] = particleCount[1] - 1
end

PrepareFirstTextParticle("raylib => fun videogames programming!", textParticles, particleCount)

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	local delta = rl.GetFrameTime()
	local mousePos = rl.GetMousePosition()

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then
		for i = particleCount[1], 1, -1 do
			local tp = textParticles[i]
			pressOffset.x = mousePos.x - tp.rect.x
			pressOffset.y = mousePos.y - tp.rect.y
			if rl.CheckCollisionPointRec(mousePos, tp.rect) then
				tp.grabbed = true
				grabbedTextParticle = tp
				break
			end
		end
	end

	if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then
		if grabbedTextParticle ~= nil then
			grabbedTextParticle.grabbed = false
			grabbedTextParticle = nil
		end
	end

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT) then
		for i = particleCount[1], 1, -1 do
			local tp = textParticles[i]
			if rl.CheckCollisionPointRec(mousePos, tp.rect) then
				if rl.IsKeyDown(rl.KEY_LEFT_SHIFT) then
					ShatterTextParticle(tp, i, textParticles, particleCount)
				else
					SliceTextParticle(tp, i, math.floor(#tp.text / 2), textParticles, particleCount)
				end
				break
			end
		end
	end

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_MIDDLE) then
		for i = 1, particleCount[1] do
			if not textParticles[i].grabbed then
				textParticles[i].vel = {
					x = rl.GetRandomValue(-2000, 2000),
					y = rl.GetRandomValue(-2000, 2000)
				}
			end
		end
	end

	if rl.IsKeyPressed(rl.KEY_ONE) then
		PrepareFirstTextParticle("raylib => fun videogames programming!", textParticles, particleCount)
	end
	if rl.IsKeyPressed(rl.KEY_TWO) then
		PrepareFirstTextParticle(rl.TextToUpper("raylib => fun videogames programming!"), textParticles, particleCount)
	end
	if rl.IsKeyPressed(rl.KEY_THREE) then
		PrepareFirstTextParticle(rl.TextToLower("raylib => fun videogames programming!"), textParticles, particleCount)
	end
	if rl.IsKeyPressed(rl.KEY_FOUR) then
		PrepareFirstTextParticle(rl.TextToPascal("raylib_fun_videogames_programming"), textParticles, particleCount)
	end
	if rl.IsKeyPressed(rl.KEY_FIVE) then
		PrepareFirstTextParticle(rl.TextToSnake("RaylibFunVideogamesProgramming"), textParticles, particleCount)
	end
	if rl.IsKeyPressed(rl.KEY_SIX) then
		PrepareFirstTextParticle(rl.TextToCamel("raylib_fun_videogames_programming"), textParticles, particleCount)
	end

	local charPressed = rl.GetCharPressed()
	if (charPressed >= string.byte("A")) and (charPressed <= string.byte("z")) and (particleCount[1] == 1) then
		SliceTextParticleByChar(textParticles[1], string.char(charPressed), textParticles, particleCount)
	end

	for i = 1, particleCount[1] do
		local tp = textParticles[i]

		if not tp.grabbed then
			tp.rect.x = tp.rect.x + tp.vel.x * delta
			tp.rect.y = tp.rect.y + tp.vel.y * delta

			if (tp.rect.x + tp.rect.width) >= rl.GetScreenWidth() then
				tp.rect.x = rl.GetScreenWidth() - tp.rect.width
				tp.vel.x = -tp.vel.x * tp.elasticity
			elseif tp.rect.x <= 0 then
				tp.rect.x = 0.0
				tp.vel.x = -tp.vel.x * tp.elasticity
			end

			if (tp.rect.y + tp.rect.height) >= rl.GetScreenHeight() then
				tp.rect.y = rl.GetScreenHeight() - tp.rect.height
				tp.vel.y = -tp.vel.y * tp.elasticity
			elseif tp.rect.y <= 0 then
				tp.rect.y = 0.0
				tp.vel.y = -tp.vel.y * tp.elasticity
			end

			tp.vel.x = tp.vel.x * tp.friction
			tp.vel.y = tp.vel.y * tp.friction
		else
			tp.rect.x = mousePos.x - pressOffset.x
			tp.rect.y = mousePos.y - pressOffset.y

			tp.vel.x = (tp.rect.x - tp.ppos.x) / delta
			tp.vel.y = (tp.rect.y - tp.ppos.y) / delta
			tp.ppos.x = tp.rect.x
			tp.ppos.y = tp.rect.y

			if rl.IsKeyDown(rl.KEY_LEFT_CONTROL) then
				for j = 1, particleCount[1] do
					if textParticles[j] ~= grabbedTextParticle and grabbedTextParticle.grabbed then
						if rl.CheckCollisionRecs(grabbedTextParticle.rect, textParticles[j].rect) then
							GlueTextParticles(grabbedTextParticle, textParticles[j], textParticles, particleCount)
							grabbedTextParticle = textParticles[particleCount[1]]
						end
					end
				end
			end
		end
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		for i = 1, particleCount[1] do
			local tp = textParticles[i]
			rl.DrawRectangle(tp.rect.x - tp.borderWidth, tp.rect.y - tp.borderWidth, tp.rect.width + tp.borderWidth * 2, tp.rect.height + tp.borderWidth * 2, rl.BLACK)
			rl.DrawRectangleRec(tp.rect, tp.color)
			rl.DrawText(tp.text, tp.rect.x + tp.padding, tp.rect.y + tp.padding, FONT_SIZE, rl.BLACK)
		end

		rl.DrawText("grab a text particle by pressing with the mouse and throw it by releasing", 10, 10, 10, rl.DARKGRAY)
		rl.DrawText("slice a text particle by pressing it with the mouse right button", 10, 30, 10, rl.DARKGRAY)
		rl.DrawText("shatter a text particle keeping left shift pressed and pressing it with the mouse right button", 10, 50, 10, rl.DARKGRAY)
		rl.DrawText("glue text particles by grabbing than and keeping left control pressed", 10, 70, 10, rl.DARKGRAY)
		rl.DrawText("1 to 6 to reset", 10, 90, 10, rl.DARKGRAY)
		rl.DrawText("when you have only one text particle, you can slice it by pressing a char", 10, 110, 10, rl.DARKGRAY)
		rl.DrawText(string.format("TEXT PARTICLE COUNT: %d", particleCount[1]), 10, rl.GetScreenHeight() - 30, 20, rl.BLACK)
	rl.EndDrawing()
end

rl.CloseWindow()