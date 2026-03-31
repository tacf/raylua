-- raylib [shapes] example - math angle rotation

local screenWidth = 720
local screenHeight = 400

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - math angle rotation")
rl.SetTargetFPS(60)

local center = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0)
local lineLength = 150.0

local angles = { 0, 30, 60, 90 }
local fixedColors = { rl.GREEN, rl.ORANGE, rl.BLUE, rl.MAGENTA }

local totalAngle = 0.0

while not rl.WindowShouldClose() do
	totalAngle = totalAngle + 1.0
	if totalAngle >= 360.0 then totalAngle = totalAngle - 360.0 end

	rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)

		rl.DrawText("Fixed angles + rotating line", 10, 10, 20, rl.LIGHTGRAY)

		for i = 1, #angles do
			local rad = math.rad(angles[i])
			local endPos = rl.new("Vector2",
				center.x + math.cos(rad) * lineLength,
				center.y + math.sin(rad) * lineLength)

			rl.DrawLineEx(center, endPos, 5.0, fixedColors[i])

			local textPos = rl.new("Vector2",
				center.x + math.cos(rad) * (lineLength + 20),
				center.y + math.sin(rad) * (lineLength + 20))
			rl.DrawText(string.format("%d°", angles[i]), math.floor(textPos.x), math.floor(textPos.y), 20, fixedColors[i])
		end

		local animRad = math.rad(totalAngle)
		local animEnd = rl.new("Vector2",
			center.x + math.cos(animRad) * lineLength,
			center.y + math.sin(animRad) * lineLength)

		local animCol = rl.ColorFromHSV(totalAngle % 360.0, 0.8, 0.9)
		rl.DrawLineEx(center, animEnd, 5.0, animCol)

	rl.EndDrawing()
end

rl.CloseWindow()
