local MAX_BUILDINGS = 100

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera")

local player = rl.new("Rectangle", 400, 280, 40, 40)
local buildings = {}
local buildColors = {}

local spacing = 0

for i = 0, MAX_BUILDINGS - 1 do
	local width = rl.GetRandomValue(50, 200)
	local height = rl.GetRandomValue(100, 800)
	buildings[i] = rl.new("Rectangle", -6000 + spacing, screenHeight - 130 - height, width, height)
	spacing = spacing + width

	buildColors[i] = rl.new("Color",
		rl.GetRandomValue(200, 240),
		rl.GetRandomValue(200, 240),
		rl.GetRandomValue(200, 250),
		255)
end

local camera = rl.new("Camera2D", {
	offset = rl.new("Vector2", screenWidth / 2, screenHeight / 2),
	target = rl.new("Vector2", player.x + 20, player.y + 20),
	rotation = 0,
	zoom = 1,
})

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	-- Update
	if rl.IsKeyDown(rl.KEY_RIGHT) then
		player.x = player.x + 2
	elseif rl.IsKeyDown(rl.KEY_LEFT) then
		player.x = player.x - 2
	end

	camera.target = rl.new("Vector2", player.x + 20, player.y + 20)

	if rl.IsKeyDown(rl.KEY_A) then
		camera.rotation = camera.rotation - 1
	elseif rl.IsKeyDown(rl.KEY_S) then
		camera.rotation = camera.rotation + 1
	end

	if camera.rotation > 40 then camera.rotation = 40
	elseif camera.rotation < -40 then camera.rotation = -40
	end

	camera.zoom = math.exp(math.log(camera.zoom) + rl.GetMouseWheelMove() * 0.1)

	if camera.zoom > 3.0 then camera.zoom = 3.0
	elseif camera.zoom < 0.1 then camera.zoom = 0.1
	end

	if rl.IsKeyPressed(rl.KEY_R) then
		camera.zoom = 1.0
		camera.rotation = 0.0
	end

	-- Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode2D(camera)
	rl.DrawRectangle(-6000, 320, 13000, 8000, rl.DARKGRAY)

	for i = 0, MAX_BUILDINGS - 1 do
		rl.DrawRectangleRec(buildings[i], buildColors[i])
	end

	rl.DrawRectangleRec(player, rl.RED)

	rl.DrawLine(math.floor(camera.target.x), -screenHeight * 10, math.floor(camera.target.x), screenHeight * 10, rl.GREEN)
	rl.DrawLine(-screenWidth * 10, math.floor(camera.target.y), screenWidth * 10, math.floor(camera.target.y), rl.GREEN)

	rl.EndMode2D()

	rl.DrawText("SCREEN AREA", 640, 10, 20, rl.RED)

	rl.DrawRectangle(0, 0, screenWidth, 5, rl.RED)
	rl.DrawRectangle(0, 5, 5, screenHeight - 10, rl.RED)
	rl.DrawRectangle(screenWidth - 5, 5, 5, screenHeight - 10, rl.RED)
	rl.DrawRectangle(0, screenHeight - 5, screenWidth, 5, rl.RED)

	rl.DrawRectangle(10, 10, 250, 113, rl.Fade(rl.SKYBLUE, 0.5))
	rl.DrawRectangleLines(10, 10, 250, 113, rl.BLUE)

	rl.DrawText("Free 2D camera controls:", 20, 20, 10, rl.BLACK)
	rl.DrawText("- Right/Left to move player", 40, 40, 10, rl.DARKGRAY)
	rl.DrawText("- Mouse Wheel to Zoom in-out", 40, 60, 10, rl.DARKGRAY)
	rl.DrawText("- A / S to Rotate", 40, 80, 10, rl.DARKGRAY)
	rl.DrawText("- R to reset Zoom and Rotation", 40, 100, 10, rl.DARKGRAY)

	rl.EndDrawing()
end

rl.CloseWindow()
