local Server = {}
Server.__index = Server

local GolfBall = require("classes/GolfBall")
local Obstacle = require("classes/Obstacle")
local levels = require("levels")

function Server.new() -- load
    local self = setmetatable({}, Server)

    self.level_index = 1
    self.clients = {}
    self.current_player = 1 -- Current player doesn't currently change
    self.game_world = love.physics.newWorld(0, 0, true)
    self.golf_ball = GolfBall.new(self.game_world, 425, 300, 10, {0, 0, 1})
    self.obstacles_data = {}
    self.obstacles = {}
    self.ball_in_motion = false

    return self
end

function Server:update(dt)
    self.game_world:update(dt)
    if self.ball_in_motion then
        if not self.golf_ball:isMoving() then
            self.ball_in_motion = false
            
            for _, client in ipairs(self.clients) do
                client.finish_ball_shoot()
            end
        end
    end
end

function Server:draw()
    self.golf_ball:display() -- Testing purposes
end

function Server:generate_level()
    self.obstacles_data = levels[self.level_index]
    for _, obstacle_data in ipairs(self.obstacles_data) do
        local obstacle = Obstacle.new(self.game_world, obstacle_data.x, obstacle_data.y, obstacle_data.width, obstacle_data.height)
        table.insert(self.obstacles, obstacle)
    end
    
    for _, client in ipairs(self.clients) do
        client.generate_level()
    end
end

function Server:launch_ball(velocity_x, velocity_y)
    self.golf_ball.body:applyForce(velocity_x, velocity_y)
    self.ball_in_motion = true
end

return Server
