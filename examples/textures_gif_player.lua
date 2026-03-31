local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - gif player")
rl.SetTargetFPS(60)

local MAX_FRAME_DELAY = 20
local MIN_FRAME_DELAY = 1

local animFrames = 0
local imScarfyAnim = rl.LoadImageAnim("resources/scarfy_run.gif", animFrames)

local texScarfyAnim = rl.LoadTextureFromImage(imScarfyAnim)

local nextFrameDataOffset = 0
local currentAnimFrame = 0
local frameDelay = 8
local frameCounter = 0

while not rl.WindowShouldClose() do
	frameCounter = frameCounter + 1
	if frameCounter >= frameDelay then
		currentAnimFrame = currentAnimFrame + 1
		if currentAnimFrame >= animFrames then currentAnimFrame = 0 end

		nextFrameDataOffset = imScarfyAnim.width * imScarfyAnim.height * 4 * currentAnimFrame

		local imageData = rl.GetImageData(imScarfyAnim)
		local offsetBytes = nextFrameDataOffset * 4
		local frameData = {}
		for i = offsetBytes, offsetBytes + imScarfyAnim.width * imScarfyAnim.height * 4 - 1 do
			table.insert(frameData, imageData[i + 1])
		end
		rl.UpdateTexture(texScarfyAnim, frameData)

		frameCounter = 0
	end

	if rl.IsKeyPressed(rl.KEY_RIGHT) then
		frameDelay = frameDelay + 1
	elseif rl.IsKeyPressed(rl.KEY_LEFT) then
		frameDelay = frameDelay - 1
	end

	if frameDelay > MAX_FRAME_DELAY then frameDelay = MAX_FRAME_DELAY end
	if frameDelay < MIN_FRAME_DELAY then frameDelay = MIN_FRAME_DELAY end

	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawText("TOTAL GIF FRAMES:  " .. string.format("%02i", animFrames), 50, 30, 20, rl.LIGHTGRAY)
	rl.DrawText("CURRENT FRAME: " .. string.format("%02i", currentAnimFrame), 50, 60, 20, rl.GRAY)
	rl.DrawText("CURRENT FRAME IMAGE.DATA OFFSET: " .. string.format("%02i", nextFrameDataOffset), 50, 90, 20, rl.GRAY)

	rl.DrawText("FRAMES DELAY: ", 100, 305, 10, rl.DARKGRAY)
	rl.DrawText(string.format("%02i frames", frameDelay), 620, 305, 10, rl.DARKGRAY)
	rl.DrawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 350, 10, rl.DARKGRAY)

	for i = 0, MAX_FRAME_DELAY - 1 do
		if i < frameDelay then
			rl.DrawRectangle(190 + 21 * i, 300, 20, 20, rl.RED)
		end
		rl.DrawRectangleLines(190 + 21 * i, 300, 20, 20, rl.MAROON)
	end

	rl.DrawTexture(texScarfyAnim, rl.GetScreenWidth() / 2 - texScarfyAnim.width / 2, 140, rl.WHITE)

	rl.DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, rl.GRAY)

	rl.EndDrawing()
end

rl.UnloadTexture(texScarfyAnim)
rl.UnloadImage(imScarfyAnim)

rl.CloseWindow()