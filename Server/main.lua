local Server = require("lib/Server")
local server

function love.load(args)
	-- Read the port from the first command-line argument and boot the server.
	-- Server.load() will bind the TCP socket and set the server to non-blocking.
	Server.load(tonumber(args[1]))
end

function love.update(dt)
	-- Until the host starts the game, keep accepting clients and polling network.
	-- Once the game has started, run the update loop.
	if not Server.game_start then
		Server.listen()
	else
		Server:update(dt)
	end
end

function love.draw() end
