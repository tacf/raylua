local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - blend modes")
rl.SetTargetFPS(60)

local bgImage = rl.LoadImage("resources/cyberpunk_street_background.png")
local bgTexture = rl.LoadTextureFromImage(bgImage)
rl.UnloadImage(bgImage)

local fgImage = rl.LoadImage("resources/cyberpunk_street_foreground.png")
local fgTexture = rl.LoadTextureFromImage(fgImage)
rl.UnloadImage(fgImage)

local blendCountMax = 4
local blendMode = 0

while not rl.WindowShouldClose() do
	if rl.IsKeyPressed(rl.KEY_SPACE) then
		if blendMode >= (blendCountMax - 1) then
			blendMode = 0
		else
			blendMode = blendMode + 1
		end
	end

	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawTexture(bgTexture, screenWidth / 2 - bgTexture.width / 2, screenHeight / 2 - bgTexture.height / 2, rl.WHITE)

	rl.BeginBlendMode(blendMode)
	rl.DrawTexture(fgTexture, screenWidth / 2 - fgTexture.width / 2, screenHeight / 2 - fgTexture.height / 2, rl.WHITE)
	rl.EndBlendMode()

	rl.DrawText("Press SPACE to change blend modes.", 310, 350, 10, rl.GRAY)

	if blendMode == rl.BLEND_ALPHA then
		rl.DrawText("Current: BLEND_ALPHA", screenWidth / 2 - 60, 370, 10, rl.GRAY)
	elseif blendMode == rl.BLEND_ADDITIVE then
		rl.DrawText("Current: BLEND_ADDITIVE", screenWidth / 2 - 60, 370, 10, rl.GRAY)
	elseif blendMode == rl.BLEND_MULTIPLIED then
		rl.DrawText("Current: BLEND_MULTIPLIED", screenWidth / 2 - 60, 370, 10, rl.GRAY)
	elseif blendMode == rl.BLEND_ADD_COLORS then
		rl.DrawText("Current: BLEND_ADD_COLORS", screenWidth / 2 - 60, 370, 10, rl.GRAY)
	end

	rl.DrawText("(c) Cyberpunk Street Environment by Luis Zuno (@ansimuz)", screenWidth - 330, screenHeight - 20, 10, rl.GRAY)

	rl.EndDrawing()
end

rl.UnloadTexture(fgTexture)
rl.UnloadTexture(bgTexture)

rl.CloseWindow()