package.path = package.path .. ";./?.lua"

local menu = require("scenes/MainMenu")

function love.load()
    love.graphics.setBackgroundColor(1, 1, 1) -- set white

end


function love.draw()
    menu.title()
    menu.hostButton()
    menu.joinButton()
    menu.quitButton()
end