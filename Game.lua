local GameScene = {}

local Player = require("Player")
local GolfBall = require("GolfBall")

local FORCE_SCALE = 20 -- Scale down the force applied to the golf ball
local gameWorld
local player
local golf_ball

function GameScene.load()
    gameWorld = love.physics.newWorld(0, 0, true)
    player = Player.new()
    golf_ball = GolfBall.new(gameWorld, 400, 300, 10)
end

function GameScene.update(dt)
    gameWorld:update(dt)
    if love.mouse.isDown(1) and not golf_ball:isMoving() then
        local mouse_x, mouse_y = love.mouse.getPosition()
        player:aim(mouse_x, mouse_y, golf_ball)
    end
end

function GameScene.draw()
    golf_ball:display()
    if player.is_aiming then
        player:display_aim(golf_ball.body:getX(), golf_ball.body:getY())
    end
end

function GameScene.mousereleased(x, y, button)
    if player.is_aiming and button == 1 then
        -- player:shoot() -- Send data to server
        player.is_aiming = false

        -- Get end position of ball from server
        local force = player.magnitude / FORCE_SCALE -- Placeholder
        local angle = player.angle                   -- Placeholder
        local velocity_x = -force * math.cos(angle)
        local velocity_y = -force * math.sin(angle)
        golf_ball.body:applyForce(velocity_x, velocity_y)
    end
end

return GameScene