rl.InitWindow(800, 450, "raylib [text] example - format text")

local score = 100020
local hiscore = 200450
local lives = 5

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawText(string.format("Score: %08i", score), 200, 80, 20, rl.RED)
		rl.DrawText(string.format("HiScore: %08i", hiscore), 200, 120, 20, rl.GREEN)
		rl.DrawText(string.format("Lives: %02i", lives), 200, 160, 40, rl.BLUE)
		rl.DrawText(string.format("Elapsed Time: %02.02f ms", rl.GetFrameTime() * 1000), 200, 220, 20, rl.BLACK)
	rl.EndDrawing()
end

rl.CloseWindow()