local SM = require("lib/sceneManager")
local Client = require("lib/Client")

local HostPort = {
	buttons = {},
}
local width, height = love.graphics.getDimensions()

local box_w = 200

local text
local starting_server
local box = {
	w = box_w,
	h = 50,
	x = (width - box_w) / 2,
	y = height - 275,
	pad = 10,
}

local fontTitle = love.graphics.newFont("assets/dogicapixelbold.ttf", 30)
local fontText = love.graphics.newFont("assets/dogicapixelbold.ttf", 20)
local fontPort = love.graphics.newFont("assets/dogicapixelbold.ttf", 35)

local width, height = love.graphics.getDimensions()

function HostPort.load()
	love.graphics.setFont(fontPort)
	text = "" or text

	HostPort.buttons = {
		createGame = {
			img = love.graphics.newImage("assets/img/createGameButton.png"),
			x = 10,
			y = 10,
			action = function()
				local port = tonumber(text) or 5000
				if jit.os == "Windows" then
					os.execute("start lovec ../Server/ " .. port)
				else
					os.execute("love ../Server/ " .. port .. " --console &")
				end
				local connected, err = Client.load("127.0.0.1", port)
				if connected then
					print("connected to server")
					SM.loadScene("Host")
				else
					print("Could not start server: " .. err)
				end
			end,
		},
		back = {
			img = love.graphics.newImage("assets/img/backButton.png"),
			x = 10,
			y = 10,
			action = function()
				SM.loadScene("MainMenu")
			end,
		},
	}
	for name, button in pairs(HostPort.buttons) do
		-- button size
		if name == "back" then
			button.width = 56
			button.height = 56
		else
			button.width = 310
			button.height = 50
			button.x = (width - button.width) / 2
			button.y = height - 100
		end
	end
end

function HostPort.draw()
	HostPort.Port()

	for _, button in pairs(HostPort.buttons) do
		love.graphics.draw(
			button.img,
			button.x, -- x position
			button.y, -- y position
			0, -- rotation
			button.width / button.img:getWidth(), -- x scale
			button.height / button.img:getHeight()
		) -- y scale
	end

	-- textbox
	love.graphics.setFont(fontPort)

	-- set the text color to white
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
	love.graphics.setScissor(box.x + 1, box.y + 5, box.w - 2, box.h - 2) -- wrap
	-- text
	love.graphics.printf(text, box.x + box.pad, box.y + box.pad, box.w - box.pad * 2, "left")
	love.graphics.setScissor()
end

--------------------------------------------------------------------------
-- Instructions

-- your IP address
function HostPort.Port()
	love.graphics.setFont(fontTitle, width)

	love.graphics.printf("Select a port number", 0, 100, love.graphics.getWidth(), "center")

	love.graphics.setFont(fontText, width)
	love.graphics.printf("In the box below, type a number from 0 to 65535", 0, 175, love.graphics.getWidth(), "center")

	love.graphics.printf("Your friends will use this number as the port!", 0, 225, love.graphics.getWidth(), "center")
end

-- textbox input for port
-- seems to be a dupe
function love.textinput(t)
	if t:match("[0-9%./:]") then
		text = text .. t
	end
end

--
function HostPort.keypressed(key)
	if key == "backspace" then
		text = text:sub(1, -2)
	end
end

-----------------------------------------
function HostPort.mousepressed(x, y, button)
	-- left click
	if button == 1 then
		for _, btn in pairs(HostPort.buttons) do
			-- find position
			if x > btn.x and x < btn.x + btn.width and y > btn.y and y < btn.y + btn.height then
				-- button function
				btn.action()
			end
		end
	end
end

return HostPort
