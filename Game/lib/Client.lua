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

function Client.update(dt)
	Client.receive_data()
end

function Client.send_data_to_server(data)
	love.thread.getChannel("send_channel"):push(data)
end

function Client.receive_data()
	local receive_channel = love.thread.getChannel("receive_channel")
	local received_data = receive_channel:pop()
	while received_data do
		--print("Client received data:", json.encode(received_data))

		local data_type = received_data.type
		local data = received_data.data

		if data_type == "shutdown" then
			print("Exiting")
			Client.socket_thread:wait()
			love.event.quit()
		end

		if data_type == "start" then
			SM.loadScene("Game")
			return
		end

		if data_type == "id" then
			Client.client_id = data.id
			Client.color = data.color
			Client.player_num = data.player_num or 0
			print("Got client ID:", Client.client_id)
			-- Ask server for current setup in case the game already started
			Client.send_data_to_server({ type = "request_setup" })
		end

		if data_type == "setup" then
			SM.currentScene.new_world(data.level_data)
		end

		if data_type == "grab" then
			local golf_ball = SM.currentScene.golf_balls[data.ball_id]
			golf_ball:update_color(data.color)
			golf_ball.locked = Client.client_id ~= data.client_id
		end

		if data_type == "shoot" then
			local golf_ball = SM.currentScene.golf_balls[data.ball_id]
			golf_ball:shoot(data.shooting_magnitude, data.shooting_angle)
		end

		if data_type == "finish_shoot" then
			local golf_ball = SM.currentScene.golf_balls[data.ball_id]
			golf_ball.body:setPosition(data.x, data.y)
			golf_ball:finish_ball_shoot()
		end

		if data_type == "goal_reached" then
			SM.currentScene.golf_balls[data.ball_id].scored = true
			SM.currentScene.golf_balls[data.ball_id].body:setPosition(-50, -50) -- Move the ball off-screen
			-- Update scoreboard
			local cid = data.client_scored
			if cid then
				SM.currentScene.scores = SM.currentScene.scores or {}
				SM.currentScene.scores[cid] = (SM.currentScene.scores[cid] or 0) + 1
			end
		end

		if data_type == "state_update" then
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
