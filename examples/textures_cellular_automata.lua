local screenWidth = 800
local screenHeight = 450
local imageWidth = 800
local imageHeight = 800 / 2

local drawRuleStartX = 585
local drawRuleStartY = 10
local drawRuleSpacing = 15
local drawRuleGroupSpacing = 50
local drawRuleSize = 14
local drawRuleInnerSize = 10

local presetsSizeX = 42
local presetsSizeY = 22

local linesUpdatedPerFrame = 4

local function ComputeLine(image, line, rule)
	for i = 1, imageWidth - 2 do
		local prevValue = 0
		local colorLeft = rl.GetImageColor(image, i - 1, line - 1)
		local colorCenter = rl.GetImageColor(image, i, line - 1)
		local colorRight = rl.GetImageColor(image, i + 1, line - 1)

		if colorLeft.r < 5 then prevValue = prevValue + 4 end
		if colorCenter.r < 5 then prevValue = prevValue + 2 end
		if colorRight.r < 5 then prevValue = prevValue + 1 end

		local currValue = (rule & (1 << prevValue)) ~= 0

		if currValue then
			rl.ImageDrawPixel(image, i, line, rl.BLACK)
		else
			rl.ImageDrawPixel(image, i, line, rl.RAYWHITE)
		end
	end
end

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - cellular automata")
rl.SetTargetFPS(60)

local image = rl.GenImageColor(imageWidth, imageHeight, rl.RAYWHITE)
rl.ImageDrawPixel(image, imageWidth / 2, 0, rl.BLACK)

local texture = rl.LoadTextureFromImage(image)

local presetValues = { 18, 30, 60, 86, 102, 124, 126, 150, 182, 225 }
local presetsCount = #presetValues

local rule = 30
local line = 1

while not rl.WindowShouldClose() do
	local mouse = rl.GetMousePosition()
	local mouseInCell = -1

	for i = 0, 7 do
		local cellX = drawRuleStartX - drawRuleGroupSpacing * i + drawRuleSpacing
		local cellY = drawRuleStartY + drawRuleSpacing
		if (mouse.x >= cellX) and (mouse.x <= cellX + drawRuleSize) and
		   (mouse.y >= cellY) and (mouse.y <= cellY + drawRuleSize) then
			mouseInCell = i
			break
		end
	end

	if mouseInCell < 0 then
		for i = 0, presetsCount - 1 do
			local cellX = 4 + (presetsSizeX + 2) * math.floor(i / 2)
			local cellY = 2 + (presetsSizeY + 2) * (i % 2)
			if (mouse.x >= cellX) and (mouse.x <= cellX + presetsSizeX) and
			   (mouse.y >= cellY) and (mouse.y <= cellY + presetsSizeY) then
				mouseInCell = i + 8
				break
			end
		end
	end

	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and (mouseInCell >= 0) then
		if mouseInCell < 8 then
			rule = rule ~ (1 << mouseInCell)
		else
			rule = presetValues[mouseInCell - 7]
		end

		rl.ImageClearBackground(image, rl.RAYWHITE)
		rl.ImageDrawPixel(image, imageWidth / 2, 0, rl.BLACK)
		line = 1
	end

	if line < imageHeight then
		for i = 0, linesUpdatedPerFrame - 1 do
			if line + i < imageHeight then
				ComputeLine(image, line + i, rule)
			end
		end
		line = line + linesUpdatedPerFrame

		rl.UpdateTexture(texture, rl.GetImageData(image))
	end

	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexture(texture, 0, screenHeight - imageHeight, rl.WHITE)

	for i = 0, presetsCount - 1 do
		rl.DrawText(tostring(presetValues[i + 1]), 8 + (presetsSizeX + 2) * math.floor(i / 2), 4 + (presetsSizeY + 2) * (i % 2), 20, rl.GRAY)
		rl.DrawRectangleLines(4 + (presetsSizeX + 2) * math.floor(i / 2), 2 + (presetsSizeY + 2) * (i % 2), presetsSizeX, presetsSizeY, rl.BLUE)

		if mouseInCell == i + 8 then
			rl.DrawRectangleLinesEx(rl.new("Rectangle", 2 + (presetsSizeX + 2) * math.floor(i / 2), (presetsSizeY + 2) * (i % 2), presetsSizeX + 4, presetsSizeY + 4), 3, rl.RED)
		end
	end

	for i = 0, 7 do
		for j = 0, 2 do
			rl.DrawRectangleLines(drawRuleStartX - drawRuleGroupSpacing * i + drawRuleSpacing * j, drawRuleStartY, drawRuleSize, drawRuleSize, rl.GRAY)
			if i & (4 >> j) ~= 0 then
				rl.DrawRectangle(drawRuleStartX + 2 - drawRuleGroupSpacing * i + drawRuleSpacing * j, drawRuleStartY + 2, drawRuleInnerSize, drawRuleInnerSize, rl.BLACK)
			end
		end

		rl.DrawRectangleLines(drawRuleStartX - drawRuleGroupSpacing * i + drawRuleSpacing, drawRuleStartY + drawRuleSpacing, drawRuleSize, drawRuleSize, rl.BLUE)
		if rule & (1 << i) ~= 0 then
			rl.DrawRectangle(drawRuleStartX + 2 - drawRuleGroupSpacing * i + drawRuleSpacing, drawRuleStartY + 2 + drawRuleSpacing, drawRuleInnerSize, drawRuleInnerSize, rl.BLACK)
		end

		if mouseInCell == i then
			rl.DrawRectangleLinesEx(rl.new("Rectangle", drawRuleStartX - drawRuleGroupSpacing * i + drawRuleSpacing - 2, drawRuleStartY + drawRuleSpacing - 2, drawRuleSize + 4, drawRuleSize + 4), 3, rl.RED)
		end
	end

	rl.DrawText("RULE: " .. tostring(rule), drawRuleStartX + drawRuleSpacing * 4, drawRuleStartY + 1, 30, rl.GRAY)

	rl.EndDrawing()
end

rl.UnloadImage(image)
rl.UnloadTexture(texture)

rl.CloseWindow()