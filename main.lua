package.path = package.path .. ";./?.lua"
local Server = require("classes/Server")
local server


local SM = require("lib/sceneManager")

function love.load()
    server = Server.new()
    server:initNetwork(22222)
    SM.loadScene("Client")
end

function love.update(dt)
    server:update(dt)
    server:updateNetwork()
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