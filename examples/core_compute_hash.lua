-- raylib [core] example - compute hash

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - compute hash")

-- UI controls variables
local textInput = "The quick brown fox jumps over the lazy dog."
local textBoxEditMode = false
local btnComputeHashes = false

-- Data hash values
local hashCRC32 = 0
local hashMD5 = nil
local hashSHA1 = nil
local hashSHA256 = nil

-- Base64 encoded data
local base64Text = nil

rl.SetTargetFPS(60)

-- Convert hash data array to hex string
local function GetDataAsHexText(data, dataSize)
	if data ~= nil and dataSize > 0 and dataSize < 15 then
		local text = ""
		for i = 0, dataSize - 1 do
			text = text .. string.format("%08X", data[i])
		end
		return text
	else
		return "00000000"
	end
end

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if btnComputeHashes then
		local textInputLen = #textInput

		-- Encode data to Base64 string
		base64Text = rl.EncodeDataBase64(textInput, textInputLen)

		hashCRC32 = rl.ComputeCRC32(textInput, textInputLen)
		hashMD5 = rl.ComputeMD5(textInput, textInputLen)
		hashSHA1 = rl.ComputeSHA1(textInput, textInputLen)
		hashSHA256 = rl.ComputeSHA256(textInput, textInputLen)
	end

	-- Draw
	rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SIZE, 20)
		rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SPACING, 2)
		rl.GuiLabel(rl.new("Rectangle", 40, 26, 720, 32), "INPUT DATA (TEXT):")
		rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SPACING, 1)
		rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SIZE, 10)

		if rl.GuiTextBox(rl.new("Rectangle", 40, 64, 720, 32), textInput, 95, textBoxEditMode) then
			textBoxEditMode = not textBoxEditMode
		end

		btnComputeHashes = rl.GuiButton(rl.new("Rectangle", 40, 64 + 40, 720, 32), "COMPUTE INPUT DATA HASHES")

		rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SIZE, 20)
		rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SPACING, 2)
		rl.GuiLabel(rl.new("Rectangle", 40, 160, 720, 32), "INPUT DATA HASH VALUES:")
		rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SPACING, 1)
		rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SIZE, 10)

		rl.GuiSetStyle(rl.TEXTBOX, rl.TEXT_READONLY, 1)
		rl.GuiLabel(rl.new("Rectangle", 40, 200, 120, 32), "CRC32 [32 bit]:")
		rl.GuiTextBox(rl.new("Rectangle", 40 + 120, 200, 720 - 120, 32), GetDataAsHexText({hashCRC32}, 1), 120, false)
		rl.GuiLabel(rl.new("Rectangle", 40, 200 + 36, 120, 32), "MD5 [128 bit]:")
		rl.GuiTextBox(rl.new("Rectangle", 40 + 120, 200 + 36, 720 - 120, 32), GetDataAsHexText(hashMD5, 4), 120, false)
		rl.GuiLabel(rl.new("Rectangle", 40, 200 + 36 * 2, 120, 32), "SHA1 [160 bit]:")
		rl.GuiTextBox(rl.new("Rectangle", 40 + 120, 200 + 36 * 2, 720 - 120, 32), GetDataAsHexText(hashSHA1, 5), 120, false)
		rl.GuiLabel(rl.new("Rectangle", 40, 200 + 36 * 3, 120, 32), "SHA256 [256 bit]:")
		rl.GuiTextBox(rl.new("Rectangle", 40 + 120, 200 + 36 * 3, 720 - 120, 32), GetDataAsHexText(hashSHA256, 8), 120, false)

		rl.GuiSetState(rl.STATE_FOCUSED)
		rl.GuiLabel(rl.new("Rectangle", 40, 200 + 36 * 5 - 30, 320, 32), "BONUS - BASE64 ENCODED STRING:")
		rl.GuiSetState(rl.STATE_NORMAL)
		rl.GuiLabel(rl.new("Rectangle", 40, 200 + 36 * 5, 120, 32), "BASE64 ENCODING:")
		rl.GuiTextBox(rl.new("Rectangle", 40 + 120, 200 + 36 * 5, 720 - 120, 32), base64Text or "", 120, false)
		rl.GuiSetStyle(rl.TEXTBOX, rl.TEXT_READONLY, 0)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
