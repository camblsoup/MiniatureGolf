local SM = require("lib/sceneManager")
local Client = require("lib/Client")
local socket = require("socket")
local json = require("lib/json")

local HostScene = {
	buttons = {},
}

local fontIP = love.graphics.newFont("assets/dogicapixelbold.ttf", 20)
local fontTitle = love.graphics.newFont("assets/dogicapixelbold.ttf", 30)

local width, height = love.graphics.getDimensions()
local ip = nil
local port = nil
-------------------------------------------------------------
-- load
function HostScene.load()
	local udp = socket.udp()
	udp:setpeername("8.8.8.8", 80)
	ip = udp:getsockname()
	udp:close()
	HostScene.buttons = {
		-- start game
		start = {
			img = love.graphics.newImage("assets/img/startButton.png"),
			x = 0,
			y = height - 100,
			action = function()
				Client.send_data_to_server({ type = "start", id = Client.client_id })
			end,
		},
		-- return to main menu
		back = {
			img = love.graphics.newImage("assets/img/backButton.png"),
			x = 10,
			y = 10,
			action = function()
				print("Sending shutdown")
				Client.send_data_to_server({ type = "shutdown", data = nil })
				local exit = love.thread.getChannel("receive_channel"):demand(3)
				if not exit or exit ~= "exit" then
					print("Exited improperly")
				end
				SM.loadScene("MainMenu")
			end,
		},
	}
	for name, button in pairs(HostScene.buttons) do
		-- button size

		if name == "back" then
			button.width = 56
			button.height = 56
		else
			button.width = 220
			button.height = 50
			button.x = (love.graphics.getWidth() - button.width) / 2
		end
	end
end

-------------------------------------------------------------
-- your IP address
function HostScene.IP()
	love.graphics.setFont(fontTitle, width)

	love.graphics.printf(ip .. ":" .. SM.host_port, 0, 150, love.graphics.getWidth(), "center")

	love.graphics.setFont(fontIP, width)

	love.graphics.printf("Your IP:", 0, 100, love.graphics.getWidth(), "center")

	love.graphics.printf(
		"Your friends will connect with this IPv4 address!",
		0,
		220,
		love.graphics.getWidth(),
		"center"
	)
end

-------------------------------------------------------------
function HostScene.draw()
	HostScene.IP()

	love.graphics.printf("You are player #" .. Client.player_num, 0, height - 200, width, "center")

	for _, button in pairs(HostScene.buttons) do
		love.graphics.draw(
			button.img,
			button.x,                     -- x position
			button.y,                     -- y position
			0,                            -- rotation
			button.width / button.img:getWidth(), -- x scale
			button.height / button.img:getHeight() -- y scale
		)
	end
end

-------------------------------------------------------------
function HostScene.mousepressed(x, y, button)
	-- left click
	if button == 1 then
		for _, btn in pairs(HostScene.buttons) do
			-- find position
			if x > btn.x and x < btn.x + btn.width and y > btn.y and y < btn.y + btn.height then
				-- button function
				btn.action()
			end
		end
	end
end

return HostScene
