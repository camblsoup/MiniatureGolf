local Server = require("lib/Server")
local server

function love.load()
	Server.load()
end

function love.update(dt)
	if not Server.game_start then
		Server.listen()
	else
		Server:update(dt)
	end
end

function love.draw() end
