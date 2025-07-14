local menu = {}

local width, height = love.graphics.getDimensions()

local fontTitle = love.graphics.newFont("assets/dogicapixelbold.ttf", 40)
local fontButton = love.graphics.newFont("assets/dogicapixelbold.ttf", 30)

function menu.title()
    -- color of text
    love.graphics.setColor(0, 0, 0, 1)

    -- font size
    love.graphics.setFont(fontTitle)

    -- text
    love.graphics.printf("MINIATURE GOLF", 0, height / 2 - 200, width, "center")
end

function menu.hostButton()
    -- font
    love.graphics.setFont(fontButton)

    --  text
    love.graphics.setColor(0, 0, 0, 1) -- black
    love.graphics.printf("HOST A GAME", 0, height / 2, width, "center")
end

function menu.joinButton()
    -- font
    love.graphics.setFont(fontButton)

    -- dimensions
    -- x, y, width, height
    love.graphics.rectangle("line", width/3 +10, height / 2 + 75, 250, 25)

    --  text
    love.graphics.setColor(0, 0, 0, 1) -- black
    love.graphics.printf("JOIN GAME", 0, height / 2 + 75, width, "center")
end

function menu.quitButton()
    -- font
    love.graphics.setFont(fontButton)

    --  text
    love.graphics.setColor(0, 0, 0, 1) -- black
    love.graphics.printf("QUIT", 0, height / 2 + 150, width, "center")
end

return menu;
