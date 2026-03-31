local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - textured cube")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 0, 10, 10),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 1, 0),
	fovy = 45,
	type = rl.CAMERA_PERSPECTIVE,
})

local texture = rl.LoadTexture("raylib/examples/models/resources/cubicmap_atlas.png")

local function DrawCubeTexture(tex, position, width, height, length, color)
	local x = position.x
	local y = position.y
	local z = position.z

	rl.rlSetTexture(tex.id)

	rl.rlBegin(rl.RL_QUADS)
	rl.rlColor4ub(color.r, color.g, color.b, color.a)

	-- Front Face
	rl.rlNormal3f(0, 0, 1)
	rl.rlTexCoord2f(0, 0); rl.rlVertex3f(x - width/2, y - height/2, z + length/2)
	rl.rlTexCoord2f(1, 0); rl.rlVertex3f(x + width/2, y - height/2, z + length/2)
	rl.rlTexCoord2f(1, 1); rl.rlVertex3f(x + width/2, y + height/2, z + length/2)
	rl.rlTexCoord2f(0, 1); rl.rlVertex3f(x - width/2, y + height/2, z + length/2)

	-- Back Face
	rl.rlNormal3f(0, 0, -1)
	rl.rlTexCoord2f(1, 0); rl.rlVertex3f(x - width/2, y - height/2, z - length/2)
	rl.rlTexCoord2f(1, 1); rl.rlVertex3f(x - width/2, y + height/2, z - length/2)
	rl.rlTexCoord2f(0, 1); rl.rlVertex3f(x + width/2, y + height/2, z - length/2)
	rl.rlTexCoord2f(0, 0); rl.rlVertex3f(x + width/2, y - height/2, z - length/2)

	-- Top Face
	rl.rlNormal3f(0, 1, 0)
	rl.rlTexCoord2f(0, 1); rl.rlVertex3f(x - width/2, y + height/2, z - length/2)
	rl.rlTexCoord2f(0, 0); rl.rlVertex3f(x - width/2, y + height/2, z + length/2)
	rl.rlTexCoord2f(1, 0); rl.rlVertex3f(x + width/2, y + height/2, z + length/2)
	rl.rlTexCoord2f(1, 1); rl.rlVertex3f(x + width/2, y + height/2, z - length/2)

	-- Bottom Face
	rl.rlNormal3f(0, -1, 0)
	rl.rlTexCoord2f(1, 1); rl.rlVertex3f(x - width/2, y - height/2, z - length/2)
	rl.rlTexCoord2f(0, 1); rl.rlVertex3f(x + width/2, y - height/2, z - length/2)
	rl.rlTexCoord2f(0, 0); rl.rlVertex3f(x + width/2, y - height/2, z + length/2)
	rl.rlTexCoord2f(1, 0); rl.rlVertex3f(x - width/2, y - height/2, z + length/2)

	-- Right Face
	rl.rlNormal3f(1, 0, 0)
	rl.rlTexCoord2f(1, 0); rl.rlVertex3f(x + width/2, y - height/2, z - length/2)
	rl.rlTexCoord2f(1, 1); rl.rlVertex3f(x + width/2, y + height/2, z - length/2)
	rl.rlTexCoord2f(0, 1); rl.rlVertex3f(x + width/2, y + height/2, z + length/2)
	rl.rlTexCoord2f(0, 0); rl.rlVertex3f(x + width/2, y - height/2, z + length/2)

	-- Left Face
	rl.rlNormal3f(-1, 0, 0)
	rl.rlTexCoord2f(0, 0); rl.rlVertex3f(x - width/2, y - height/2, z - length/2)
	rl.rlTexCoord2f(1, 0); rl.rlVertex3f(x - width/2, y - height/2, z + length/2)
	rl.rlTexCoord2f(1, 1); rl.rlVertex3f(x - width/2, y + height/2, z + length/2)
	rl.rlTexCoord2f(0, 1); rl.rlVertex3f(x - width/2, y + height/2, z - length/2)

	rl.rlEnd()

	rl.rlSetTexture(0)
end

local function DrawCubeTextureRec(tex, source, position, width, height, length, color)
	local x = position.x
	local y = position.y
	local z = position.z
	local texWidth = tex.width
	local texHeight = tex.height

	rl.rlSetTexture(tex.id)

	rl.rlBegin(rl.RL_QUADS)
	rl.rlColor4ub(color.r, color.g, color.b, color.a)

	-- Front Face
	rl.rlNormal3f(0, 0, 1)
	rl.rlTexCoord2f(source.x / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x - width/2, y - height/2, z + length/2)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x + width/2, y - height/2, z + length/2)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, source.y / texHeight)
	rl.rlVertex3f(x + width/2, y + height/2, z + length/2)
	rl.rlTexCoord2f(source.x / texWidth, source.y / texHeight)
	rl.rlVertex3f(x - width/2, y + height/2, z + length/2)

	-- Back Face
	rl.rlNormal3f(0, 0, -1)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x - width/2, y - height/2, z - length/2)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, source.y / texHeight)
	rl.rlVertex3f(x - width/2, y + height/2, z - length/2)
	rl.rlTexCoord2f(source.x / texWidth, source.y / texHeight)
	rl.rlVertex3f(x + width/2, y + height/2, z - length/2)
	rl.rlTexCoord2f(source.x / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x + width/2, y - height/2, z - length/2)

	-- Top Face
	rl.rlNormal3f(0, 1, 0)
	rl.rlTexCoord2f(source.x / texWidth, source.y / texHeight)
	rl.rlVertex3f(x - width/2, y + height/2, z - length/2)
	rl.rlTexCoord2f(source.x / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x - width/2, y + height/2, z + length/2)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x + width/2, y + height/2, z + length/2)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, source.y / texHeight)
	rl.rlVertex3f(x + width/2, y + height/2, z - length/2)

	-- Bottom Face
	rl.rlNormal3f(0, -1, 0)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, source.y / texHeight)
	rl.rlVertex3f(x - width/2, y - height/2, z - length/2)
	rl.rlTexCoord2f(source.x / texWidth, source.y / texHeight)
	rl.rlVertex3f(x + width/2, y - height/2, z - length/2)
	rl.rlTexCoord2f(source.x / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x + width/2, y - height/2, z + length/2)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x - width/2, y - height/2, z + length/2)

	-- Right Face
	rl.rlNormal3f(1, 0, 0)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x + width/2, y - height/2, z - length/2)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, source.y / texHeight)
	rl.rlVertex3f(x + width/2, y + height/2, z - length/2)
	rl.rlTexCoord2f(source.x / texWidth, source.y / texHeight)
	rl.rlVertex3f(x + width/2, y + height/2, z + length/2)
	rl.rlTexCoord2f(source.x / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x + width/2, y - height/2, z + length/2)

	-- Left Face
	rl.rlNormal3f(-1, 0, 0)
	rl.rlTexCoord2f(source.x / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x - width/2, y - height/2, z - length/2)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, (source.y + source.height) / texHeight)
	rl.rlVertex3f(x - width/2, y - height/2, z + length/2)
	rl.rlTexCoord2f((source.x + source.width) / texWidth, source.y / texHeight)
	rl.rlVertex3f(x - width/2, y + height/2, z + length/2)
	rl.rlTexCoord2f(source.x / texWidth, source.y / texHeight)
	rl.rlVertex3f(x - width/2, y + height/2, z - length/2)

	rl.rlEnd()

	rl.rlSetTexture(0)
end

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)

	DrawCubeTexture(texture, rl.new("Vector3", -2, 2, 0), 2, 4, 2, rl.WHITE)

	DrawCubeTextureRec(texture,
		rl.new("Rectangle", 0, texture.height / 2.0, texture.width / 2.0, texture.height / 2.0),
		rl.new("Vector3", 2, 1, 0), 2, 2, 2, rl.WHITE)

	rl.DrawGrid(10, 1.0)

	rl.EndMode3D()

	rl.DrawFPS(10, 10)

	rl.EndDrawing()
end

rl.UnloadTexture(texture)
rl.CloseWindow()
