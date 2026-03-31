-- raylib [core] example - render texture

-- Initialization
local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - render texture")

local renderTextureWidth = 300
local renderTextureHeight = 300
local target = rl.LoadRenderTexture(renderTextureWidth, renderTextureHeight)

local ballPosition = rl.new("Vector2", renderTextureWidth / 2.0, renderTextureHeight / 2.0)
local ballSpeed = rl.new("Vector2", 5.0, 4.0)
local ballRadius = 20

local rotation = 0.0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	ballPosition.x = ballPosition.x + ballSpeed.x
	ballPosition.y = ballPosition.y + ballSpeed.y

	if (ballPosition.x >= (renderTextureWidth - ballRadius)) or (ballPosition.x <= ballRadius) then
		ballSpeed.x = ballSpeed.x * -1.0
	end
	if (ballPosition.y >= (renderTextureHeight - ballRadius)) or (ballPosition.y <= ballRadius) then
		ballSpeed.y = ballSpeed.y * -1.0
	end

	rotation = rotation + 0.5

	-- Draw
	-- Draw our scene to the render texture
	rl.BeginTextureMode(target)
	rl.ClearBackground(rl.SKYBLUE)

	rl.DrawRectangle(0, 0, 20, 20, rl.RED)
	rl.DrawCircleV(ballPosition, ballRadius, rl.MAROON)

	rl.EndTextureMode()

	-- Draw render texture to main framebuffer
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	-- Draw render texture with rotation applied
	-- NOTE: We flip vertically the texture setting negative source rectangle height
	rl.DrawTexturePro(target.texture,
		rl.new("Rectangle", 0, 0, target.texture.width, -target.texture.height),
		rl.new("Rectangle", screenWidth / 2.0, screenHeight / 2.0, target.texture.width, target.texture.height),
		rl.new("Vector2", target.texture.width / 2.0, target.texture.height / 2.0), rotation, rl.WHITE)

	rl.DrawText("DRAWING BOUNCING BALL INSIDE RENDER TEXTURE!", 10, screenHeight - 40, 20, rl.BLACK)

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
