--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_directory_files.c

]]

-- raylib [core] example - directory files

local MAX_FILEPATH_SIZE = 1024

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - directory files")

local directory = rl.GetWorkingDirectory()

-- Load file-paths on current working directory
-- NOTE: LoadDirectoryFiles() loads files and directories by default,
-- use LoadDirectoryFilesEx() for custom filters and recursive directories loading
local files = rl.LoadDirectoryFilesEx(directory, ".png;.c", false)

local btnBackPressed = false

local listScrollIndex = 0
local listItemActive = -1
local listItemFocused = -1

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if btnBackPressed then
		directory = rl.GetPrevDirectoryPath(directory)
		rl.UnloadDirectoryFiles(files)
		files = rl.LoadDirectoryFiles(directory)
	end

	-- Draw
	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		btnBackPressed = rl.GuiButton(rl.new("Rectangle", 40, 10, 48, 28), "<")

		rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SIZE, rl.GuiGetFont().baseSize * 2)
		rl.GuiLabel(rl.new("Rectangle", 40 + 48 + 10, 10, 700, 28), directory)
		rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SIZE, rl.GuiGetFont().baseSize)

		rl.GuiSetStyle(rl.LISTVIEW, rl.TEXT_ALIGNMENT, rl.TEXT_ALIGN_LEFT)
		rl.GuiSetStyle(rl.LISTVIEW, rl.TEXT_PADDING, 40)
		rl.GuiListViewEx(rl.new("Rectangle", 0, 50, rl.GetScreenWidth(), rl.GetScreenHeight() - 50),
			files.paths, files.count, listScrollIndex, listItemActive, listItemFocused)
	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadDirectoryFiles(files)
rl.CloseWindow()
