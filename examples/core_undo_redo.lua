-- raylib [core] example - undo redo

local MAX_UNDO_STATES = 26
local GRID_CELL_SIZE = 24
local MAX_GRID_CELLS_X = 30
local MAX_GRID_CELLS_Y = 13

local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - undo redo")

-- Undo/redo system variables
local currentUndoIndex = 0
local firstUndoIndex = 0
local lastUndoIndex = 0
local undoFrameCounter = 0
local undoInfoPos = rl.new("Vector2", 110, 400)

-- Init current player state
local player = {
	cell = { x = 10, y = 10 },
	color = rl.new("Color", 255, 0, 0, 255),
}

-- Init undo buffer to store MAX_UNDO_STATES states
local states = {}
for i = 0, MAX_UNDO_STATES - 1 do
	states[i] = {
		cell = { x = player.cell.x, y = player.cell.y },
		color = rl.new("Color", player.color.r, player.color.g, player.color.b, player.color.a),
	}
end

-- Grid variables
local gridPosition = rl.new("Vector2", 40, 60)

local function DrawUndoBuffer(position, firstIdx, lastIdx, currentIdx, slotSize)
	-- Draw index marks
	rl.DrawRectangle(math.floor(position.x) + 8 + slotSize * currentIdx, math.floor(position.y) - 10, 8, 8, rl.RED)
	rl.DrawRectangleLines(math.floor(position.x) + 2 + slotSize * firstIdx, math.floor(position.y) + 27, 8, 8, rl.BLACK)
	rl.DrawRectangle(math.floor(position.x) + 14 + slotSize * lastIdx, math.floor(position.y) + 27, 8, 8, rl.BLACK)

	-- Draw background gray slots
	for i = 0, MAX_UNDO_STATES - 1 do
		rl.DrawRectangle(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.LIGHTGRAY)
		rl.DrawRectangleLines(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.GRAY)
	end

	-- Draw occupied slots: firstIdx --> lastIdx
	if firstIdx <= lastIdx then
		for i = firstIdx, lastIdx do
			rl.DrawRectangle(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.SKYBLUE)
			rl.DrawRectangleLines(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.BLUE)
		end
	elseif lastIdx < firstIdx then
		for i = firstIdx, MAX_UNDO_STATES - 1 do
			rl.DrawRectangle(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.SKYBLUE)
			rl.DrawRectangleLines(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.BLUE)
		end
		for i = 0, lastIdx do
			rl.DrawRectangle(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.SKYBLUE)
			rl.DrawRectangleLines(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.BLUE)
		end
	end

	-- Draw occupied slots: firstIdx --> currentIdx
	if firstIdx < currentIdx then
		for i = firstIdx, currentIdx - 1 do
			rl.DrawRectangle(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.GREEN)
			rl.DrawRectangleLines(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.LIME)
		end
	elseif currentIdx < firstIdx then
		for i = firstIdx, MAX_UNDO_STATES - 1 do
			rl.DrawRectangle(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.GREEN)
			rl.DrawRectangleLines(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.LIME)
		end
		for i = 0, currentIdx - 1 do
			rl.DrawRectangle(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.GREEN)
			rl.DrawRectangleLines(math.floor(position.x) + slotSize * i, math.floor(position.y), slotSize, slotSize, rl.LIME)
		end
	end

	-- Draw current selected UNDO slot
	rl.DrawRectangle(math.floor(position.x) + slotSize * currentIdx, math.floor(position.y), slotSize, slotSize, rl.GOLD)
	rl.DrawRectangleLines(math.floor(position.x) + slotSize * currentIdx, math.floor(position.y), slotSize, slotSize, rl.ORANGE)
end

local function PlayerStateChanged(a, b)
	return a.cell.x ~= b.cell.x or a.cell.y ~= b.cell.y or
		a.color.r ~= b.color.r or a.color.g ~= b.color.g or a.color.b ~= b.color.b
end

rl.SetTargetFPS(60)

-- Main game loop
while not rl.WindowShouldClose() do
	-- Update
	-- Player movement logic
	if rl.IsKeyPressed(rl.KEY_RIGHT) then player.cell.x = player.cell.x + 1
	elseif rl.IsKeyPressed(rl.KEY_LEFT) then player.cell.x = player.cell.x - 1
	elseif rl.IsKeyPressed(rl.KEY_UP) then player.cell.y = player.cell.y - 1
	elseif rl.IsKeyPressed(rl.KEY_DOWN) then player.cell.y = player.cell.y + 1
	end

	-- Make sure player does not go out of bounds
	if player.cell.x < 0 then player.cell.x = 0
	elseif player.cell.x >= MAX_GRID_CELLS_X then player.cell.x = MAX_GRID_CELLS_X - 1
	end
	if player.cell.y < 0 then player.cell.y = 0
	elseif player.cell.y >= MAX_GRID_CELLS_Y then player.cell.y = MAX_GRID_CELLS_Y - 1
	end

	-- Player color change logic
	if rl.IsKeyPressed(rl.KEY_SPACE) then
		player.color = rl.new("Color",
			rl.GetRandomValue(20, 255),
			rl.GetRandomValue(20, 220),
			rl.GetRandomValue(20, 240),
			255)
	end

	-- Undo state change logic
	undoFrameCounter = undoFrameCounter + 1

	if undoFrameCounter >= 2 then
		if PlayerStateChanged(states[currentUndoIndex], player) then
			currentUndoIndex = currentUndoIndex + 1
			if currentUndoIndex >= MAX_UNDO_STATES then currentUndoIndex = 0 end
			if currentUndoIndex == firstUndoIndex then
				firstUndoIndex = firstUndoIndex + 1
			end
			if firstUndoIndex >= MAX_UNDO_STATES then firstUndoIndex = 0 end

			states[currentUndoIndex] = {
				cell = { x = player.cell.x, y = player.cell.y },
				color = rl.new("Color", player.color.r, player.color.g, player.color.b, player.color.a),
			}
			lastUndoIndex = currentUndoIndex
		end

		undoFrameCounter = 0
	end

	-- Recover previous state from buffer: CTRL+Z
	if rl.IsKeyDown(rl.KEY_LEFT_CONTROL) and rl.IsKeyPressed(rl.KEY_Z) then
		if currentUndoIndex ~= firstUndoIndex then
			currentUndoIndex = currentUndoIndex - 1
			if currentUndoIndex < 0 then currentUndoIndex = MAX_UNDO_STATES - 1 end

			if PlayerStateChanged(states[currentUndoIndex], player) then
				player.cell.x = states[currentUndoIndex].cell.x
				player.cell.y = states[currentUndoIndex].cell.y
				player.color = rl.new("Color",
					states[currentUndoIndex].color.r,
					states[currentUndoIndex].color.g,
					states[currentUndoIndex].color.b,
					states[currentUndoIndex].color.a)
			end
		end
	end

	-- Recover next state from buffer: CTRL+Y
	if rl.IsKeyDown(rl.KEY_LEFT_CONTROL) and rl.IsKeyPressed(rl.KEY_Y) then
		if currentUndoIndex ~= lastUndoIndex then
			local nextUndoIndex = currentUndoIndex + 1
			if nextUndoIndex >= MAX_UNDO_STATES then nextUndoIndex = 0 end

			if nextUndoIndex ~= firstUndoIndex then
				currentUndoIndex = nextUndoIndex

				if PlayerStateChanged(states[currentUndoIndex], player) then
					player.cell.x = states[currentUndoIndex].cell.x
					player.cell.y = states[currentUndoIndex].cell.y
					player.color = rl.new("Color",
						states[currentUndoIndex].color.r,
						states[currentUndoIndex].color.g,
						states[currentUndoIndex].color.b,
						states[currentUndoIndex].color.a)
				end
			end
		end
	end

	-- Draw
	rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		-- Draw controls info
		rl.DrawText("[ARROWS] MOVE PLAYER - [SPACE] CHANGE PLAYER COLOR", 40, 20, 20, rl.DARKGRAY)

		-- Draw player visited cells recorded by undo
		if lastUndoIndex > firstUndoIndex then
			for i = firstUndoIndex, currentUndoIndex - 1 do
				rl.DrawRectangle(
					gridPosition.x + states[i].cell.x * GRID_CELL_SIZE,
					gridPosition.y + states[i].cell.y * GRID_CELL_SIZE,
					GRID_CELL_SIZE, GRID_CELL_SIZE, rl.LIGHTGRAY)
			end
		elseif firstUndoIndex > lastUndoIndex then
			if currentUndoIndex < MAX_UNDO_STATES and currentUndoIndex > lastUndoIndex then
				for i = firstUndoIndex, currentUndoIndex - 1 do
					rl.DrawRectangle(
						gridPosition.x + states[i].cell.x * GRID_CELL_SIZE,
						gridPosition.y + states[i].cell.y * GRID_CELL_SIZE,
						GRID_CELL_SIZE, GRID_CELL_SIZE, rl.LIGHTGRAY)
				end
			else
				for i = firstUndoIndex, MAX_UNDO_STATES - 1 do
					rl.DrawRectangle(
						gridPosition.x + states[i].cell.x * GRID_CELL_SIZE,
						gridPosition.y + states[i].cell.y * GRID_CELL_SIZE,
						GRID_CELL_SIZE, GRID_CELL_SIZE, rl.LIGHTGRAY)
				end
				for i = 0, currentUndoIndex - 1 do
					rl.DrawRectangle(
						gridPosition.x + states[i].cell.x * GRID_CELL_SIZE,
						gridPosition.y + states[i].cell.y * GRID_CELL_SIZE,
						GRID_CELL_SIZE, GRID_CELL_SIZE, rl.LIGHTGRAY)
				end
			end
		end

		-- Draw game grid
		for y = 0, MAX_GRID_CELLS_Y do
			rl.DrawLine(
				math.floor(gridPosition.x),
				math.floor(gridPosition.y) + y * GRID_CELL_SIZE,
				math.floor(gridPosition.x) + MAX_GRID_CELLS_X * GRID_CELL_SIZE,
				math.floor(gridPosition.y) + y * GRID_CELL_SIZE, rl.GRAY)
		end
		for x = 0, MAX_GRID_CELLS_X do
			rl.DrawLine(
				math.floor(gridPosition.x) + x * GRID_CELL_SIZE,
				math.floor(gridPosition.y),
				math.floor(gridPosition.x) + x * GRID_CELL_SIZE,
				math.floor(gridPosition.y) + MAX_GRID_CELLS_Y * GRID_CELL_SIZE, rl.GRAY)
		end

		-- Draw player
		rl.DrawRectangle(
			math.floor(gridPosition.x) + player.cell.x * GRID_CELL_SIZE,
			math.floor(gridPosition.y) + player.cell.y * GRID_CELL_SIZE,
			GRID_CELL_SIZE + 1, GRID_CELL_SIZE + 1, player.color)

		-- Draw undo system buffer info
		rl.DrawText("UNDO STATES:", math.floor(undoInfoPos.x) - 85, math.floor(undoInfoPos.y) + 9, 10, rl.DARKGRAY)
		DrawUndoBuffer(undoInfoPos, firstUndoIndex, lastUndoIndex, currentUndoIndex, 24)

	rl.EndDrawing()
end

-- De-Initialization
rl.CloseWindow()
