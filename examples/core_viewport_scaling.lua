-- raylib [core] example - viewport scaling

local RESOLUTION_COUNT = 4

local VIEWPORT_TYPES = {
	"KEEP_ASPECT_INTEGER",
	"KEEP_HEIGHT_INTEGER",
	"KEEP_WIDTH_INTEGER",
	"KEEP_ASPECT",
	"KEEP_HEIGHT",
	"KEEP_WIDTH",
}
local VIEWPORT_TYPE_COUNT = #VIEWPORT_TYPES

local function KeepAspectCenteredInteger(scrW, scrH, gameW, gameH)
	local sourceRect = rl.new("Rectangle", 0, gameH, gameW, -gameH)

	local ratioX = math.floor(scrW / gameW)
	local ratioY = math.floor(scrH / gameH)
	local resizeRatio = math.min(ratioX, ratioY)

	local destRect = rl.new("Rectangle",
		math.floor((scrW - gameW * resizeRatio) * 0.5),
		math.floor((scrH - gameH * resizeRatio) * 0.5),
		math.floor(gameW * resizeRatio),
		math.floor(gameH * resizeRatio))

	return sourceRect, destRect
end

local function KeepHeightCenteredInteger(scrW, scrH, gameW, gameH)
	local resizeRatio = scrH / gameH
	local sourceRect = rl.new("Rectangle", 0, 0, math.floor(scrW / resizeRatio), -gameH)

	local destRect = rl.new("Rectangle",
		math.floor((scrW - sourceRect.width * resizeRatio) * 0.5),
		math.floor((scrH - gameH * resizeRatio) * 0.5),
		math.floor(sourceRect.width * resizeRatio),
		math.floor(gameH * resizeRatio))

	return sourceRect, destRect
end

local function KeepWidthCenteredInteger(scrW, scrH, gameW, gameH)
	local resizeRatio = scrW / gameW
	local sourceRect = rl.new("Rectangle", 0, 0, gameW, -math.floor(scrH / resizeRatio))

	local destRect = rl.new("Rectangle",
		math.floor((scrW - gameW * resizeRatio) * 0.5),
		math.floor((scrH - (-sourceRect.height) * resizeRatio) * 0.5),
		math.floor(gameW * resizeRatio),
		math.floor((-sourceRect.height) * resizeRatio))

	return sourceRect, destRect
end

local function KeepAspectCentered(scrW, scrH, gameW, gameH)
	local sourceRect = rl.new("Rectangle", 0, gameH, gameW, -gameH)

	local ratioX = scrW / gameW
	local ratioY = scrH / gameH
	local resizeRatio = math.min(ratioX, ratioY)

	local destRect = rl.new("Rectangle",
		math.floor((scrW - gameW * resizeRatio) * 0.5),
		math.floor((scrH - gameH * resizeRatio) * 0.5),
		math.floor(gameW * resizeRatio),
		math.floor(gameH * resizeRatio))

	return sourceRect, destRect
end

local function KeepHeightCentered(scrW, scrH, gameW, gameH)
	local resizeRatio = scrH / gameH
	local sourceRect = rl.new("Rectangle", 0, 0, math.floor(scrW / resizeRatio), -gameH)

	local destRect = rl.new("Rectangle",
		math.floor((scrW - sourceRect.width * resizeRatio) * 0.5),
		math.floor((scrH - gameH * resizeRatio) * 0.5),
		math.floor(sourceRect.width * resizeRatio),
		math.floor(gameH * resizeRatio))

	return sourceRect, destRect
end

local function KeepWidthCentered(scrW, scrH, gameW, gameH)
	local resizeRatio = scrW / gameW
	local sourceRect = rl.new("Rectangle", 0, 0, gameW, -math.floor(scrH / resizeRatio))

	local destRect = rl.new("Rectangle",
		math.floor((scrW - gameW * resizeRatio) * 0.5),
		math.floor((scrH - (-sourceRect.height) * resizeRatio) * 0.5),
		math.floor(gameW * resizeRatio),
		math.floor((-sourceRect.height) * resizeRatio))

	return sourceRect, destRect
end

local viewportFunctions = {
	KeepAspectCenteredInteger,
	KeepHeightCenteredInteger,
	KeepWidthCenteredInteger,
	KeepAspectCentered,
	KeepHeightCentered,
	KeepWidthCentered,
}

local function Screen2RenderTexturePosition(point, textureRect, scaledRect)
	local relativePosition = rl.new("Vector2", point.x - scaledRect.x, point.y - scaledRect.y)
	local ratio = rl.new("Vector2", textureRect.width / scaledRect.width, -textureRect.height / scaledRect.height)
	return rl.new("Vector2", relativePosition.x * ratio.x, relativePosition.y * ratio.x)
end

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE)
rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - viewport scaling")

-- Preset resolutions
local resolutionList = {
	rl.new("Vector2", 64, 64),
	rl.new("Vector2", 256, 240),
	rl.new("Vector2", 320, 180),
	-- 4K doesn't work with integer scaling but included for example purposes with non-integer scaling
	rl.new("Vector2", 3840, 2160),
}

local resolutionIndex = 1
local gameWidth = 64
local gameHeight = 64

local viewportType = 1  -- KEEP_ASPECT_INTEGER (0-indexed in C, 1-indexed in Lua)

local function ResizeRenderSize()
	screenWidth = rl.GetScreenWidth()
	screenHeight = rl.GetScreenHeight()
	local fn = viewportFunctions[viewportType]
	return fn(screenWidth, screenHeight, gameWidth, gameHeight)
end

local sourceRect, destRect = ResizeRenderSize()
local target = rl.LoadRenderTexture(math.floor(sourceRect.width), math.floor(-sourceRect.height))

-- Button rectangles
local decreaseResolutionButton = rl.new("Rectangle", 200, 30, 10, 10)
local increaseResolutionButton = rl.new("Rectangle", 215, 30, 10, 10)
local decreaseTypeButton = rl.new("Rectangle", 200, 45, 10, 10)
local increaseTypeButton = rl.new("Rectangle", 215, 45, 10, 10)

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	if rl.IsWindowResized() then
		rl.UnloadRenderTexture(target)
		sourceRect, destRect = ResizeRenderSize()
		target = rl.LoadRenderTexture(math.floor(sourceRect.width), math.floor(-sourceRect.height))
	end

	local mousePosition = rl.GetMousePosition()
	local mousePressed = rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)

	-- Check buttons and rescale
	if rl.CheckCollisionPointRec(mousePosition, decreaseResolutionButton) and mousePressed then
		resolutionIndex = ((resolutionIndex - 2) % RESOLUTION_COUNT) + 1
		gameWidth = math.floor(resolutionList[resolutionIndex].x)
		gameHeight = math.floor(resolutionList[resolutionIndex].y)
		rl.UnloadRenderTexture(target)
		sourceRect, destRect = ResizeRenderSize()
		target = rl.LoadRenderTexture(math.floor(sourceRect.width), math.floor(-sourceRect.height))
	end

	if rl.CheckCollisionPointRec(mousePosition, increaseResolutionButton) and mousePressed then
		resolutionIndex = (resolutionIndex % RESOLUTION_COUNT) + 1
		gameWidth = math.floor(resolutionList[resolutionIndex].x)
		gameHeight = math.floor(resolutionList[resolutionIndex].y)
		rl.UnloadRenderTexture(target)
		sourceRect, destRect = ResizeRenderSize()
		target = rl.LoadRenderTexture(math.floor(sourceRect.width), math.floor(-sourceRect.height))
	end

	if rl.CheckCollisionPointRec(mousePosition, decreaseTypeButton) and mousePressed then
		viewportType = ((viewportType - 2) % VIEWPORT_TYPE_COUNT) + 1
		rl.UnloadRenderTexture(target)
		sourceRect, destRect = ResizeRenderSize()
		target = rl.LoadRenderTexture(math.floor(sourceRect.width), math.floor(-sourceRect.height))
	end

	if rl.CheckCollisionPointRec(mousePosition, increaseTypeButton) and mousePressed then
		viewportType = (viewportType % VIEWPORT_TYPE_COUNT) + 1
		rl.UnloadRenderTexture(target)
		sourceRect, destRect = ResizeRenderSize()
		target = rl.LoadRenderTexture(math.floor(sourceRect.width), math.floor(-sourceRect.height))
	end

	local textureMousePosition = Screen2RenderTexturePosition(mousePosition, sourceRect, destRect)

	-- Draw
	-- Draw our scene to the render texture
	rl.BeginTextureMode(target)
		rl.ClearBackground(rl.WHITE)
		rl.DrawCircleV(textureMousePosition, 20.0, rl.LIME)
	rl.EndTextureMode()

	-- Draw render texture to main framebuffer
	rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		-- Draw our render texture with rotation applied
		rl.DrawTexturePro(target.texture, sourceRect, destRect, rl.new("Vector2", 0, 0), 0.0, rl.WHITE)

		-- Draw info box
		local infoRect = rl.new("Rectangle", 5, 5, 330, 105)
		rl.DrawRectangleRec(infoRect, rl.Fade(rl.LIGHTGRAY, 0.7))
		rl.DrawRectangleLinesEx(infoRect, 1, rl.BLUE)

		rl.DrawText(string.format("Window Resolution: %d x %d", screenWidth, screenHeight), 15, 15, 10, rl.BLACK)
		rl.DrawText(string.format("Game Resolution: %d x %d", gameWidth, gameHeight), 15, 30, 10, rl.BLACK)

		rl.DrawText(string.format("Type: %s", VIEWPORT_TYPES[viewportType]), 15, 45, 10, rl.BLACK)
		local scaleRatio = rl.new("Vector2", destRect.width / sourceRect.width, -destRect.height / sourceRect.height)
		if scaleRatio.x < 0.001 or scaleRatio.y < 0.001 then
			rl.DrawText("Scale ratio: INVALID", 15, 60, 10, rl.BLACK)
		else
			rl.DrawText(string.format("Scale ratio: %.2f x %.2f", scaleRatio.x, scaleRatio.y), 15, 60, 10, rl.BLACK)
		end

		rl.DrawText(string.format("Source size: %.2f x %.2f", sourceRect.width, -sourceRect.height), 15, 75, 10, rl.BLACK)
		rl.DrawText(string.format("Destination size: %.2f x %.2f", destRect.width, destRect.height), 15, 90, 10, rl.BLACK)

		-- Draw buttons
		rl.DrawRectangleRec(decreaseTypeButton, rl.SKYBLUE)
		rl.DrawRectangleRec(increaseTypeButton, rl.SKYBLUE)
		rl.DrawRectangleRec(decreaseResolutionButton, rl.SKYBLUE)
		rl.DrawRectangleRec(increaseResolutionButton, rl.SKYBLUE)
		rl.DrawText("<", math.floor(decreaseTypeButton.x) + 3, math.floor(decreaseTypeButton.y) + 1, 10, rl.BLACK)
		rl.DrawText(">", math.floor(increaseTypeButton.x) + 3, math.floor(increaseTypeButton.y) + 1, 10, rl.BLACK)
		rl.DrawText("<", math.floor(decreaseResolutionButton.x) + 3, math.floor(decreaseResolutionButton.y) + 1, 10, rl.BLACK)
		rl.DrawText(">", math.floor(increaseResolutionButton.x) + 3, math.floor(increaseResolutionButton.y) + 1, 10, rl.BLACK)

	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadRenderTexture(target)
rl.CloseWindow()
