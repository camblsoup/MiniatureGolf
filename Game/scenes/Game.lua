local Game = {
	game_world = nil,
	-- obstacles_data = {},
	obstacles = {},
	goal = nil,
	golf_balls = {},
	current_ball_id = 0,
}

local GolfBall = require("classes/GolfBall")
local Obstacle = require("classes/Obstacle")
local Goal = require("classes/Goal")
local Client = require("lib/Client")

function Game.load()
	Game.new_world()
end

function Game.update(dt)
	Game.game_world:update(dt)

	if love.mouse.isDown(1) then
		for _, golf_ball in ipairs(Game.golf_balls) do
			golf_ball:aim(Game, love.mouse.getX(), love.mouse.getY())
		end
	end
end

function Game.draw()
	Game.goal:draw()
	for _, obstacle in ipairs(Game.obstacles) do
		obstacle:draw()
	end
	for _, golf_ball in ipairs(Game.golf_balls) do
		golf_ball:display()
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
				},
			})
		end
	end
end

function Game.new_world()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	Game.game_world = love.physics.newWorld(0, 0, true)
	Game.goal = Goal.new(Game.game_world, width / 2, height / 2)
	Game.obstacles = {}
	table.insert(Game.obstacles, Obstacle.new(Game.game_world, 0, height / 2, 10, height)) -- Left wall
	table.insert(Game.obstacles, Obstacle.new(Game.game_world, width, height / 2, 10, height)) -- Right wall
	table.insert(Game.obstacles, Obstacle.new(Game.game_world, width / 2, 0, width, 10)) -- Top wall
	table.insert(Game.obstacles, Obstacle.new(Game.game_world, width / 2, height, width, 10)) -- Bottom wall
end

-- function Client.generate_level()
--     local screen_width = love.graphics.getWidth()
--     local screen_height = love.graphics.getHeight()

--     Client.game_world = love.physics.newWorld(0, 0, true)
--     Client.obstacles_data = server.obstacles_data

--     local golf_ball_data = Client.obstacles_data[1]
--     local goal_data = Client.obstacles_data[2]
--     Client.golf_ball = GolfBall.new(Client.game_world, screen_width * golf_ball_data.x, screen_height * golf_ball_data.y, 10)
--     Client.goal = Goal.new(Client.game_world, screen_width * goal_data.x, screen_height * goal_data.y)

--     Client.obstacles = {}
--     local screen_width = love.graphics.getWidth()
--     local screen_height = love.graphics.getHeight()
--     for i = 3, #Client.obstacles_data do
--         local obstacle_data = Client.obstacles_data[i]
--         table.insert(Client.obstacles, Obstacle.new(Client.game_world, screen_width * obstacle_data.x, screen_height * obstacle_data.y, screen_width * obstacle_data.width, screen_height * obstacle_data.height))
--     end
-- end

return Game
