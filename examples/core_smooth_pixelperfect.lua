-- raylib [core] example - smooth pixelperfect

-- Initialization
local screenWidth = 800
local screenHeight = 450

local virtualScreenWidth = 160
local virtualScreenHeight = 90

local virtualRatio = screenWidth / virtualScreenWidth

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - smooth pixelperfect")

local worldSpaceCamera = rl.new("Camera2D", {
	offset = rl.new("Vector2", 0, 0),
	target = rl.new("Vector2", 0, 0),
	rotation = 0,
	zoom = 1.0,
})

local screenSpaceCamera = rl.new("Camera2D", {
	offset = rl.new("Vector2", 0, 0),
	target = rl.new("Vector2", 0, 0),
	rotation = 0,
	zoom = 1.0,
})

local target = rl.LoadRenderTexture(virtualScreenWidth, virtualScreenHeight)

local rec01 = rl.new("Rectangle", 70.0, 35.0, 20.0, 20.0)
local rec02 = rl.new("Rectangle", 90.0, 55.0, 30.0, 10.0)
local rec03 = rl.new("Rectangle", 80.0, 65.0, 15.0, 25.0)

local sourceRec = rl.new("Rectangle", 0.0, 0.0, target.texture.width, -target.texture.height)
local destRec = rl.new("Rectangle", -virtualRatio, -virtualRatio, screenWidth + (virtualRatio * 2), screenHeight + (virtualRatio * 2))

local origin = rl.new("Vector2", 0.0, 0.0)

local rotation = 0.0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	rotation = rotation + 60.0 * rl.GetFrameTime()

	-- Make the camera move to demonstrate the effect
	local cameraX = (math.sin(rl.GetTime()) * 50.0) - 10.0
	local cameraY = math.cos(rl.GetTime()) * 30.0

	screenSpaceCamera.target = rl.new("Vector2", cameraX, cameraY)

	-- Round worldSpace coordinates, keep decimals into screenSpace coordinates
	worldSpaceCamera.target.x = math.floor(screenSpaceCamera.target.x)
	screenSpaceCamera.target.x = screenSpaceCamera.target.x - worldSpaceCamera.target.x
	screenSpaceCamera.target.x = screenSpaceCamera.target.x * virtualRatio

	worldSpaceCamera.target.y = math.floor(screenSpaceCamera.target.y)
	screenSpaceCamera.target.y = screenSpaceCamera.target.y - worldSpaceCamera.target.y
	screenSpaceCamera.target.y = screenSpaceCamera.target.y * virtualRatio

	-- Draw
	rl.BeginTextureMode(target)
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode2D(worldSpaceCamera)
	rl.DrawRectanglePro(rec01, origin, rotation, rl.BLACK)
	rl.DrawRectanglePro(rec02, origin, -rotation, rl.RED)
	rl.DrawRectanglePro(rec03, origin, rotation + 45.0, rl.BLUE)
	rl.EndMode2D()
	rl.EndTextureMode()

	rl.BeginDrawing()
	rl.ClearBackground(rl.RED)

	rl.BeginMode2D(screenSpaceCamera)
	rl.DrawTexturePro(target.texture, sourceRec, destRec, origin, 0.0, rl.WHITE)
	rl.EndMode2D()

	rl.DrawText(string.format("Screen resolution: %ix%i", screenWidth, screenHeight), 10, 10, 20, rl.DARKBLUE)
	rl.DrawText(string.format("World resolution: %ix%i", virtualScreenWidth, virtualScreenHeight), 10, 40, 20, rl.DARKGREEN)
	rl.DrawFPS(rl.GetScreenWidth() - 95, 10)
	rl.EndDrawing()
end

-- De-Initialization
rl.UnloadRenderTexture(target)
rl.CloseWindow()
