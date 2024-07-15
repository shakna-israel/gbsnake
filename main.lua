fade(1)

do
	local std_tostring = tostring
	tostring = function(i)
		 if i == 0 then
			return "0"
		 elseif i < 0 then
			return "-" .. tostring(-i)
		 else
			local str = ""
			while i > 0 do
				local digit = i % 10
				str = std_tostring(digit) .. str
				i = math.floor(i / 10)
			end
			return str
		 end
	end
end

local OVERLAY = 0
local TILE_1 = 1
local TILE_0 = 2
local BACKGROUND = 3
local SPRITE = 4

txtr(OVERLAY, "overlay/overlay.bmp")
--txtr(SPRITE, "test.bmp")
--txtr(TILE_0, "tiles/tilesheet.bmp")
--txtr(BACKGROUND, "sprites/spritesheet.bmp")

function draw_img(layer, x, y, w, h)
	local t = 0
	for yy = 0, h - 1 do
		for xx = 0, w - 1 do
			tile(layer, x + xx, y + yy, t)
			t = t + 1
		end
	end
end

--draw_img(1, 0, 2, 30, 14)

local BTN_A = 0
local BTN_B = 1
local BTN_START = 2
local BTN_SELECT = 3
local BTN_LEFT = 4
local BTN_RIGHT = 5
local BTN_UP = 6
local BTN_DOWN = 7
local BTN_BUMPLEFT = 8
local BTN_BUMPRIGHT = 9

local DIR_UP = 0
local DIR_DOWN = 1
local DIR_LEFT = 2
local DIR_RIGHT = 3
local direction = DIR_UP

local screen = {29, 19}
local player = {
	math.floor((screen[1] / 2) + 0.5),
	math.floor((screen[2] / 2) + 0.5)
}
local tail = {}

for x=0, screen[1] do
	for y=0, screen[2] do
		print(" ", x, y)
	end
end
fade(0)

local bonus = false
local game_over = false
local score = 0
while true do
	if btn(BTN_START) or btn(BTN_SELECT) then
		player = {
			math.floor((screen[1] / 2) + 0.5),
			math.floor((screen[2] / 2) + 0.5) - 1
		}
		for x=0, screen[1] do
			for y=0, screen[2] do
				print(" ", x, y)
			end
		end
		tail = {}
		game_over = false
		score = 0
		direction = DIR_UP
		bonus = false
	end

	if game_over == true then
		clear()
		display()
	else
		-- update logic here:
		if btn(BTN_RIGHT) or btn(BTN_BUMPRIGHT) then
			if direction == DIR_UP then
				direction = DIR_LEFT
			elseif direction == DIR_DOWN then
				direction = DIR_RIGHT
			elseif direction == DIR_LEFT then
				direction = DIR_DOWN
			elseif direction == DIR_RIGHT then
				direction = DIR_UP
			end
		elseif btn(BTN_LEFT) or btn(BTN_BUMPLEFT) then
			if direction == DIR_UP then
				direction = DIR_RIGHT
			elseif direction == DIR_DOWN then
				direction = DIR_LEFT
			elseif direction == DIR_LEFT then
				direction = DIR_UP
			elseif direction == DIR_RIGHT then
				direction = DIR_DOWN
			end
		end

		if direction == DIR_UP then
			player[2] = player[2] + 1
		elseif direction == DIR_DOWN then
			player[2] = player[2] - 1
		elseif direction == DIR_LEFT then
			player[1] = player[1] - 1
		elseif direction == DIR_RIGHT then
			player[1] = player[1] + 1
		end

		if player[1] > screen[1] then
			player[1] = 0
		elseif player[1] < 0 then
			player[1] = screen[1]
		end
		if player[2] > screen[2] - 1 then
			player[2] = 0
		elseif player[2] < 0 then
			player[2] = screen[2]
		end

		print("#", player[1], player[2])
		print(tostring(score), 2, screen[2])

		if #tail > 0 then
			for i=1, #tail do
				if tail[i][1] == player[1] and tail[i][2] == player[2] then
					game_over = true
					print("GAME OVER", 2, 2)
				end
			end
		end
		if bonus and bonus[1] == player[1] and bonus[2] == player[2] then
			print("#", bonus[1], bonus[2])
			for i=1, 10 do
				if #tail > 0 then
					local item = table.remove(tail, 1)
					print(" ", item[1], item[2])
				end
			end
			score = score + 10
			bonus = false
		end
		if not bonus then
			bonus = {math.random(1, screen[1]), math.random(1, screen[2])}
			for i=1, #tail do
				if bonus then
					if tail[i][1] == bonus[1] and tail[i][2] == bonus[2] then
						bonus = false
						break
					end
				end
			end
			if bonus then
				print("@", bonus[1], bonus[2])
			end
		end

		-- Do a maximum tail length...
		tail[#tail + 1] = {player[1], player[2]}
		if #tail % 5 == 0 then
			score = score + 1
		end
		if #tail > 3 and #tail > math.floor((score / 5) + 0.5) then
			print(" ", tail[1][1], tail[1][2])
			table.remove(tail, 1)
		end

		clear()

		-- graphics updates here:
		display()

		sleep(10)
	end
end
