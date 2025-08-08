local Game = {
	game_world = nil,
	goal = nil,
	golf_balls = {},
	obstacles = {},
	current_ball_id = 0,
	-- scoreboard show/hide buttons
	scoreboard_buttons = {},
	is_scoreboard_visible = true,
}

local GolfBall = require("classes/GolfBall")
local Obstacle = require("classes/Obstacle")
local Goal = require("classes/Goal")
local Client = require("lib/Client")

-- scoreboard variables
local scoreboard_font = love.graphics.newFont("assets/dogicapixelbold.ttf", 15)

local scoreboard_posX = love.graphics.getWidth() - 200
local scoreboard_posY = 20
local scoreboard_width = 175
local scoreboard_height = 200
local button_width = 75
local button_height = 20

-- flag
local flag

function Game.load()
	Game.scoreboard_buttons = {
		show = {
			img = love.graphics.newImage("assets/img/showButton.png"),
			x = scoreboard_posX + (scoreboard_width / 2),
			y = scoreboard_posY + 10,
			width = button_width,
			height = button_height,
			action = Game.ShowScoreboard,
		},
		hide = {
			img = love.graphics.newImage("assets/img/hideButton.png"),
			x = scoreboard_posX + (scoreboard_width / 2),
			y = scoreboard_posY + scoreboard_height + 10,
			width = button_width,
			height = button_height,
			action = Game.HideScoreboard,
		},
	}

	flag = love.graphics.newImage("assets/img/flag.png")
	Game.ballCollideSfx = love.audio.newSource("sfx/bump.wav", "static")
	Game.ballHitSfx = love.audio.newSource("sfx/put.wav", "static")
end

function Game.update(dt)
	if not Game.game_world then
		return
	end

	Game.game_world:update(dt)

	if love.mouse.isDown(1) then
		for _, golf_ball in ipairs(Game.golf_balls) do
			golf_ball:aim(Game, love.mouse.getX(), love.mouse.getY())
		end
	end
end

function Game.draw()
	if not Game.game_world then
		return
	end

	Game.goal:draw()
	for _, obstacle in ipairs(Game.obstacles) do
		obstacle:draw()
	end
	for _, golf_ball in ipairs(Game.golf_balls) do
		golf_ball:display()
	end

	-- Scoreboard
	if Game.is_scoreboard_visible == true then
		Game.Scoreboard()
	end

	love.graphics.setColor(1, 1, 1)
	local button = Game.is_scoreboard_visible and Game.scoreboard_buttons.hide or Game.scoreboard_buttons.show
	love.graphics.draw(
		button.img,
		button.x,
		button.y,
		0,
		button.width / button.img:getWidth(),
		button.height / button.img:getHeight()
	)

	-- Flag
	local screen_w = love.graphics.getWidth()
	local screen_h = love.graphics.getHeight()
	local flag_w = flag:getWidth()
	local flag_h = flag:getHeight()
	love.graphics.draw(flag, (screen_w - flag_w) / 2 + 15, (screen_h - flag_h) / 2 - 50)
end

function Game.mousepressed(x, y, button)
	-- left click
	if button == 1 then
		local btn = Game.is_scoreboard_visible and Game.scoreboard_buttons.hide or Game.scoreboard_buttons.show
		local img_w = btn.img:getWidth()
		local img_h = btn.img:getHeight()

		if x > btn.x and x < btn.x + img_w and y > btn.y and y < btn.y + img_h then
			btn.action()
		end
	end
end

function Game.mousereleased(x, y, button)
	if button ~= 1 then
		return
	end

	Game.current_ball_id = 0
	for _, golf_ball in ipairs(Game.golf_balls) do
		if golf_ball.is_aiming and golf_ball.current_shooter_id == 0 and not golf_ball:isMoving() then
			Client.send_data_to_server({
				type = "shoot",
				client_id = Client.client_id,
				data = {
					ball_id = golf_ball.ball_id,
					shooting_magnitude = golf_ball.shooting_magnitude,
					shooting_angle = golf_ball.shooting_angle,
					color = Client.color,
				},
			})
		end
	end
end

local function beginContact(fixtureA, fixtureB, contact)
	print("Collision")
	local dataA = fixtureA:getUserData()
	local dataB = fixtureB:getUserData()

	Game.ballCollideSfx:stop() -- restart sound for rapid collisions
	Game.ballCollideSfx:play()
end

function Game.new_world(level_data)
	-- General setup
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	Game.game_world = love.physics.newWorld(0, 0, true)

	-- Extra level data components
	local goal_data = level_data.goal_data
	local balls_data = level_data.balls_data
	local obstacles_data = level_data.obstacles_data

	Game.goal = Goal.new(Game.game_world, goal_data.x, goal_data.y)

	-- Create balls
	Game.golf_balls = {}
	for i, ball_data in ipairs(balls_data) do
		table.insert(
			Game.golf_balls,
			GolfBall.new(Game.game_world, ball_data.ball_id, ball_data.x, ball_data.y, Game.ballHitSfx)
		)
	end

	-- Create obstacles
	Game.obstacles = {}
	table.insert(Game.obstacles, Obstacle.new(Game.game_world, 0, height / 2, 10, height)) -- Left wall
	table.insert(Game.obstacles, Obstacle.new(Game.game_world, width, height / 2, 10, height)) -- Right wall
	table.insert(Game.obstacles, Obstacle.new(Game.game_world, width / 2, 0, width, 10)) -- Top wall
	table.insert(Game.obstacles, Obstacle.new(Game.game_world, width / 2, height, width, 10)) -- Bottom wall

	for _, obstacle_data in ipairs(obstacles_data) do
		table.insert(
			Game.obstacles,
			Obstacle.new(Game.game_world, obstacle_data.x, obstacle_data.y, obstacle_data.width, obstacle_data.height)
		)
	end
	Game.game_world:setCallbacks(beginContact, nil, nil, nil)
end

------------------------------------------------------------------------------------
-- scoreboard function
function Game.Scoreboard()
	love.graphics.setFont(scoreboard_font)

	-- black background
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", scoreboard_posX, scoreboard_posY, scoreboard_width, scoreboard_height, 5, 5)

	-- scoreboard text
	love.graphics.setColor(255, 255, 255) -- Sets the drawing color to red
	love.graphics.rectangle("line", scoreboard_posX, scoreboard_posY, scoreboard_width, scoreboard_height, 5, 5)

	love.graphics.print("SCOREBOARD", scoreboard_posX + 10, 30)

	for i = 1, 4 do
		local padding = 20
		local next_height = padding + 40 * i
		love.graphics.print("Client", scoreboard_posX + 10, next_height)
		love.graphics.print(":", scoreboard_posX + 110, next_height)

		love.graphics.print(i, scoreboard_posX + 95, next_height)
		-- TODO: print the scores
		love.graphics.print("0", scoreboard_posX + 120, next_height)
	end
end

------------------------------------------------------------------------------------
-- show the scoreboard
function Game.ShowScoreboard()
	if Game.is_scoreboard_visible == false then
		Game.is_scoreboard_visible = true
	end
end

-- hide the scoreboard
function Game.HideScoreboard()
	Game.is_scoreboard_visible = false
end

return Game
