package.path = package.path .. ";./?.lua"

local menu = require("scenes/MainMenu")

local hostButton
local joinButton
local quitButton

function love.load()

    -- images
    hostButton = love.graphics.newImage("assets/img/hostButton.png")
    joinButton = love.graphics.newImage("assets/img/joinButton.png")
    quitButton = love.graphics.newImage("assets/img/quitButton.png")

end


function love.draw()
    menu.title()
    menu.hostButton(hostButton)
    menu.joinButton(joinButton)
    menu.quitButton(quitButton)
end