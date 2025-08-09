local SM = require("lib/sceneManager")
local Client = require("lib/Client")
local socket = require("socket")

function love.load()
    print("Game Start!")
    love.physics.setMeter(30)
    SM.loadScene("MainMenu") -- Load the main menu scene
end

function love.update(dt)
    -- Update networking client if socket thread is running
    if Client and Client.socket_thread and Client.socket_thread:isRunning() then
        Client:update(dt)
    end
    SM.update(dt) -- Update current scene
end

function love.draw()
    SM.draw() -- Draw current scene
end

function love.quit()
    -- On quitting, notify the server to cleanly disconnect
    if Client and Client.socket_thread and Client.socket_thread:isRunning() then
        print("Sending shutdown")
        love.thread.getChannel("receive_channel"):clear()
        Client.send_data_to_server({ type = "shutdown", id = Client.client_id, data = nil })
        local exit
        -- Wait for server acknowledgement or timeout
        repeat
            exit = love.thread.getChannel("receive_channel"):demand(3)
        until (exit and exit.type == "shutdown") or exit == nil
        if not exit then
            print("Exited improperly")
        end
    end
end

function love.mousepressed(x, y, button)
    SM.mousepressed(x, y, button) -- Pass mouse press events to scene manager
end

function love.mousereleased(x, y, button)
    SM.mousereleased(x, y, button) -- Pass mouse release events to scene manager
end

function love.keypressed(key)
    SM.keypressed(key) -- Pass keyboard press events to scene manager
end
