-- raylib [core] example - monitor detector

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - monitor detector")

local currentMonitorIndex = rl.GetCurrentMonitor()
local monitorCount = 0

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	local maxWidth = 1
	local maxHeight = 1
	local monitorOffsetX = 0

	-- Rebuild monitors array every frame
	monitorCount = rl.GetMonitorCount()
	local monitors = {}

	for i = 0, monitorCount - 1 do
		local pos = rl.GetMonitorPosition(i)
		monitors[i] = {
			position = pos,
			name = rl.GetMonitorName(i),
			width = rl.GetMonitorWidth(i),
			height = rl.GetMonitorHeight(i),
			physicalWidth = rl.GetMonitorPhysicalWidth(i),
			physicalHeight = rl.GetMonitorPhysicalHeight(i),
			refreshRate = rl.GetMonitorRefreshRate(i),
		}

		if monitors[i].position.x < monitorOffsetX then
			monitorOffsetX = -monitors[i].position.x
		end

		local w = monitors[i].position.x + monitors[i].width
		local h = monitors[i].position.y + monitors[i].height

		if maxWidth < w then maxWidth = w end
		if maxHeight < h then maxHeight = h end
	end

	if rl.IsKeyPressed(rl.KEY_ENTER) and monitorCount > 1 then
		currentMonitorIndex = currentMonitorIndex + 1
		if currentMonitorIndex == monitorCount then currentMonitorIndex = 0 end
		rl.SetWindowMonitor(currentMonitorIndex)
	else
		currentMonitorIndex = rl.GetCurrentMonitor()
	end

	local monitorScale = 0.6

	if maxHeight > (maxWidth + monitorOffsetX) then
		monitorScale = monitorScale * (screenHeight / maxHeight)
	else
		monitorScale = monitorScale * (screenWidth / (maxWidth + monitorOffsetX))
	end

	-- Draw
	rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawText("Press [Enter] to move window to next monitor available", 20, 20, 20, rl.DARKGRAY)

		rl.DrawRectangleLines(20, 60, screenWidth - 40, screenHeight - 100, rl.DARKGRAY)

		-- Draw Monitor Rectangles with information inside
		for i = 0, monitorCount - 1 do
			local rec = rl.new("Rectangle",
				(monitors[i].position.x + monitorOffsetX) * monitorScale + 140,
				monitors[i].position.y * monitorScale + 80,
				monitors[i].width * monitorScale,
				monitors[i].height * monitorScale
			)

			rl.DrawText(string.format("[%d] %s", i, monitors[i].name),
				math.floor(rec.x) + 10,
				math.floor(rec.y) + math.floor(100 * monitorScale),
				math.floor(120 * monitorScale), rl.BLUE)

			rl.DrawText(
				string.format("Resolution: [%dpx x %dpx]\nRefreshRate: [%dhz]\nPhysical Size: [%dmm x %dmm]\nPosition: %3.0f x %3.0f",
					monitors[i].width,
					monitors[i].height,
					monitors[i].refreshRate,
					monitors[i].physicalWidth,
					monitors[i].physicalHeight,
					monitors[i].position.x,
					monitors[i].position.y
				),
				math.floor(rec.x) + 10,
				math.floor(rec.y) + math.floor(200 * monitorScale),
				math.floor(120 * monitorScale), rl.DARKGRAY)

			-- Highlight current monitor
			if i == currentMonitorIndex then
				rl.DrawRectangleLinesEx(rec, 5, rl.RED)
				local windowPos = rl.GetWindowPosition()
				local windowPosition = rl.new("Vector2",
					(windowPos.x + monitorOffsetX) * monitorScale + 140,
					windowPos.y * monitorScale + 80)

				rl.DrawRectangleV(windowPosition,
					rl.new("Vector2", screenWidth * monitorScale, screenHeight * monitorScale),
					rl.Fade(rl.GREEN, 0.5))
			else
				rl.DrawRectangleLinesEx(rec, 5, rl.GRAY)
			end
		end

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
