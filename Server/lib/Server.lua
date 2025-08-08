local Server = {}
local socket = require("socket")
local json = require("lib/json")

local GolfBall = require("../classes/GolfBall")
local Obstacle = require("../classes/Obstacle")
local Goal = require("../classes/Goal")
-- local levels = require("../levels")

local NUM_BALLS = 4
local FIXED_DT = 1 / 60
local COLORS = {
	{ 1, 0, 0 },
	{ 0, 1, 0 },
	{ 0, 0, 1 },
	{ 1, 1, 0 },
}

function Server.load(port) -- load
	if not port or type(port) ~= "number" then
		error("Port number not specified properly")
		love.event.quit()
	end
	math.randomseed(os.time() + socket.gettime())
	-- Server.level_index = 1
	Server.clients = {}
	Server.client_sockets = {}

	Server.tick = 0
	Server.accumulator = 0

	Server.instance = socket.bind("127.0.0.1", port)
	Server.instance:settimeout(0)
	print("Server started")
end

function Server.listen()
	Server.receive_data()
	if not Server.clients or #Server.clients < 4 then
		local client = Server.instance:accept()
		if client then
			client:settimeout(0)
			local clientObj = {
				socket = client,
				id = math.random(10, 9999999999),
			}
			table.insert(Server.clients, clientObj)
			table.insert(Server.client_sockets, client)

			local color = COLORS[1]
			table.remove(COLORS, 1)
			client:send(json.encode({ type = "id", data = { id = clientObj.id, color = color } }) .. "\n")
			print("New client connected! ID:", clientObj.id)
		end
	end
end

function Server:update(dt)
	self.accumulator = self.accumulator + dt
	while self.accumulator >= FIXED_DT do
		self:fixed_update(FIXED_DT)
		self.accumulator = self.accumulator - FIXED_DT
		self.tick = self.tick + 1
	end
end

function Server:fixed_update(dt)
	Server.receive_data()
	self.game_world:update(dt)
	for _, golf_ball in ipairs(self.golf_balls) do
		if golf_ball.rolling and not golf_ball:isMoving() then
			golf_ball:finish_ball_shoot()
			Server.send_data_to_all_clients({
				type = "finish_shoot",
				data = {
					ball_id = golf_ball.ball_id,
					x = golf_ball.body:getX(),
					y = golf_ball.body:getY(),
				},
			})
		end
		if self.goal:check_reached(golf_ball.body) then
			self.golf_balls[golf_ball.ball_id].scored = true
			self.golf_balls[golf_ball.ball_id].body:setPosition(-50, -50) -- Move the ball off-screen
			self.num_golf_balls = self.num_golf_balls - 1
			if golf_ball.current_shooter_id >= 10 then
				self.points[golf_ball.current_shooter_id] = self.points[golf_ball.current_shooter_id] + 1
			end
			Server.send_data_to_all_clients({
				type = "goal_reached",
				data = {
					ball_id = golf_ball.ball_id,
					client_scored = golf_ball.current_shooter_id,
				},
			})
			if self.num_golf_balls <= 0 then
				self:new_world()
			end
		end
	end
	if self.tick % 4 == 0 then
		self.broadcast_state()
	end
end

function Server:new_world()
	local width = 1000
	local height = 600

	self.obstacles = {}
	self.points = {}
	for i, client in ipairs(self.clients) do
		self.points[client.id] = 0
	end
	self.game_world = love.physics.newWorld(0, 0, true)
	self.goal = Goal.new(self.game_world, width / 2, height / 2)
	self.golf_balls = {}
	self.num_golf_balls = NUM_BALLS

	local client_balls_data = {}

	for i = 1, NUM_BALLS do
		local x = math.random(width * 0.1, width * 0.9)
		local y = math.random(height * 0.1, height * 0.9)
		local new_golf_ball = GolfBall.new(self.game_world, i, x, y, true)
		table.insert(self.golf_balls, new_golf_ball)
		table.insert(client_balls_data, { ball_id = i, x = x, y = y })
	end
	self.obstacles = {}
	table.insert(self.obstacles, Obstacle.new(self.game_world, 0, height / 2, 10, height)) -- Left wall
	table.insert(self.obstacles, Obstacle.new(self.game_world, width, height / 2, 10, height)) -- Right wall
	table.insert(self.obstacles, Obstacle.new(self.game_world, width / 2, 0, width, 10)) -- Top wall
	table.insert(self.obstacles, Obstacle.new(self.game_world, width / 2, height, width, 10)) -- Bottom wall
	Server.send_data_to_all_clients({
		type = "setup",
		data = {
			golf_balls = client_balls_data,
		},
	})
end

function Server.broadcast_state()
	local ball_states = {}
	for i, ball in ipairs(Server.golf_balls) do
		table.insert(ball_states, {
			ball_id = ball.ball_id,
			x = ball.body:getX(),
			y = ball.body:getY(),
			vx = ball.body:getLinearVelocity(),
			vy = select(2, ball.body:getLinearVelocity()),
		})
	end
	Server.send_data_to_all_clients({
		type = "state_update",
		data = {
			tick = Server.tick,
			balls = ball_states,
		},
	})
end

function Server.send_data_to_all_clients(data)
	local jsonString = json.encode(data)
	--print("Sending data: " .. jsonString)
	for i, client in ipairs(Server.clients) do
		local success, err = client.socket:send(jsonString .. "\n")
		if not success then
			table.remove(Server.clients, i)
		end
	end
end

function Server.receive_data()
	local readable, _, _ = socket.select(Server.client_sockets, nil, 0)
	for i, client in ipairs(readable) do
		local temp_data, err = client:receive("*l")
		if not temp_data then
			if err ~= "timeout" then
				print("Client disconnected or lost:" .. err)
				for i, client_socket in ipairs(Server.client_sockets) do
					if client_socket == client then
						table.remove(Server.client_sockets, i)
						break
					end
				end
				for i, clientObj in ipairs(Server.clients) do
					if clientObj.socket == client then
						table.remove(Server.clients, i)
						break
					end
				end
			end
			goto continue
		end
		local received_data = json.decode(temp_data)
		if received_data then
			-- print("Server received data from client:", temp_data)

			local data_type = received_data.type
			local data = received_data.data

			if data_type == "shoot" then
				local golf_ball = Server.golf_balls[data.ball_id]
				golf_ball.current_shooter_id = received_data.client_id
				golf_ball:shoot(data.shooting_magnitude, data.shooting_angle)
				Server.send_data_to_all_clients({
					type = "shoot",
					data = {
						ball_id = data.ball_id,
						client_id = received_data.client_id,
						shooting_magnitude = data.shooting_magnitude,
						shooting_angle = data.shooting_angle,
						color = data.color,
					},
				})
			end

			if i == 1 and data_type == "shutdown" then
				Server.send_data_to_all_clients("exit")
				love.event.quit()
			end
			if i == 1 and data_type == "start" then
				Server.game_start = true
				Server.send_data_to_all_clients("start")
				Server:new_world()
			end
		end
		::continue::
	end
end

return Server
