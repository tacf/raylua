local screenWidth = 800
local screenHeight = 450

rl.InitWindow(screenWidth, screenHeight, "raylib [models] example - tesseract view")

local camera = rl.new("Camera3D", {
	position = rl.new("Vector3", 4, 4, 4),
	target = rl.new("Vector3", 0, 0, 0),
	up = rl.new("Vector3", 0, 0, 1),
	fovy = 50,
	type = rl.CAMERA_PERSPECTIVE,
})

local tesseract = {
	{  1,  1,  1,  1 }, {  1,  1,  1, -1 },
	{  1,  1, -1,  1 }, {  1,  1, -1, -1 },
	{  1, -1,  1,  1 }, {  1, -1,  1, -1 },
	{  1, -1, -1,  1 }, {  1, -1, -1, -1 },
	{ -1,  1,  1,  1 }, { -1,  1,  1, -1 },
	{ -1,  1, -1,  1 }, { -1,  1, -1, -1 },
	{ -1, -1,  1,  1 }, { -1, -1,  1, -1 },
	{ -1, -1, -1,  1 }, { -1, -1, -1, -1 },
}

local rotation = 0.0
local DEG2RAD = math.pi / 180.0

rl.SetTargetFPS(60)

while not rl.WindowShouldClose() do
	rotation = DEG2RAD * 45.0 * rl.GetTime()

	local transformed = {}
	local wValues = {}

	for i = 1, 16 do
		local p = { tesseract[i][1], tesseract[i][2], tesseract[i][3], tesseract[i][4] }

		local cosR = math.cos(rotation)
		local sinR = math.sin(rotation)
		local newX = p[1] * cosR - p[4] * sinR
		local newW = p[1] * sinR + p[4] * cosR
		p[1] = newX
		p[4] = newW

		local c = 3.0 / (3.0 - p[4])
		transformed[i] = rl.new("Vector3", c * p[1], c * p[2], c * p[3])
		wValues[i] = p[4]
	end

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(camera)
	for i = 1, 16 do
		rl.DrawSphere(transformed[i], math.abs(wValues[i] * 0.1), rl.RED)

		for j = 1, 16 do
			local v1 = tesseract[i]
			local v2 = tesseract[j]
			local diff = 0
			if v1[1] == v2[1] then diff = diff + 1 end
			if v1[2] == v2[2] then diff = diff + 1 end
			if v1[3] == v2[3] then diff = diff + 1 end
			if v1[4] == v2[4] then diff = diff + 1 end

			if diff == 3 and i < j then
				rl.DrawLine3D(transformed[i], transformed[j], rl.MAROON)
			end
		end
	end
	rl.EndMode3D()

	rl.EndDrawing()
end

rl.CloseWindow()
