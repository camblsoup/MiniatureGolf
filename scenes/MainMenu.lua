local menu = {}

local width, height = love.graphics.getDimensions()

local fontTitle = love.graphics.newFont("assets/dogicapixelbold.ttf", 40)
local fontButton = love.graphics.newFont("assets/dogicapixelbold.ttf", 30)

function menu.title()
    -- color of text

    -- font size
    love.graphics.setFont(fontTitle)

    -- text
    love.graphics.printf("MINIATURE", 0, height / 2 - 200, width, "center")
        love.graphics.printf("GÖLF!", 0, height / 2 - 125, width, "center")

end

-- host button
function menu.hostButton(img)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(img, width/2, height/2, 0, 1, 1, 225)
end

function menu.joinButton(img)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(img, width/2, height/2+ 75, 0 , 1, 1, 225)
end

function menu.quitButton(img)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(img, width/2, height/2 + 150, 0, 1, 1, 225)
end

return menu;
