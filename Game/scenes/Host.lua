local SM = require("lib/sceneManager")

local HostScene = {
    buttons = {}
}

local fontIP = love.graphics.newFont("assets/dogicapixelbold.ttf", 20)
local width, height = love.graphics.getDimensions()
-------------------------------------------------------------
-- load
function HostScene.load()
    local networkThread
    local hostThread = love.thread.newThread("/lib/Server.lua")
    hostThread:start()
    HostScene.buttons = {
        -- start game
        start = {
            img = love.graphics.newImage("assets/img/startButton.png"),
            x = 0,
            y = height - 100,
            action = function()
                SM.loadScene("Game")
            end
        },
        -- return to main menu
        back = {
            img = love.graphics.newImage("assets/img/backButton.png"),
            x = 10,
            y = 10,
            action = function()
                SM.loadScene("HostPort")
            end
        }
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
    love.graphics.setFont(fontIP, width)

    love.graphics.printf("Your IP:", 0, 100, love.graphics.getWidth(), "center")

    love.graphics.printf("Open command prompt and type 'ipconfig'",
        0, 150, love.graphics.getWidth(), "center")

    love.graphics.printf("Your friends will connect with IPv4 address!",
        0, 200, love.graphics.getWidth(), "center")
end

-------------------------------------------------------------
function HostScene.draw()
    HostScene.IP()

    for _, button in pairs(HostScene.buttons) do
        love.graphics.draw(button.img,
            button.x,                               -- x position
            button.y,                               -- y position
            0,                                      -- rotation
            button.width / button.img:getWidth(),   -- x scale
            button.height / button.img:getHeight()) -- y scale
    end
end

-------------------------------------------------------------
function HostScene.mousepressed(x, y, button)
    -- left click
    if button == 1 then
        for _, btn in pairs(HostScene.buttons) do
            -- find position
            if x > btn.x and x < btn.x + btn.width and
                y > btn.y and y < btn.y + btn.height then
                -- button function
                btn.action()
            end
        end
    end
end

return HostScene
