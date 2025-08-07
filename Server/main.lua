local Server = require("lib/Server")
local server

function love.load(args)
	Server.load(args[1])
end

function love.update(dt)
	if not Server.game_start then
		Server.listen()
	else
		Server:update(dt)
	end
end

function love.draw() end
