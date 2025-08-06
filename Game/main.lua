local SM = require("lib/sceneManager")
local Client = require("lib/Client")
local socket = require("socket")

function love.load()
	print("Game Start!")
	love.physics.setMeter(30)
	SM.loadScene("MainMenu")
end

function love.update(dt)
	if Client and Client.socket_thread and Client.socket_thread:isRunning() then
		Client:update(dt)
	end
	SM.update(dt)
end

function love.draw()
	SM.draw()
end

function love.quit()
	if Client and Client.socket_thread then
		Client.send_data_to_server({ type = "shutdown", data = nil })
		while Client.socket_thread:isRunning() do
			socket.sleep(0.01)
		end
	end
end

function love.mousepressed(x, y, button)
	SM.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	SM.mousereleased(x, y, button)
end

function love.keypressed(key)
	SM.keypressed(key)
end
