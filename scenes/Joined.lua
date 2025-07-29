local SM = require("lib/sceneManager")

local Joined = {}

local font = love.graphics.newFont("assets/dogicapixelbold.ttf", 20)

function Joined.load()
    love.graphics.setFont(font)
    Joined.buttons = {
        back = {
            img = love.graphics.newImage("assets/img/backButton.png"),
            x = 10,
            y = 10,
            action = function()
                SM.loadScene("MainMenu")
            end
        },
    }
    for _, button in pairs(Joined.buttons) do
        -- button size
        button.width = 56
        button.height = 56
    end
end

function Joined.draw()
    love.graphics.setFont(font)

    love.graphics.printf("Successfully joined!", 0, 100, love.graphics.getWidth(), "center")
    love.graphics.printf("Waiting for the host to start the game...", 0, 150, love.graphics.getWidth(), "center")

    for _, button in pairs(Joined.buttons) do
        love.graphics.draw(button.img,
            button.x,                               -- x position
            button.y,                               -- y position
            0,                                      -- rotation
            button.width / button.img:getWidth(),   -- x scale
            button.height / button.img:getHeight()) -- y scale
    end
end

function Joined.mousepressed(x, y, button)
    -- left click
    if button == 1 then
        for _, btn in pairs(Joined.buttons) do
            -- find position
            if x > btn.x and x < btn.x + btn.width and
                y > btn.y and y < btn.y + btn.height then
                -- button function
                btn.action()
            end
        end
    end
end

return Joined
