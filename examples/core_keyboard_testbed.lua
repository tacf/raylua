-- raylib [core] example - keyboard testbed

local KEY_REC_SPACING = 4

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - keyboard testbed")
rl.SetExitKey(rl.KEY_NULL)

-- Key text mapping (US keyboard)
local keyText = {
	[rl.KEY_APOSTROPHE]    = "'",
	[rl.KEY_COMMA]         = ",",
	[rl.KEY_MINUS]         = "-",
	[rl.KEY_PERIOD]        = ".",
	[rl.KEY_SLASH]         = "/",
	[rl.KEY_ZERO]          = "0",
	[rl.KEY_ONE]           = "1",
	[rl.KEY_TWO]           = "2",
	[rl.KEY_THREE]         = "3",
	[rl.KEY_FOUR]          = "4",
	[rl.KEY_FIVE]          = "5",
	[rl.KEY_SIX]           = "6",
	[rl.KEY_SEVEN]         = "7",
	[rl.KEY_EIGHT]         = "8",
	[rl.KEY_NINE]          = "9",
	[rl.KEY_SEMICOLON]     = ";",
	[rl.KEY_EQUAL]         = "=",
	[rl.KEY_A]             = "A",
	[rl.KEY_B]             = "B",
	[rl.KEY_C]             = "C",
	[rl.KEY_D]             = "D",
	[rl.KEY_E]             = "E",
	[rl.KEY_F]             = "F",
	[rl.KEY_G]             = "G",
	[rl.KEY_H]             = "H",
	[rl.KEY_I]             = "I",
	[rl.KEY_J]             = "J",
	[rl.KEY_K]             = "K",
	[rl.KEY_L]             = "L",
	[rl.KEY_M]             = "M",
	[rl.KEY_N]             = "N",
	[rl.KEY_O]             = "O",
	[rl.KEY_P]             = "P",
	[rl.KEY_Q]             = "Q",
	[rl.KEY_R]             = "R",
	[rl.KEY_S]             = "S",
	[rl.KEY_T]             = "T",
	[rl.KEY_U]             = "U",
	[rl.KEY_V]             = "V",
	[rl.KEY_W]             = "W",
	[rl.KEY_X]             = "X",
	[rl.KEY_Y]             = "Y",
	[rl.KEY_Z]             = "Z",
	[rl.KEY_LEFT_BRACKET]  = "[",
	[rl.KEY_BACKSLASH]     = "\\",
	[rl.KEY_RIGHT_BRACKET] = "]",
	[rl.KEY_GRAVE]         = "`",
	[rl.KEY_SPACE]         = "SPACE",
	[rl.KEY_ESCAPE]        = "ESC",
	[rl.KEY_ENTER]         = "ENTER",
	[rl.KEY_TAB]           = "TAB",
	[rl.KEY_BACKSPACE]     = "BACK",
	[rl.KEY_INSERT]        = "INS",
	[rl.KEY_DELETE]        = "DEL",
	[rl.KEY_RIGHT]         = "RIGHT",
	[rl.KEY_LEFT]          = "LEFT",
	[rl.KEY_DOWN]          = "DOWN",
	[rl.KEY_UP]            = "UP",
	[rl.KEY_PAGE_UP]       = "PGUP",
	[rl.KEY_PAGE_DOWN]     = "PGDOWN",
	[rl.KEY_HOME]          = "HOME",
	[rl.KEY_END]           = "END",
	[rl.KEY_CAPS_LOCK]     = "CAPS",
	[rl.KEY_SCROLL_LOCK]   = "LOCK",
	[rl.KEY_NUM_LOCK]      = "NUMLOCK",
	[rl.KEY_PRINT_SCREEN]  = "PRINTSCR",
	[rl.KEY_PAUSE]         = "PAUSE",
	[rl.KEY_F1]            = "F1",
	[rl.KEY_F2]            = "F2",
	[rl.KEY_F3]            = "F3",
	[rl.KEY_F4]            = "F4",
	[rl.KEY_F5]            = "F5",
	[rl.KEY_F6]            = "F6",
	[rl.KEY_F7]            = "F7",
	[rl.KEY_F8]            = "F8",
	[rl.KEY_F9]            = "F9",
	[rl.KEY_F10]           = "F10",
	[rl.KEY_F11]           = "F11",
	[rl.KEY_F12]           = "F12",
	[rl.KEY_LEFT_SHIFT]    = "LSHIFT",
	[rl.KEY_LEFT_CONTROL]  = "LCTRL",
	[rl.KEY_LEFT_ALT]      = "LALT",
	[rl.KEY_LEFT_SUPER]    = "WIN",
	[rl.KEY_RIGHT_SHIFT]   = "RSHIFT",
	[rl.KEY_RIGHT_CONTROL] = "RCTRL",
	[rl.KEY_RIGHT_ALT]     = "ALTGR",
	[rl.KEY_RIGHT_SUPER]   = "RSUPER",
	[rl.KEY_KB_MENU]       = "KBMENU",
	[rl.KEY_KP_0]          = "KP0",
	[rl.KEY_KP_1]          = "KP1",
	[rl.KEY_KP_2]          = "KP2",
	[rl.KEY_KP_3]          = "KP3",
	[rl.KEY_KP_4]          = "KP4",
	[rl.KEY_KP_5]          = "KP5",
	[rl.KEY_KP_6]          = "KP6",
	[rl.KEY_KP_7]          = "KP7",
	[rl.KEY_KP_8]          = "KP8",
	[rl.KEY_KP_9]          = "KP9",
	[rl.KEY_KP_DECIMAL]    = "KPDEC",
	[rl.KEY_KP_DIVIDE]     = "KPDIV",
	[rl.KEY_KP_MULTIPLY]   = "KPMUL",
	[rl.KEY_KP_SUBTRACT]   = "KPSUB",
	[rl.KEY_KP_ADD]        = "KPADD",
	[rl.KEY_KP_ENTER]      = "KPENTER",
	[rl.KEY_KP_EQUAL]      = "KPEQU",
}

local function GetKeyText(key)
	return keyText[key] or ""
end

local function GuiKeyboardKey(bounds, key)
	if key == rl.KEY_NULL then
		rl.DrawRectangleLinesEx(bounds, 2.0, rl.LIGHTGRAY)
	else
		if rl.IsKeyDown(key) then
			rl.DrawRectangleLinesEx(bounds, 2.0, rl.MAROON)
			rl.DrawText(GetKeyText(key), math.floor(bounds.x + 4), math.floor(bounds.y + 4), 10, rl.MAROON)
		else
			rl.DrawRectangleLinesEx(bounds, 2.0, rl.DARKGRAY)
			rl.DrawText(GetKeyText(key), math.floor(bounds.x + 4), math.floor(bounds.y + 4), 10, rl.DARKGRAY)
		end
	end

	if rl.CheckCollisionPointRec(rl.GetMousePosition(), bounds) then
		rl.DrawRectangleRec(bounds, rl.Fade(rl.RED, 0.2))
		rl.DrawRectangleLinesEx(bounds, 3.0, rl.RED)
	end
end

-- Keyboard line 01
local line01KeyWidths = {}
for i = 1, 15 do line01KeyWidths[i] = 45 end
line01KeyWidths[14] = 62   -- PRINTSCREEN
local line01Keys = {
	rl.KEY_ESCAPE, rl.KEY_F1, rl.KEY_F2, rl.KEY_F3, rl.KEY_F4, rl.KEY_F5,
	rl.KEY_F6, rl.KEY_F7, rl.KEY_F8, rl.KEY_F9, rl.KEY_F10, rl.KEY_F11,
	rl.KEY_F12, rl.KEY_PRINT_SCREEN, rl.KEY_PAUSE
}

-- Keyboard line 02
local line02KeyWidths = {}
for i = 1, 15 do line02KeyWidths[i] = 45 end
line02KeyWidths[1] = 25    -- GRAVE
line02KeyWidths[14] = 82   -- BACKSPACE
local line02Keys = {
	rl.KEY_GRAVE, rl.KEY_ONE, rl.KEY_TWO, rl.KEY_THREE, rl.KEY_FOUR,
	rl.KEY_FIVE, rl.KEY_SIX, rl.KEY_SEVEN, rl.KEY_EIGHT, rl.KEY_NINE,
	rl.KEY_ZERO, rl.KEY_MINUS, rl.KEY_EQUAL, rl.KEY_BACKSPACE, rl.KEY_DELETE
}

-- Keyboard line 03
local line03KeyWidths = {}
for i = 1, 15 do line03KeyWidths[i] = 45 end
line03KeyWidths[1] = 50    -- TAB
line03KeyWidths[14] = 57   -- BACKSLASH
local line03Keys = {
	rl.KEY_TAB, rl.KEY_Q, rl.KEY_W, rl.KEY_E, rl.KEY_R, rl.KEY_T, rl.KEY_Y,
	rl.KEY_U, rl.KEY_I, rl.KEY_O, rl.KEY_P, rl.KEY_LEFT_BRACKET,
	rl.KEY_RIGHT_BRACKET, rl.KEY_BACKSLASH, rl.KEY_INSERT
}

-- Keyboard line 04
local line04KeyWidths = {}
for i = 1, 14 do line04KeyWidths[i] = 45 end
line04KeyWidths[1] = 68    -- CAPS
line04KeyWidths[13] = 88   -- ENTER
local line04Keys = {
	rl.KEY_CAPS_LOCK, rl.KEY_A, rl.KEY_S, rl.KEY_D, rl.KEY_F, rl.KEY_G,
	rl.KEY_H, rl.KEY_J, rl.KEY_K, rl.KEY_L, rl.KEY_SEMICOLON,
	rl.KEY_APOSTROPHE, rl.KEY_ENTER, rl.KEY_PAGE_UP
}

-- Keyboard line 05
local line05KeyWidths = {}
for i = 1, 14 do line05KeyWidths[i] = 45 end
line05KeyWidths[1] = 80    -- LSHIFT
line05KeyWidths[12] = 76   -- RSHIFT
local line05Keys = {
	rl.KEY_LEFT_SHIFT, rl.KEY_Z, rl.KEY_X, rl.KEY_C, rl.KEY_V, rl.KEY_B,
	rl.KEY_N, rl.KEY_M, rl.KEY_COMMA, rl.KEY_PERIOD,
	rl.KEY_SLASH, rl.KEY_RIGHT_SHIFT, rl.KEY_UP, rl.KEY_PAGE_DOWN
}

-- Keyboard line 06
local line06KeyWidths = {}
for i = 1, 11 do line06KeyWidths[i] = 45 end
line06KeyWidths[1] = 80    -- LCTRL
line06KeyWidths[4] = 208   -- SPACE
line06KeyWidths[8] = 60    -- RCTRL
local line06Keys = {
	rl.KEY_LEFT_CONTROL, rl.KEY_LEFT_SUPER, rl.KEY_LEFT_ALT,
	rl.KEY_SPACE, rl.KEY_RIGHT_ALT, 162, rl.KEY_NULL,
	rl.KEY_RIGHT_CONTROL, rl.KEY_LEFT, rl.KEY_DOWN, rl.KEY_RIGHT
}

local keyboardOffset = rl.new("Vector2", 26, 80)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	local key = rl.GetKeyPressed()
	if key > 0 then rl.TraceLog(rl.LOG_INFO, string.format("KEYBOARD TESTBED: KEY PRESSED:    %d", key)) end

	local ch = rl.GetCharPressed()
	if ch > 0 then rl.TraceLog(rl.LOG_INFO, string.format("KEYBOARD TESTBED: CHAR PRESSED:   %c (%d)", ch, ch)) end

	-- Draw
	rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawText("KEYBOARD LAYOUT: ENG-US", 26, 38, 20, rl.LIGHTGRAY)

		-- Keyboard line 01
		local recOffsetX = 0
		for i = 1, 15 do
			GuiKeyboardKey(rl.new("Rectangle", keyboardOffset.x + recOffsetX, keyboardOffset.y, line01KeyWidths[i], 30), line01Keys[i])
			recOffsetX = recOffsetX + line01KeyWidths[i] + KEY_REC_SPACING
		end

		-- Keyboard line 02
		recOffsetX = 0
		for i = 1, 15 do
			GuiKeyboardKey(rl.new("Rectangle", keyboardOffset.x + recOffsetX, keyboardOffset.y + 30 + KEY_REC_SPACING, line02KeyWidths[i], 38), line02Keys[i])
			recOffsetX = recOffsetX + line02KeyWidths[i] + KEY_REC_SPACING
		end

		-- Keyboard line 03
		recOffsetX = 0
		for i = 1, 15 do
			GuiKeyboardKey(rl.new("Rectangle", keyboardOffset.x + recOffsetX, keyboardOffset.y + 30 + 38 + KEY_REC_SPACING * 2, line03KeyWidths[i], 38), line03Keys[i])
			recOffsetX = recOffsetX + line03KeyWidths[i] + KEY_REC_SPACING
		end

		-- Keyboard line 04
		recOffsetX = 0
		for i = 1, 14 do
			GuiKeyboardKey(rl.new("Rectangle", keyboardOffset.x + recOffsetX, keyboardOffset.y + 30 + 38 * 2 + KEY_REC_SPACING * 3, line04KeyWidths[i], 38), line04Keys[i])
			recOffsetX = recOffsetX + line04KeyWidths[i] + KEY_REC_SPACING
		end

		-- Keyboard line 05
		recOffsetX = 0
		for i = 1, 14 do
			GuiKeyboardKey(rl.new("Rectangle", keyboardOffset.x + recOffsetX, keyboardOffset.y + 30 + 38 * 3 + KEY_REC_SPACING * 4, line05KeyWidths[i], 38), line05Keys[i])
			recOffsetX = recOffsetX + line05KeyWidths[i] + KEY_REC_SPACING
		end

		-- Keyboard line 06
		recOffsetX = 0
		for i = 1, 11 do
			GuiKeyboardKey(rl.new("Rectangle", keyboardOffset.x + recOffsetX, keyboardOffset.y + 30 + 38 * 4 + KEY_REC_SPACING * 5, line06KeyWidths[i], 38), line06Keys[i])
			recOffsetX = recOffsetX + line06KeyWidths[i] + KEY_REC_SPACING
		end

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
