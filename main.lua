package.path = package.path .. ";./?.lua"
local Server = require("lib/Server")
local server


local SM = require("lib/sceneManager")

function love.load()
    server = Server.new()

    love.physics.setMeter(30)
    SM.loadScene("MainMenu")
end

function love.update(dt)
    if server and server.network_thread then
        local success, message = pcall(function()
            return server.network_thread:getMessage()
        end)
        if success and message then
            print("Thread message:", message)
        end
    end

    server:update(dt)
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

function love.keypressed(key)
    SM.keypressed(key)
end