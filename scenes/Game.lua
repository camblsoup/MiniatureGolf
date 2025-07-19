local GameScene = {}

local Player = require("classes/Player")
local GolfBall = require("classes/GolfBall")
local Obstacle = require("classes/Obstacle")
local Server = require("classes/Server")

local FORCE_SCALE = 20 -- Scale down the force applied to the golf ball

-- Client variables
local server
local player -- Player object
local player_id = 1
local game_world -- Physics world for the game
local golf_ball
local obstacles_data = {}
local obstacles = {}


function GameScene.load()
    game_world = love.physics.newWorld(0, 0, true)
    player = Player.new()
    golf_ball = GolfBall.new(game_world, 400, 300, 10)
    server = Server.new()
    server:generate_level()
end

function GameScene.update(dt)
    game_world:update(dt)
    if love.mouse.isDown(1) and not golf_ball:isMoving() then
        local mouse_x, mouse_y = love.mouse.getPosition()
        player:aim(mouse_x, mouse_y, golf_ball)
    end

    if server.have_data_to_send then
        obstacles_data = server.obstacles_data
        for _, obstacle_data in ipairs(obstacles_data) do
            local obstacle = Obstacle.new(game_world, obstacle_data.x, obstacle_data.y, obstacle_data.width, obstacle_data.height)
            table.insert(obstacles, obstacle)
        end
        server.have_data_to_send = false
    end
end

function GameScene.draw()
    golf_ball:display()
    if player.is_aiming then
        player:display_aim(golf_ball.body:getX(), golf_ball.body:getY())
    end

    for _, obstacle in ipairs(obstacles) do
        obstacle:draw()
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