-- raylib [core] example - drop files

local MAX_FILEPATH_RECORDED = 4096
local MAX_FILEPATH_SIZE = 2048

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - drop files")

local filePathCounter = 0
local filePaths = {}

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsFileDropped() then
		local droppedFiles = rl.LoadDroppedFiles()

		local offset = filePathCounter
		for i = 0, droppedFiles.count - 1 do
			if filePathCounter < (MAX_FILEPATH_RECORDED - 1) then
				filePaths[offset + i] = droppedFiles.paths[i]
				filePathCounter = filePathCounter + 1
			end
		end

		rl.UnloadDroppedFiles(droppedFiles)
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	if filePathCounter == 0 then
		rl.DrawText("Drop your files to this window!", 100, 40, 20, rl.DARKGRAY)
	else
		rl.DrawText("Dropped files:", 100, 40, 20, rl.DARKGRAY)

		for i = 0, filePathCounter - 1 do
			if i % 2 == 0 then
				rl.DrawRectangle(0, 85 + 40 * i, screenWidth, 40, rl.Fade(rl.LIGHTGRAY, 0.5))
			else
				rl.DrawRectangle(0, 85 + 40 * i, screenWidth, 40, rl.Fade(rl.LIGHTGRAY, 0.3))
			end

			rl.DrawText(filePaths[i], 120, 100 + 40 * i, 10, rl.GRAY)
		end

		rl.DrawText("Drop new files...", 100, 110 + 40 * filePathCounter, 20, rl.DARKGRAY)
	end

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
