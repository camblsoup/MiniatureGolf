local SM = require("lib/sceneManager")

local JoinScene = {
    buttons = {}
}

function JoinScene.load()
    JoinScene.buttons = {
        back = {
            img = love.graphics.newImage("assets/img/backButton.png"),
            x = 10,
            y = 10,
            action = function()
                SM.loadScene("MainMenu")
            end
        }
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

function JoinScene.draw()
    for _, button in pairs(JoinScene.buttons) do
        love.graphics.draw(button.img,
            button.x,                               -- x position
            button.y,                               -- y position
            0,                                      -- rotation
            button.width / button.img:getWidth(),   -- x scale
            button.height / button.img:getHeight()) -- y scale
    end
end

function JoinScene.mousepressed(x, y, button)
    -- left click
    if button == 1 then
        for _, btn in pairs(JoinScene.buttons) do
            -- find position
            if x > btn.x and x < btn.x + btn.width and
                y > btn.y and y < btn.y + btn.height then
                -- button function
                btn.action()
            end
        end
    end
end

return JoinScene