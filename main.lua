package.path = package.path .. ";./?.lua"

local SM = require("lib/sceneManager")

function love.load()
    SM.loadScene("Client")
end

function love.update(dt)
    SM.update(dt)
end

function love.draw()
    SM.draw()
end

function love.mousepressed(x, y, button)
    SM.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    SM.mousereleased(x, y, button)
end