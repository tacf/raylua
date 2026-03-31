-- raylib [core] example - text file loading

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - text file loading")

-- Setting up the camera
local cam = rl.new("Camera2D", {
	offset = rl.new("Vector2", 0, 0),
	target = rl.new("Vector2", 0, 0),
	rotation = 0,
	zoom = 1,
})

-- Loading text file
local fileName = "resources/text_file.txt"

-- Read file using standard Lua I/O
local lines = {}
do
	local file = io.open(fileName, "r")
	if file then
		for line in file:lines() do
			lines[#lines + 1] = line
		end
		file:close()
	end
end

-- Stylistic choices
local fontSize = 20
local textTop = 25 + fontSize
local wrapWidth = screenWidth - 20

-- Wrap the lines as needed
for i = 1, #lines do
	local line = lines[i]
	local result = {}
	local lastSpace = 0
	local lastWrapStart = 1
	local j = 1

	while j <= #line + 1 do
		local ch = line:sub(j, j)
		if ch == " " or ch == "" then
			local segment = line:sub(lastWrapStart, j - 1)
			if rl.MeasureText(segment, fontSize) > wrapWidth and lastSpace >= lastWrapStart then
				-- Insert newline at last space
				line = line:sub(1, lastSpace - 1) .. "\n" .. line:sub(lastSpace + 1)
				lastWrapStart = lastSpace + 1
			end
			lastSpace = j
		end
		j = j + 1
	end

	lines[i] = line
end

-- Calculating the total height so that we can show a scrollbar
local textHeight = 0
for i = 1, #lines do
	local size = rl.MeasureTextEx(rl.GetFontDefault(), lines[i], fontSize, 2)
	textHeight = textHeight + size.y + 10
end

-- A simple scrollbar on the side
local scrollBar = rl.new("Rectangle",
	screenWidth - 5,
	0,
	5,
	screenHeight * 100.0 / (textHeight - screenHeight)
)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	local scroll = rl.GetMouseWheelMove()
	cam.target.y = cam.target.y - scroll * fontSize * 1.5

	if cam.target.y < 0 then cam.target.y = 0 end

	if cam.target.y > textHeight - screenHeight + textTop then
		cam.target.y = textHeight - screenHeight + textTop
	end

	-- Computing the position of the scrollBar
	local lerpT = (cam.target.y - textTop) / (textHeight - screenHeight)
	scrollBar.y = textTop + (screenHeight - scrollBar.height - textTop) * lerpT

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode2D(cam)
	local t = textTop
	for i = 1, #lines do
		local size
		if lines[i] ~= "" then
			size = rl.MeasureTextEx(rl.GetFontDefault(), lines[i], fontSize, 2)
		else
			size = rl.MeasureTextEx(rl.GetFontDefault(), " ", fontSize, 2)
		end

		rl.DrawText(lines[i], 10, t, fontSize, rl.RED)
		t = t + size.y + 10
	end
	rl.EndMode2D()

	-- Header displaying which file is being read
	rl.DrawRectangle(0, 0, screenWidth, textTop - 10, rl.BEIGE)
	rl.DrawText(string.format("File: %s", fileName), 10, 10, fontSize, rl.MAROON)

	rl.DrawRectangleRec(scrollBar, rl.MAROON)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
