local SM = require("lib/sceneManager")

local MainMenu = {
    buttons = {}
}

local fontTitle = love.graphics.newFont("assets/dogicapixelbold.ttf", 40)

local width, height = love.graphics.getDimensions()

function MainMenu.load()
    MainMenu.buttons = {
        -- host game button
        host = {
            img = love.graphics.newImage("assets/img/hostButton.png"),
            x = 0,
            y = height - 400,
            action = function()
                SM.loadScene("Host")
            end
        },
        -- join game button
        join = {
            img = love.graphics.newImage("assets/img/joinButton.png"),
            x = 0,
            y = height - 300,
            action = function()
                SM.loadScene("Join")
            end
        },
        -- quit game button
        quit = {
            img = love.graphics.newImage("assets/img/quitButton.png"),
            x = 0,
            y = height - 200,
            action = function()
                love.event.quit()
            end
        }
    }

    for _, button in pairs(MainMenu.buttons) do
        -- button size
        button.width = 400
        button.height = 50

        -- button x-position
        button.x = (love.graphics.getWidth() - button.width) / 2
    end
end

function MainMenu.draw()
    MainMenu.title()

    for _, button in pairs(MainMenu.buttons) do
        love.graphics.draw(button.img,
            button.x,                               -- x position
            button.y,                               -- y position
            0,                                      -- rotation
            button.width / button.img:getWidth(),   -- x scale
            button.height / button.img:getHeight()) -- y scale
    end
end

function MainMenu.mousepressed(x, y, button)
    -- left click
    if button == 1 then
        for _, btn in pairs(MainMenu.buttons) do
            -- find position
            if x > btn.x and x < btn.x + btn.width and
                y > btn.y and y < btn.y + btn.height then
                -- button function
                btn.action()
            end
        end
    end
end

function MainMenu.title()
    love.graphics.setFont(fontTitle, width)
    love.graphics.printf("MINIATURE", 0, 100, love.graphics.getWidth(), "center")
    love.graphics.printf("GÖLF!", 0, 150, love.graphics.getWidth(), "center")
end

return MainMenu
