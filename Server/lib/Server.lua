-- game server (network + simulation)
-- receives client commands, and broadcasts results
local Server = {}
local socket = require("socket")
local json = require("lib/json")

local GolfBall = require("../classes/GolfBall")
local Obstacle = require("../classes/Obstacle")
local Goal = require("../classes/Goal")
local levels = require("../levels")

<<<<<<< HEAD
local NUM_BALLS = 16
local FIXED_DT = 1 / 60
=======
-- Game constants
local NUM_BALLS = 4          -- Balls per round
local FIXED_DT = 1 / 60      -- Physics tick (seconds)
>>>>>>> comments
local COLORS = {
	{ 1, 0, 0 },
	{ 0, 1, 0 },
	{ 0, 0, 1 },
	{ 1, 1, 0 },
}

-- Boot the TCP server on a given port 
function Server.load(port) -- load
	if not port or type(port) ~= "number" then
		error("Port number not specified properly")
		love.event.quit()
	end
	math.randomseed(os.time() + socket.gettime())
<<<<<<< HEAD
	Server.level_index = math.random(1, 1)
=======
    Server.level_index = math.random(1, 3)
>>>>>>> comments
	Server.clients = {}
	Server.client_count = 0
	Server.scores = {}
	Server.client_sockets = {}

    Server.tick = 0          -- global tick counter
    Server.accumulator = 0   -- accumulator for fixed-step integration

    Server.start_time = socket.gettime() -- used to auto-exit when no clients connect

    -- Bind to all interfaces ("*") so localhost or LAN can connect
    Server.instance = socket.bind("*", port)
	Server.instance:settimeout(0)
	print("Server started")
end

-- Accept new clients (up to 4) and process incoming messages once per frame
function Server.listen()
	Server.receive_data()
	if (not Server.clients or Server.client_count == 0) and socket.gettime() - Server.start_time > 5 then
		print("No clients")
		love.event.quit()
	end
	if not Server.clients or Server.client_count < 4 then
		local client = Server.instance:accept()
		if client then
			client:settimeout(0)
			local color = COLORS[1]
			table.remove(COLORS, 1)

			Server.client_count = Server.client_count + 1
			local clientObj = {
				id = math.random(10, 9999999999),
				player_num = Server.client_count,
				color = color,
				score = 0,
				socket = client,
			}
			Server.clients[clientObj.id] = clientObj
			table.insert(Server.client_sockets, client)
			table.insert(Server.scores, 0)

			client:send(json.encode({
				type = "id",
				data = { id = clientObj.id, color = clientObj.color, player_num = clientObj.player_num },
			}) .. "\n")
			print("New client connected! ID:", clientObj.id)

			-- If game already running, immediately send current setup/state to late joiner
			if Server.game_start and Server.golf_balls then
				Server.send_setup_to_client(clientObj)
			end
		end
	end
end

-- Advance the server simulation using a fixed timestep
function Server:update(dt)
	self.accumulator = self.accumulator + dt
	while self.accumulator >= FIXED_DT do
		self:fixed_update(FIXED_DT)
		self.accumulator = self.accumulator - FIXED_DT
		self.tick = self.tick + 1
	end
end

-- 1) Poll network; 2) Step physics; 3) Stop finished shots; 4) Handle goals;
-- 5) Occasionally snapshot and broadcast ball states
function Server:fixed_update(dt)
	if Server.client_count == 0 then
		love.event.quit()
	end
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
			self.scores[Server.clients[golf_ball.current_shooter_id].player_num] = self.scores
				[Server.clients[golf_ball.current_shooter_id].player_num] + 1
			Server.send_data_to_all_clients({
				type = "goal_reached",
				data = {
					ball_id = golf_ball.ball_id,
					scores = Server.scores,
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

-- Broadcast a snapshot of all ball transforms to clients
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
			scores = Server.scores,
			balls = ball_states,
		},
	})
end

-- Send a JSON message to all connected sockets; remove dead ones
function Server.send_data_to_all_clients(data)
	local jsonString = json.encode(data)
	--print("Sending data: " .. jsonString)
	for id, client in pairs(Server.clients) do
		local success, err = client.socket:send(jsonString .. "\n")
		if not success then
			client.socket:close()
			table.remove(Server.clients, id)
			table.remove(Server.client_sockets, client.player_num)
		end
	end
end

<<<<<<< HEAD
function Server.send_data_to_client(clientObj, data)
	local jsonString = json.encode(data)
	--print("Sending: " .. jsonString)
	local ok = clientObj.socket:send(jsonString .. "\n")
	if not ok then
		-- drop silently; removal handled elsewhere when detected
		return false
	end
	return true
end

function Server.send_setup_to_client(clientObj)
	if not Server.golf_balls then
		return
	end
	local client_balls_data = {}
	for _, ball in ipairs(Server.golf_balls) do
		table.insert(client_balls_data, {
			ball_id = ball.ball_id,
			x = ball.body:getX(),
			y = ball.body:getY(),
			scored = ball.scored,
		})
	end
	Server.send_data_to_client(clientObj, {
		type = "setup",
		data = { golf_balls = client_balls_data },
	})
end

=======
-- Poll sockets, parse 1-line JSON messages, and handle commands
>>>>>>> comments
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
					for id, clientObj in pairs(Server.clients) do
						if clientObj.player_num == i then
							table.remove(Server.clients, clientObj.id)
							break
						end
					end
				end
			end
			goto continue
		end
		local received_data = json.decode(temp_data)
		if received_data then
			print("Server received data from client:", temp_data)

			local data_type = received_data.type
			local data = received_data.data

<<<<<<< HEAD
			if data_type == "grab" then
				local golf_ball = Server.golf_balls[data.ball_id]
				golf_ball.current_shooter_id = data.client_id
				Server.send_data_to_all_clients({
					type = "grab",
					data = {
						ball_id = data.ball_id,
						color = data.color,
						client_id = data.client_id,
					},
				})
			end

=======
            -- Apply a shot and echo to everyone
>>>>>>> comments
			if data_type == "shoot" then
				local golf_ball = Server.golf_balls[data.ball_id]
				golf_ball:shoot(data.shooting_magnitude, data.shooting_angle)
				Server.send_data_to_all_clients({
					type = "shoot",
					data = {
						ball_id = data.ball_id,
						shooting_magnitude = data.shooting_magnitude,
						shooting_angle = data.shooting_angle,
					},
				})
			end

            -- Shutdown (first client acts as host here)
			if data_type == "shutdown" then
				local client_instance = Server.clients[received_data.id]
				if not client_instance then
					goto continue
				end
				if client_instance.player_num == 1 then
					Server.send_data_to_all_clients({ type = "shutdown", data = nil })
					love.event.quit()
				else
					client_instance.socket:send(json.encode({ type = "shutdown", data = nil }) .. "\n")
					print("Client disconnected: " .. client_instance.id)
					client_instance.socket:close()
					table.remove(Server.client_sockets, client_instance.player_num)
					table.remove(Server.clients, received_data.id)
					Server.client_count = Server.client_count - 1
				end
			end
<<<<<<< HEAD
			if data_type == "start" and Server.clients[received_data.id].player_num == 1 then
=======
            -- Start match (gated to first client)
			if data_type == "start" and received_data.id == Server.clients[1].id then
>>>>>>> comments
				Server.game_start = true
				Server.send_data_to_all_clients({ type = "start", data = { scores = Server.scores } })
				Server:new_world()
			end
			if data_type == "request_setup" then
				-- send current setup to requester if game is running
				for id, clientObj in pairs(Server.clients) do
					if clientObj.socket == client then
						Server.send_setup_to_client(clientObj)
						break
					end
				end
			end
		end
		::continue::
	end
end

-- Build a new round: choose level, spawn goals/balls/obstacles, send setup
function Server:new_world()
	local width = 1000
	local height = 600

	-- General setup
    self.points = {} -- score per client id
	for i, client in ipairs(self.clients) do
		self.points[client.id] = 0
	end
	self.game_world = love.physics.newWorld(0, 0, true)

	-- Extra level data
    local new_level_data = levels[Server.level_index] -- pick a level layout
	local balls_data = new_level_data.balls
	local goal_data = new_level_data.goal
	local obstacles_data = new_level_data.obstacles
	Server.level_index = (Server.level_index % 3) + 1

	-- Initialize game world data
	self.goal = Goal.new(self.game_world, goal_data.x, goal_data.y)
	self.golf_balls = {}
	self.num_golf_balls = NUM_BALLS
	self.obstacles = {}

	-- Initialize client data
	local client_level_data = {}
	client_level_data.goal_data = { x = goal_data.x, y = goal_data.y }
	client_level_data.balls_data = {}
	client_level_data.obstacles_data = {}

	-- Create balls
	for i = 1, NUM_BALLS do
		local spawn_index = ((i - 1) % 4) + 1
		local spawn_area = balls_data[spawn_index]

		local angle = math.random() * 2 * math.pi
		local dist = math.sqrt(math.random()) * spawn_area.radius
		local x = spawn_area.x + dist * math.cos(angle)
		local y = spawn_area.y + dist * math.sin(angle)

		table.insert(self.golf_balls, GolfBall.new(self.game_world, i, x, y))
		table.insert(client_level_data.balls_data, { ball_id = i, x = x, y = y })
	end

	-- Create obstacles
	table.insert(self.obstacles, Obstacle.new(self.game_world, 0, height / 2, 10, height))  -- Left wall
	table.insert(self.obstacles, Obstacle.new(self.game_world, width, height / 2, 10, height)) -- Right wall
	table.insert(self.obstacles, Obstacle.new(self.game_world, width / 2, 0, width, 10))    -- Top wall
	table.insert(self.obstacles, Obstacle.new(self.game_world, width / 2, height, width, 10)) -- Bottom wall

	for _, obstacle_data in ipairs(obstacles_data) do
		table.insert(
			self.obstacles,
			Obstacle.new(self.game_world, obstacle_data.x, obstacle_data.y, obstacle_data.width, obstacle_data.height)
		)
		table.insert(
			client_level_data.obstacles_data,
			{ x = obstacle_data.x, y = obstacle_data.y, width = obstacle_data.width, height = obstacle_data.height }
		)
	end

	Server.send_data_to_all_clients({
		type = "setup",
		data = {
			level_data = client_level_data,
		},
	})
end

return Server
