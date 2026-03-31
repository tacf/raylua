local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - clipboard image")
rl.SetTargetFPS(60)

local MAX_TEXTURE_COLLECTION = 20

local collection = {}
for i = 1, MAX_TEXTURE_COLLECTION do
	collection[i] = { texture = nil, position = { x = 0, y = 0 } }
end

local currentCollectionIndex = 1

while not rl.WindowShouldClose() do
	if rl.IsKeyPressed(rl.KEY_R) then
		for i = 1, MAX_TEXTURE_COLLECTION do
			if collection[i].texture and collection[i].texture.id > 0 then
				rl.UnloadTexture(collection[i].texture)
			end
		end
		currentCollectionIndex = 1
	end

	if rl.IsKeyDown(rl.KEY_LEFT_CONTROL) and rl.IsKeyPressed(rl.KEY_V) and currentCollectionIndex <= MAX_TEXTURE_COLLECTION then
		local clipboardImage = rl.GetClipboardImage()
		if clipboardImage.id ~= 0 then
			collection[currentCollectionIndex].texture = rl.LoadTextureFromImage(clipboardImage)
			local mouse = rl.GetMousePosition()
			collection[currentCollectionIndex].position.x = mouse.x
			collection[currentCollectionIndex].position.y = mouse.y
			currentCollectionIndex = currentCollectionIndex + 1
			rl.UnloadImage(clipboardImage)
		else
			rl.TraceLog(rl.LOG_INFO, "IMAGE: Could not retrieve image from clipboard")
		end
	end

	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	for i = 1, currentCollectionIndex - 1 do
		if collection[i].texture and collection[i].texture.id > 0 then
			rl.DrawTexturePro(collection[i].texture,
				rl.new("Rectangle", 0, 0, collection[i].texture.width, collection[i].texture.height),
				rl.new("Rectangle", collection[i].position.x, collection[i].position.y, collection[i].texture.width, collection[i].texture.height),
				rl.new("Vector2", collection[i].texture.width * 0.5, collection[i].texture.height * 0.5),
				0.0, rl.WHITE)
		end
	end

	rl.DrawRectangle(0, 0, screenWidth, 40, rl.BLACK)
	rl.DrawText("Clipboard Image - Ctrl+V to Paste and R to Reset ", 120, 10, 20, rl.LIGHTGRAY)

	rl.EndDrawing()
end

for i = 1, MAX_TEXTURE_COLLECTION do
	if collection[i].texture and collection[i].texture.id > 0 then
		rl.UnloadTexture(collection[i].texture)
	end
end

rl.CloseWindow()