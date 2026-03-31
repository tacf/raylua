-- raylib [core] example - clipboard text

local MAX_TEXT_SAMPLES = 5

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - clipboard text")

-- Define some sample texts
local sampleTexts = {
	"Hello from raylib!",
	"The quick brown fox jumps over the lazy dog",
	"Clipboard operations are useful!",
	"raylib is a simple and easy-to-use library",
	"Copy and paste me!"
}

local clipboardText = ""
local inputBuffer = "Hello from raylib!"

-- UI required variables
local textBoxEditMode = false

local btnCutPressed = false
local btnCopyPressed = false
local btnPastePressed = false
local btnClearPressed = false
local btnRandomPressed = false

-- Set UI style
rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SIZE, 20)
rl.GuiSetIconScale(2)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- Handle button interactions
	if btnCutPressed then
		rl.SetClipboardText(inputBuffer)
		clipboardText = rl.GetClipboardText()
		inputBuffer = ""
	end

	if btnCopyPressed then
		rl.SetClipboardText(inputBuffer)
		clipboardText = rl.GetClipboardText()
	end

	if btnPastePressed then
		clipboardText = rl.GetClipboardText()
		if clipboardText ~= nil then
			inputBuffer = clipboardText
		end
	end

	if btnClearPressed then
		inputBuffer = ""
	end

	if btnRandomPressed then
		inputBuffer = sampleTexts[rl.GetRandomValue(0, MAX_TEXT_SAMPLES - 1) + 1]
	end

	-- Quick cut/copy/paste with keyboard shortcuts
	if rl.IsKeyDown(rl.KEY_LEFT_CONTROL) or rl.IsKeyDown(rl.KEY_RIGHT_CONTROL) then
		if rl.IsKeyPressed(rl.KEY_X) then
			rl.SetClipboardText(inputBuffer)
			inputBuffer = ""
		end

		if rl.IsKeyPressed(rl.KEY_C) then
			rl.SetClipboardText(inputBuffer)
		end

		if rl.IsKeyPressed(rl.KEY_V) then
			clipboardText = rl.GetClipboardText()
			if clipboardText ~= nil then
				inputBuffer = clipboardText
			end
		end
	end

	-- Draw
	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		-- Draw instructions
		rl.GuiLabel(rl.new("Rectangle", 50, 20, 700, 36), "Use the BUTTONS or KEY SHORTCUTS:")
		rl.DrawText("[CTRL+X] - CUT | [CTRL+C] COPY | [CTRL+V] | PASTE", 50, 60, 20, rl.MAROON)

		-- Draw text box
		local result = rl.GuiTextBox(rl.new("Rectangle", 50, 120, 652, 40), inputBuffer, 256, textBoxEditMode)
		if result then textBoxEditMode = not textBoxEditMode end

		-- Random text button
		btnRandomPressed = rl.GuiButton(rl.new("Rectangle", 50 + 652 + 8, 120, 40, 40), "#77#")

		-- Draw buttons
		btnCutPressed = rl.GuiButton(rl.new("Rectangle", 50, 180, 158, 40), "#17#CUT")
		btnCopyPressed = rl.GuiButton(rl.new("Rectangle", 50 + 165, 180, 158, 40), "#16#COPY")
		btnPastePressed = rl.GuiButton(rl.new("Rectangle", 50 + 165 * 2, 180, 158, 40), "#18#PASTE")
		btnClearPressed = rl.GuiButton(rl.new("Rectangle", 50 + 165 * 3, 180, 158, 40), "#143#CLEAR")

		-- Draw clipboard status
		rl.GuiSetState(rl.STATE_DISABLED)
		rl.GuiLabel(rl.new("Rectangle", 50, 260, 700, 40), "Clipboard current text data:")
		rl.GuiSetStyle(rl.TEXTBOX, rl.TEXT_READONLY, 1)
		rl.GuiTextBox(rl.new("Rectangle", 50, 300, 700, 40), clipboardText or "", 256, false)
		rl.GuiSetStyle(rl.TEXTBOX, rl.TEXT_READONLY, 0)
		rl.GuiLabel(rl.new("Rectangle", 50, 360, 700, 40), "Try copying text from other applications and pasting here!")
		rl.GuiSetState(rl.STATE_NORMAL)
	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
