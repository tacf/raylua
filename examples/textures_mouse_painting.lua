--[[
    raylib [textures] example - mouse painting

    Example complexity rating: [★★★☆] 3/4

    Example originally created with raylib 3.0, last time updated with raylib 3.0

    Example contributed by Chris Dill (@MysteriousSpace) and reviewed by Ramon Santamaria (@raysan5)

    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software

    Copyright (c) 2019-2025 Chris Dill (@MysteriousSpace) and Ramon Santamaria (@raysan5)
]]

local MAX_COLORS_COUNT = 23                                      -- Number of colors available

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - mouse painting")

-- Colors to choose from
local colors = {
	rl.RAYWHITE, rl.YELLOW, rl.GOLD, rl.ORANGE, rl.PINK, rl.RED, rl.MAROON, rl.GREEN, rl.LIME, rl.DARKGREEN,
	rl.SKYBLUE, rl.BLUE, rl.DARKBLUE, rl.PURPLE, rl.VIOLET, rl.DARKPURPLE, rl.BEIGE, rl.BROWN, rl.DARKBROWN,
	rl.LIGHTGRAY, rl.GRAY, rl.DARKGRAY, rl.BLACK
}

-- Define colorsRecs data (for every rectangle)
local colorsRecs = {}
for i = 1, MAX_COLORS_COUNT do
	colorsRecs[i] = rl.new("Rectangle", 10 + 30.0*(i-1) + 2*(i-1), 10, 30, 30)
end

local colorSelected = 1
local colorSelectedPrev = colorSelected
local colorMouseHover = 0
local brushSize = 20.0
local mouseWasPressed = false

local btnSaveRec = rl.new("Rectangle", 750, 10, 40, 30)
local btnSaveMouseHover = false
local showSaveMessage = false
local saveMessageCounter = 0

-- Create a RenderTexture2D to use as a canvas
local target = rl.LoadRenderTexture(screenWidth, screenHeight)

-- Clear render texture before entering the game loop
rl.BeginTextureMode(target)
rl.ClearBackground(colors[1])
rl.EndTextureMode()

rl.SetTargetFPS(120)                                             -- Set our game to run at 120 frames-per-second

-- Main game loop
while not rl.WindowShouldClose() do                              -- Detect window close button or ESC key
	-- Update
	local mousePos = rl.GetMousePosition()

	-- Move between colors with keys
	if rl.IsKeyPressed(rl.KEY_RIGHT) then colorSelected = colorSelected + 1
	elseif rl.IsKeyPressed(rl.KEY_LEFT) then colorSelected = colorSelected - 1 end

	if colorSelected > MAX_COLORS_COUNT then colorSelected = MAX_COLORS_COUNT
	elseif colorSelected < 1 then colorSelected = 1 end

	-- Choose color with mouse
	colorMouseHover = 0
	for i = 1, MAX_COLORS_COUNT do
		if rl.CheckCollisionPointRec(mousePos, colorsRecs[i]) then
			colorMouseHover = i
			break
		end
	end

	if (colorMouseHover > 0) and rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then
		colorSelected = colorMouseHover
		colorSelectedPrev = colorSelected
	end

	-- Change brush size
	brushSize = brushSize + rl.GetMouseWheelMove()*5
	if brushSize < 2 then brushSize = 2 end
	if brushSize > 50 then brushSize = 50 end

	if rl.IsKeyPressed(rl.KEY_C) then
		-- Clear render texture to clear color
		rl.BeginTextureMode(target)
		rl.ClearBackground(colors[1])
		rl.EndTextureMode()
	end

	if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) or (rl.GetGestureDetected() == rl.GESTURE_DRAG) then
		-- Paint circle into render texture
		-- NOTE: To avoid discontinuous circles, we could store
		-- previous-next mouse points and just draw a line using brush size
		rl.BeginTextureMode(target)
		if mousePos.y > 50 then rl.DrawCircle(math.floor(mousePos.x), math.floor(mousePos.y), brushSize, colors[colorSelected]) end
		rl.EndTextureMode()
	end

	if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_RIGHT) then
		if not mouseWasPressed then
			colorSelectedPrev = colorSelected
			colorSelected = 1
		end

		mouseWasPressed = true

		-- Erase circle from render texture
		rl.BeginTextureMode(target)
		if mousePos.y > 50 then rl.DrawCircle(math.floor(mousePos.x), math.floor(mousePos.y), brushSize, colors[1]) end
		rl.EndTextureMode()
	elseif rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_RIGHT) and mouseWasPressed then
		colorSelected = colorSelectedPrev
		mouseWasPressed = false
	end

	-- Check mouse hover save button
	btnSaveMouseHover = rl.CheckCollisionPointRec(mousePos, btnSaveRec)

	-- Image saving logic
	-- NOTE: Saving painted texture to a default named image
	if (btnSaveMouseHover and rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT)) or rl.IsKeyPressed(rl.KEY_S) then
		local image = rl.LoadImageFromTexture(target.texture)
		rl.ImageFlipVertical(image)
		rl.ExportImage(image, "my_amazing_texture_painting.png")
		rl.UnloadImage(image)
		showSaveMessage = true
	end

	if showSaveMessage then
		-- On saving, show a full screen message for 2 seconds
		saveMessageCounter = saveMessageCounter + 1
		if saveMessageCounter > 240 then
			showSaveMessage = false
			saveMessageCounter = 0
		end
	end

	-- Draw
	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	-- NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
	rl.DrawTextureRec(target.texture, rl.new("Rectangle", 0, 0, target.texture.width, -target.texture.height),
		rl.new("Vector2", 0, 0), rl.WHITE)

	-- Draw drawing circle for reference
	if mousePos.y > 50 then
		if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_RIGHT) then
			rl.DrawCircleLines(math.floor(mousePos.x), math.floor(mousePos.y), brushSize, rl.GRAY)
		else
			rl.DrawCircle(rl.GetMouseX(), rl.GetMouseY(), brushSize, colors[colorSelected])
		end
	end

	-- Draw top panel
	rl.DrawRectangle(0, 0, rl.GetScreenWidth(), 50, rl.RAYWHITE)
	rl.DrawLine(0, 50, rl.GetScreenWidth(), 50, rl.LIGHTGRAY)

	-- Draw color selection rectangles
	for i = 1, MAX_COLORS_COUNT do rl.DrawRectangleRec(colorsRecs[i], colors[i]) end
	rl.DrawRectangleLines(10, 10, 30, 30, rl.LIGHTGRAY)

	if colorMouseHover > 0 then rl.DrawRectangleRec(colorsRecs[colorMouseHover], rl.Fade(rl.WHITE, 0.6)) end

	rl.DrawRectangleLinesEx(rl.new("Rectangle", colorsRecs[colorSelected].x - 2, colorsRecs[colorSelected].y - 2,
		colorsRecs[colorSelected].width + 4, colorsRecs[colorSelected].height + 4), 2, rl.BLACK)

	-- Draw save image button
	rl.DrawRectangleLinesEx(btnSaveRec, 2, btnSaveMouseHover and rl.RED or rl.BLACK)
	rl.DrawText("SAVE!", 755, 20, 10, btnSaveMouseHover and rl.RED or rl.BLACK)

	-- Draw save image message
	if showSaveMessage then
		rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.Fade(rl.RAYWHITE, 0.8))
		rl.DrawRectangle(0, 150, rl.GetScreenWidth(), 80, rl.BLACK)
		rl.DrawText("IMAGE SAVED!", 150, 180, 20, rl.RAYWHITE)
	end

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadRenderTexture(target)                                   -- Unload render texture

rl.CloseWindow()                                                 -- Close window and OpenGL context
