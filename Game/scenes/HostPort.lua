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

local startServerCoroutine = nil
local isStartingServer = nil
local isErrorMessageVisible = nil
local startResult = nil

function HostPort.load()
	love.graphics.setFont(fontPort)

	-- store empty string or text for port input
	text = "" or text

	-- Starting server... message
	isStartingServer = false

	-- Server failed to start... message
	isErrorMessageVisible = false

	HostPort.buttons = {
		-- create game button
		createGame = {
			img = love.graphics.newImage("assets/img/createGameButton.png"),
			x = 10,
			y = 10,
			action = function()
				-- if host leaves port empty, automatically set it as 7777
				local port = tonumber(text) or 7777

				-- start the game
				if jit.os == "Windows" then
					os.execute("start lovec ../Server/ " .. port)
				else
					os.execute("love ../Server/ " .. port .. " --console &")
				end

				-- activate "server is starting..." message
				isStartingServer = true

				-- keep the error message hidden
				isErrorMessageVisible = false

				-- used for join/joined/host to solve window freezes.
				startServerCoroutine = coroutine.create(function()
					coroutine.yield() -- yield so main loop can draw
					local words = {}
					-- split the text up between the :
					for split in string.gmatch(text, "([^:]+)") do
						-- and store the separate values into a table
						table.insert(words, split)
					end

					-- connect to the host server on the local IP, and the chosen port.
					local connected, err = Client.load("127.0.0.1", port)

					if connected then
						startResult = "success"
					else
						-- error handling
						startResult = err or "unknown error"
					end
				end)
			end,
		},
		-- back button
		back = {
			img = love.graphics.newImage("assets/img/backButton.png"),
			x = 10, -- x position
			y = 10, -- y position
			action = function()
				-- return to main menu
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

function HostPort.update(dt)
	-- draws frame to tell client that it is connecting, so begin the co-routine
	if startServerCoroutine then
		local status, res = coroutine.resume(startServerCoroutine)
		if not status then
			-- Coroutine error
			print("Start server coroutine error:", res)
			isStartingServer = false -- hide the "starting the server" message
			isErrorMessageVisible = true -- unhide the "server failed to start" message
			startServerCoroutine = nil
		elseif coroutine.status(startServerCoroutine) == "dead" then
			-- Coroutine finished
			if startResult == "success" then
				-- if the host does not pick a custom port, 
				if text == "" then
					SM.host_port = "7777"
				-- otherwise, set the port to the inputted text
				else
					SM.host_port = text
				end
				-- load the next scene 
				SM.loadScene("Host")
			else
				-- if it fails, display the correct message
				isStartingServer = false
				isErrorMessageVisible = true
			end
			startServerCoroutine = nil
		end
	end
end

function HostPort.draw()
	-- instructions
	HostPort.Port()

	-- button position and size 
	for _, button in pairs(HostPort.buttons) do
		love.graphics.draw(
			button.img,
			button.x,                    -- x position
			button.y,                    -- y position
			0,                           -- rotation
			button.width / button.img:getWidth(), -- x scale
			button.height / button.img:getHeight()
		)                                -- y scale
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

	love.graphics.setFont(fontText, width)
	-- Starting Server message
	if isStartingServer then
		HostPort.starting()
	end

	-- error message
	love.graphics.setColor(255, 0, 0) -- set error message to red
	if isErrorMessageVisible then
		HostPort.ServerFailed()
	end
	love.graphics.setColor(255, 255, 255) -- set it back to white
end

-- failure to start a game message
function HostPort.ServerFailed()
	love.graphics.printf("The server failed to start", 0, height - 200, love.graphics.getWidth(), "center")
end

-- successfully started a game message
function HostPort.starting()
	love.graphics.printf("Starting server...", 0, height - 200, love.graphics.getWidth(), "center")
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
	-- set a max of 5 characters. Only allow numbers, ., and :
	if #text < 5 and t:match("[0-9%./:]") then
		text = text .. t
	end
end

-- for deleting characters of the text string
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
