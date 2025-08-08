local Client = {
	client_id = 1,
	receive_thread = nil,
	socket = nil,
	color = { 0.5, 0.5, 0.5 },
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
	if received_data == "exit" then
		love.event.quit()
	elseif received_data == "start" then
		SM.loadScene("Game")
		return
	end
	while received_data do
		local data_type = received_data.type
		local data = received_data.data
		--print("Client received data:", received_data)

		if data_type == "id" then
			Client.client_id = data.id
			Client.color = data.color
		end

		if data_type == "setup" then
			SM.currentScene.golf_balls = {}
			for _, golf_ball_data in ipairs(data.golf_balls) do
				local golf_ball =
					GolfBall.new(SM.currentScene.game_world, golf_ball_data.ball_id, golf_ball_data.x, golf_ball_data.y)
				table.insert(SM.currentScene.golf_balls, golf_ball)
			end
		end

		if data_type == "shoot" then
			local golf_ball = SM.currentScene.golf_balls[data.ball_id]
			golf_ball.current_shooter_id = data.client_id
			golf_ball:update_color(data.color)
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
