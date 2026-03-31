--[[

Example ported from oficial examples in raylib

source: https://github.com/raysan5/raylib/blob/master/examples/core/core_basic_window.c

]]

rl.SetConfigFlags(rl.FLAG_VSYNC_HINT)

rl.InitWindow(800, 450, "raylib [core] example - basic window")


while not rl.WindowShouldClose() do
  rl.BeginDrawing()

  rl.DrawFPS(10, 10)

  rl.ClearBackground(rl.RAYWHITE)
  rl.DrawTextEx(font, "Congrats! You created your first window!", rl.rlVertex2f(174, 200), 32, 0, rl.BLACK)

  rl.EndDrawing()
end

rl.CloseWindow()
