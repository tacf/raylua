-- raylib [shapes] example - recursive tree

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - recursive tree")

local start = rl.new("Vector2", (screenWidth / 2.0) - 125.0, screenHeight)
local angle = 40.0
local thick = 1.0
local treeDepth = 10.0
local branchDecay = 0.66
local length = 120.0
local bezier = false

local function SliderBar(bx, by, bw, bh, label, value, minVal, maxVal)
	local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
	if rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
		value = minVal + (maxVal - minVal) * (mx - bx) / bw
	end
	value = math.max(minVal, math.min(maxVal, value))
	rl.DrawRectangle(bx, by, bw, bh, rl.LIGHTGRAY)
	local fillW = (value - minVal) / (maxVal - minVal) * bw
	rl.DrawRectangle(bx, by, fillW, bh, rl.RED)
	rl.DrawRectangleLines(bx, by, bw, bh, rl.DARKGRAY)
	rl.DrawText(string.format("%s: %s", label, string.format("%.2f", value)), bx, by - 16, 10, rl.DARKGRAY)
	return value
end

local function CheckBox(bx, by, size, label, checked)
	rl.DrawRectangle(bx, by, size, size, checked and rl.RED or rl.LIGHTGRAY)
	rl.DrawRectangleLines(bx, by, size, size, rl.DARKGRAY)
	rl.DrawText(label, bx + size + 4, by + 2, 10, rl.DARKGRAY)
	local mx, my = rl.GetMousePosition().x, rl.GetMousePosition().y
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) and mx >= bx and mx <= bx + size and my >= by and my <= by + size then
		return not checked
	end
	return checked
end

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	local theta = math.rad(angle)
	local maxBranches = math.floor(2 ^ math.floor(treeDepth))
	local branches = {}
	local count = 0

	local initialEnd = rl.new("Vector2", start.x + length * math.sin(0.0), start.y - length * math.cos(0.0))
	count = count + 1
	branches[count] = { start = start, ["end"] = initialEnd, angle = 0.0, length = length }

	local i = 1
	while i <= count do
		local branch = branches[i]
		if branch.length >= 2 then
			local nextLength = branch.length * branchDecay
			if count < maxBranches and nextLength >= 2 then
				local branchStart = branch["end"]

				local angle1 = branch.angle + theta
				local branchEnd1 = rl.new("Vector2",
					branchStart.x + nextLength * math.sin(angle1),
					branchStart.y - nextLength * math.cos(angle1))
				count = count + 1
				branches[count] = { start = branchStart, ["end"] = branchEnd1, angle = angle1, length = nextLength }

				local angle2 = branch.angle - theta
				local branchEnd2 = rl.new("Vector2",
					branchStart.x + nextLength * math.sin(angle2),
					branchStart.y - nextLength * math.cos(angle2))
				count = count + 1
				branches[count] = { start = branchStart, ["end"] = branchEnd2, angle = angle2, length = nextLength }
			end
		end
		i = i + 1
	end

	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		for i = 1, count do
			local branch = branches[i]
			if branch.length >= 2 then
				if bezier then
					rl.DrawLineBezier(branch.start, branch["end"], thick, rl.RED)
				else
					rl.DrawLineEx(branch.start, branch["end"], thick, rl.RED)
				end
			end
		end

		rl.DrawLine(580, 0, 580, rl.GetScreenHeight(), rl.new("Color", 218, 218, 218, 255))
		rl.DrawRectangle(580, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.new("Color", 232, 232, 232, 255))

		angle = SliderBar(640, 40, 120, 20, "Angle", angle, 0, 180)
		length = SliderBar(640, 70, 120, 20, "Length", length, 12.0, 240.0)
		branchDecay = SliderBar(640, 100, 120, 20, "Decay", branchDecay, 0.1, 0.78)
		treeDepth = SliderBar(640, 130, 120, 20, "Depth", treeDepth, 1.0, 10.0)
		thick = SliderBar(640, 160, 120, 20, "Thick", thick, 1, 8)
		bezier = CheckBox(640, 190, 20, "Bezier", bezier)

		rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.CloseWindow()
