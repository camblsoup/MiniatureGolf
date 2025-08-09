-- Client networking: runs a socket thread and applies server messages
local Client = {
	client_id = 0,
	player_num = 0,
	receive_thread = nil,
	socket = nil,
	color = { 1, 1, 1 },
}

local GolfBall = require("classes/GolfBall")
local SM = require("lib/sceneManager")
local socket = require("socket")
local json = require("lib/json")

local server = nil

-- Start socket thread; wait for connection status

function Client.load(host, port)
	Client.socket_thread = love.thread.newThread("client_socket_thread.lua")
	Client.socket_thread:start(host, port)
	local connection_status = love.thread.getChannel("send_channel"):demand()
	if connection_status == "connected" then
		return true
	else
		return false, connection_status
	end
end

-- Poll incoming messages once per frame
function Client.update(dt)
	Client.receive_data()
end

-- Queue an outgoing message for the socket thread
function Client.send_data_to_server(data)
	love.thread.getChannel("send_channel"):push(data)
end

-- Handle messages from the network thread and update the scene
function Client.receive_data()
	local receive_channel = love.thread.getChannel("receive_channel")
	local received_data = receive_channel:pop()
	while received_data do
		--print("Client received data:", json.encode(received_data))

		local data_type = received_data.type
		local data = received_data.data

		-- Quit
		if data_type == "shutdown" then
			print("Exiting")
			Client.socket_thread:wait()
			love.event.quit()
		end

		-- Switch to Game scene
		if data_type == "start" then
			SM.loadScene("Game")
			SM.currentScene.scores = data.scores
			return
		end

		-- Save our id and color
		if data_type == "id" then
			Client.client_id = data.id
			Client.color = data.color
			Client.player_num = data.player_num or 0
			print("Got client ID:", Client.client_id)
			-- Ask server for current setup in case the game already started
			Client.send_data_to_server({ type = "request_setup" })
		end

		-- Build the world from server data
		if data_type == "setup" then
			SM.currentScene.new_world(data.level_data)
		end

		-- Apply shot
		if data_type == "shoot" then
			local golf_ball = SM.currentScene.golf_balls[data.ball_id]
			golf_ball:shoot(data.shooting_magnitude, data.shooting_angle)
		end

		-- Stop ball and snap to server position
		if data_type == "finish_shoot" then
			local golf_ball = SM.currentScene.golf_balls[data.ball_id]
			golf_ball.body:setPosition(data.x, data.y)
			golf_ball:finish_ball_shoot()
		end

		-- Mark scored and hide the ball
		if data_type == "goal_reached" then
			SM.currentScene.golf_balls[data.ball_id].scored = true
			SM.currentScene.golf_balls[data.ball_id].body:setPosition(-50, -50) -- Move the ball off-screen
			-- Update scoreboard
			SM.currentScene.scores = data.scores
		end

		-- Sync positions/velocities
		if data_type == "state_update" then
			SM.currentScene.scores = data.scores
			local ball_states = data.balls
			for i, ball_data in ipairs(ball_states) do
				local golf_ball = SM.currentScene.golf_balls[i].body
				golf_ball:setX(ball_data.x)
				golf_ball:setY(ball_data.y)
				golf_ball:setLinearVelocity(ball_data.vx, ball_data.vy)
			end
		end

		received_data = receive_channel:pop()
	end
end

return Client
