--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_window_letterbox.c

]]

-- raylib [core] example - window letterbox

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE | rl.FLAG_VSYNC_HINT)
rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - window letterbox")
rl.SetWindowMinSize(320, 240)

local gameScreenWidth = 640
local gameScreenHeight = 480

local target = rl.LoadRenderTexture(gameScreenWidth, gameScreenHeight)
rl.SetTextureFilter(target.texture, rl.TEXTURE_FILTER_BILINEAR)

local colors = {}
for i = 0, 9 do
	colors[i] = rl.new("Color",
		rl.GetRandomValue(100, 250),
		rl.GetRandomValue(50, 150),
		rl.GetRandomValue(10, 100),
		255)
end

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	local scale = math.min(rl.GetScreenWidth() / gameScreenWidth, rl.GetScreenHeight() / gameScreenHeight)

	if rl.IsKeyPressed(rl.KEY_SPACE) then
		for i = 0, 9 do
			colors[i] = rl.new("Color",
				rl.GetRandomValue(100, 250),
				rl.GetRandomValue(50, 150),
				rl.GetRandomValue(10, 100),
				255)
		end
	end

	-- Update virtual mouse (clamped mouse value behind game screen)
	local mouse = rl.GetMousePosition()
	local virtualMouse = rl.new("Vector2", 0, 0)
	virtualMouse.x = (mouse.x - (rl.GetScreenWidth() - (gameScreenWidth * scale)) * 0.5) / scale
	virtualMouse.y = (mouse.y - (rl.GetScreenHeight() - (gameScreenHeight * scale)) * 0.5) / scale
	virtualMouse = rl.Vector2Clamp(virtualMouse, rl.new("Vector2", 0, 0), rl.new("Vector2", gameScreenWidth, gameScreenHeight))

	-- Draw
	rl.BeginTextureMode(target)
	rl.ClearBackground(rl.RAYWHITE)

	for i = 0, 9 do
		rl.DrawRectangle(0, (gameScreenHeight / 10) * i, gameScreenWidth, gameScreenHeight / 10, colors[i])
	end

	rl.DrawText("If executed inside a window,\nyou can resize the window,\nand see the screen scaling!", 10, 25, 20, rl.WHITE)
	rl.DrawText(string.format("Default Mouse: [%i , %i]", mouse.x, mouse.y), 350, 25, 20, rl.GREEN)
	rl.DrawText(string.format("Virtual Mouse: [%i , %i]", virtualMouse.x, virtualMouse.y), 350, 55, 20, rl.YELLOW)
	rl.EndTextureMode()

	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.DrawTexturePro(target.texture, rl.new("Rectangle", 0, 0, target.texture.width, -target.texture.height),
		rl.new("Rectangle",
			(rl.GetScreenWidth() - (gameScreenWidth * scale)) * 0.5,
			(rl.GetScreenHeight() - (gameScreenHeight * scale)) * 0.5,
			gameScreenWidth * scale,
			gameScreenHeight * scale),
		rl.new("Vector2", 0, 0), 0.0, rl.WHITE)
	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadRenderTexture(target)
rl.CloseWindow()
