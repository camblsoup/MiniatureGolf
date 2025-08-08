local SM = require("lib/sceneManager")
local socket = require("socket")
local Client = require("lib/Client")

local font = love.graphics.newFont("assets/dogicapixelbold.ttf", 20)
local fontInput = love.graphics.newFont("assets/dogicapixelbold.ttf", 30)

local width, height = love.graphics.getDimensions()
local text
local box = {
	w = width / 2 + 90,
	h = 50,
	x = (width - (width / 2 + 90)) / 2,
	y = (height - 50) / 2,
	pad = 10,
}
-- error message
local isErrorMessageVisible = false
local timer = 0

local JoinScene = {
	buttons = {},
}
-------------------------------------------------------------
function JoinScene.load()
	love.graphics.setFont(fontInput)
	text = "" or text
	JoinScene.buttons = {
		back = {
			img = love.graphics.newImage("assets/img/backButton.png"),
			x = 10,
			y = 10,
			action = function()
				SM.loadScene("MainMenu")
			end,
		},

		join = {
			img = love.graphics.newImage("assets/img/joinButton2.png"),
			x = 0,
			y = 450,
			action = function()
				isErrorMessageVisible = false
				timer = 0
				local words = {}
				for split in string.gmatch(text, "([^:]+)") do
					table.insert(words, split)
				end
				local host = words[1]
				local port = tonumber(words[2])
				local connected, err = Client.load(host, port)
				if connected then
					print("Connected to server")
					SM.loadScene("Joined") -- ensure that the user inputs a valid network
				else
					-- handle connection error
					print("Could not connect: " .. err)
					JoinScene.errorMessageVisible()
				end
			end,
		},
	}
	for name, button in pairs(JoinScene.buttons) do
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
function JoinScene.draw()
	love.graphics.setFont(font)
	-- buttons
	for _, button in pairs(JoinScene.buttons) do
		love.graphics.draw(
			button.img,
			button.x, -- x position
			button.y, -- y position
			0, -- rotation
			button.width / button.img:getWidth(), -- x scale
			button.height / button.img:getHeight()
		) -- y scale
	end

	love.graphics.printf("Join with the host's IP and port number", 0, 100, love.graphics.getWidth(), "center")

	love.graphics.printf("IP:PORT NUMBER", 0, 150, love.graphics.getWidth(), "center")

	love.graphics.printf("e.g. 255.255.255.255:5000", 0, 200, love.graphics.getWidth(), "center")

	-- textbox
	-- set the text color to white
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
	love.graphics.setScissor(box.x + 1, box.y + 5, box.w - 2, box.h - 2) -- wrap
	-- text
	love.graphics.setFont(fontInput)
	love.graphics.printf(text, box.x + box.pad, box.y + box.pad, box.w - box.pad * 2, "left")
	love.graphics.setFont(font)

	love.graphics.setScissor()

	-- error message
	love.graphics.setColor(255, 0, 0) -- set error message to red
	if isErrorMessageVisible then
		JoinScene.invalidLobby()
	end
	love.graphics.setColor(255, 255, 255) -- set it back to white
end

-------------------------------------------------------------
-- textbox input for IP
function love.textinput(t)
	if #text < 21 and t:match("[0-9%./:]") then
		text = text .. t
	end
end

function JoinScene.update(dt)
	JoinScene.timer(dt)
end

-------------------------------------------------------------
-- for the buttons
function JoinScene.mousepressed(x, y, button)
	-- left click
	if button == 1 then
		for _, btn in pairs(JoinScene.buttons) do
			-- find position
			if x > btn.x and x < btn.x + btn.width and y > btn.y and y < btn.y + btn.height then
				-- button function
				btn.action()
			end
		end
	end
end

-------------------------------------------------------------
-- delete char
function JoinScene.keypressed(key)
	if key == "backspace" then
		text = text:sub(1, -2)
	end
end

function JoinScene.invalidLobby()
	love.graphics.printf(
		"The IP/port you have inputted is invalid",
		0,
		height - 250,
		love.graphics.getWidth(),
		"center"
	)
end

function JoinScene.errorMessageVisible()
	isErrorMessageVisible = true
	timer = 20
end

function JoinScene.timer(dt)
	if isErrorMessageVisible then
		timer = timer - dt
		if timer <= 0 then
			isErrorMessageVisible = false
		end
	end
end

return JoinScene
