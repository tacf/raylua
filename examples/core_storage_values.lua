-- raylib [core] example - storage values

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - storage values")

local STORAGE_DATA_FILE = "storage.data"

-- Storage positions
local STORAGE_POSITION_SCORE = 0
local STORAGE_POSITION_HISCORE = 1

-- Save integer value to storage file (to defined position)
-- NOTE: Storage positions is directly related to file memory layout (4 bytes each integer)
local function SaveStorageValue(position, value)
	local file = io.open(STORAGE_DATA_FILE, "rb")
	local data

	if file then
		data = file:read("*a")
		file:close()
	end

	if data and #data >= (position + 1) * 4 then
		-- Replace value at position
		local before = data:sub(1, position * 4)
		local after = data:sub(position * 4 + 5)
		data = before .. string.pack("i", value) .. after
	else
		-- Need to expand or create data
		local newSize = (position + 1) * 4
		if data then
			-- Expand existing data
			data = data .. string.rep("\0", newSize - #data)
			local before = data:sub(1, position * 4)
			local after = data:sub(position * 4 + 5)
			data = before .. string.pack("i", value) .. after
		else
			-- Create new data
			data = string.rep("\0", position * 4) .. string.pack("i", value)
		end
	end

	local out = io.open(STORAGE_DATA_FILE, "wb")
	if out then
		out:write(data)
		out:close()
		return true
	end

	return false
end

-- Load integer value from storage file (from defined position)
-- NOTE: If requested position could not be found, value 0 is returned
local function LoadStorageValue(position)
	local file = io.open(STORAGE_DATA_FILE, "rb")
	if not file then return 0 end

	local data = file:read("*a")
	file:close()

	if not data or #data < (position + 1) * 4 then
		return 0
	end

	local value = string.unpack("i", data, position * 4 + 1)
	return value
end

local score = 0
local hiscore = 0
local framesCounter = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyPressed(rl.KEY_R) then
		score = rl.GetRandomValue(1000, 2000)
		hiscore = rl.GetRandomValue(2000, 4000)
	end

	if rl.IsKeyPressed(rl.KEY_ENTER) then
		SaveStorageValue(STORAGE_POSITION_SCORE, score)
		SaveStorageValue(STORAGE_POSITION_HISCORE, hiscore)
	elseif rl.IsKeyPressed(rl.KEY_SPACE) then
		score = LoadStorageValue(STORAGE_POSITION_SCORE)
		hiscore = LoadStorageValue(STORAGE_POSITION_HISCORE)
	end

	framesCounter = framesCounter + 1

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawText(string.format("SCORE: %i", score), 280, 130, 40, rl.MAROON)
	rl.DrawText(string.format("HI-SCORE: %i", hiscore), 210, 200, 50, rl.BLACK)

	rl.DrawText(string.format("frames: %i", framesCounter), 10, 10, 20, rl.LIME)

	rl.DrawText("Press R to generate random numbers", 220, 40, 20, rl.LIGHTGRAY)
	rl.DrawText("Press ENTER to SAVE values", 250, 310, 20, rl.LIGHTGRAY)
	rl.DrawText("Press SPACE to LOAD values", 252, 350, 20, rl.LIGHTGRAY)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
