-- raylib [shapes] example - vector angle

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - vector angle")

local v0 = rl.new("Vector2", screenWidth / 2.0, screenHeight / 2.0)
local v1 = rl.new("Vector2", v0.x + 100.0, v0.y + 80.0)
local v2 = rl.new("Vector2", 0, 0)

local angle = 0.0
local angleMode = 0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	local startangle = 0.0

	if angleMode == 0 then startangle = -rl.Vector2LineAngle(v0, v1) * rl.RAD2DEG end
	if angleMode == 1 then startangle = 0.0 end

	v2 = rl.GetMousePosition()

	if rl.IsKeyPressed(rl.KEY_SPACE) then angleMode = 1 - angleMode end

	if angleMode == 0 and rl.IsMouseButtonDown(rl.MOUSE_BUTTON_RIGHT) then v1 = rl.GetMousePosition() end

	if angleMode == 0 then
		local v1Sub = rl.new("Vector2", v1.x - v0.x, v1.y - v0.y)
		local v2Sub = rl.new("Vector2", v2.x - v0.x, v2.y - v0.y)
		local v1Normal = rl.Vector2Normalize(v1Sub)
		local v2Normal = rl.Vector2Normalize(v2Sub)
		angle = rl.Vector2Angle(v1Normal, v2Normal) * rl.RAD2DEG
	elseif angleMode == 1 then
		angle = rl.Vector2LineAngle(v0, v2) * rl.RAD2DEG
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		if angleMode == 0 then
			rl.DrawText("MODE 0: Angle between V1 and V2", 10, 10, 20, rl.BLACK)
			rl.DrawText("Right Click to Move V2", 10, 30, 20, rl.DARKGRAY)

			rl.DrawLineEx(v0, v1, 2.0, rl.BLACK)
			rl.DrawLineEx(v0, v2, 2.0, rl.RED)

			rl.DrawCircleSector(v0, 40.0, startangle, startangle + angle, 32, rl.Fade(rl.GREEN, 0.6))
		elseif angleMode == 1 then
			rl.DrawText("MODE 1: Angle formed by line V1 to V2", 10, 10, 20, rl.BLACK)

			rl.DrawLine(0, screenHeight / 2, screenWidth, screenHeight / 2, rl.LIGHTGRAY)
			rl.DrawLineEx(v0, v2, 2.0, rl.RED)

			rl.DrawCircleSector(v0, 40.0, startangle, startangle - angle, 32, rl.Fade(rl.GREEN, 0.6))
		end

		rl.DrawText("v0", v0.x, v0.y, 10, rl.DARKGRAY)

		if angleMode == 0 and (v0.y - v1.y) > 0.0 then
			rl.DrawText("v1", v1.x, v1.y - 10, 10, rl.DARKGRAY)
		elseif angleMode == 0 and (v0.y - v1.y) < 0.0 then
			rl.DrawText("v1", v1.x, v1.y, 10, rl.DARKGRAY)
		end

		if angleMode == 1 then rl.DrawText("v1", v0.x + 40, v0.y, 10, rl.DARKGRAY) end

		rl.DrawText("v2", v2.x - 10, v2.y - 10, 10, rl.DARKGRAY)

		rl.DrawText("Press SPACE to change MODE", 460, 10, 20, rl.DARKGRAY)
		rl.DrawText(string.format("ANGLE: %2.2f", angle), 10, 70, 20, rl.LIME)
	rl.EndDrawing()
end

rl.CloseWindow()
