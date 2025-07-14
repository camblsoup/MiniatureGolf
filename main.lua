package.path = package.path .. ";./?.lua"
local Player = require("Player")
local GolfBall = require("GolfBall")

local FORCE_SCALE = 20 -- Scale down the force applied to the golf ball

function love.load()
    player = Player.new()
    golf_ball = GolfBall.new(400, 300, 10)
end

function love.update(dt)
    if love.mouse.isDown(1) and not golf_ball.is_moving then
        local mouse_x, mouse_y = love.mouse.getPosition()
        player:aim(mouse_x, mouse_y, golf_ball.x, golf_ball.y)
    end
    if golf_ball.is_moving then
        golf_ball:roll()
    end
end

function love.draw()
    golf_ball:display()
    if player.is_aiming then
        player:display_aim(golf_ball.x, golf_ball.y)
    end
end

function love.mousereleased(x, y, button)
    if player.is_aiming and button == 1 then
        -- player:shoot() -- Send data to server
        player.is_aiming = false

        -- Get end position of ball from server
        local force = player.magnitude / FORCE_SCALE -- Placeholder
        local angle = player.angle -- Placeholder
        golf_ball.velocity_x = -force * math.cos(angle)
        golf_ball.velocity_y = -force * math.sin(angle)
        golf_ball.is_moving = true
    end
end