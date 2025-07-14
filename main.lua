package.path = package.path .. ";./?.lua"
local Player = require("Player")
local GolfBall = require("GolfBall")

function love.load()
    player = Player.new()
    golf_ball = GolfBall.new(400, 300, 10)
end

function love.update(dt)
    if love.mouse.isDown(1) then
        local mouse_x, mouse_y = love.mouse.getPosition()
        player:aim(mouse_x, mouse_y, golf_ball.x, golf_ball.y)
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
        player:shoot()
    end
end