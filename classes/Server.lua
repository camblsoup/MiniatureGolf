local Server = {}
local socket = require("socket")

Server.__index = Server

local GolfBall = require("classes/GolfBall")
local Obstacle = require("classes/Obstacle")
local Goal = require("classes/Goal")
local levels = require("levels")

function Server.new() -- load
    local self = setmetatable({}, Server)

    self.level_index = 1
    self.clients = {}
    self.current_player = 1 -- Current player doesn't currently change
    self.obstacles_data = {}
    self.obstacles = {}
    self.goal = nil
    self.golf_ball = nil
    self.ball_in_motion = false

    self.game_world = love.physics.newWorld(0, 0, true)
    

    self.network_thread = love.thread.newThread("network_server.lua")
    self.network_thread:start()

    return self
end




function Server:update(dt)
    if self.game_world then
        self.game_world:update(dt)
    end

    if self.ball_in_motion and self.golf_ball then
        if not self.golf_ball:isMoving() then
            self.ball_in_motion = false        
            for _, client in ipairs(self.clients) do
                if client.finish_ball_shoot then
                    client.finish_ball_shoot()
                end
            end
        end
    end

    -- safety checks here
    if self.goal and self.golf_ball then
        if self.goal:check_reached(self.golf_ball.body) then
            self:next_level()
        end
    end
end

function Server:draw()
    self.golf_ball:display() -- Testing purposes
end

function Server:generate_level()
    self.game_world = love.physics.newWorld(0, 0, true)
    self.obstacles_data = levels[self.level_index]
    
    local golf_ball_data = self.obstacles_data[1]
    local goal_data = self.obstacles_data[2]
    self.golf_ball = GolfBall.new(self.game_world, golf_ball_data.x, golf_ball_data.y, 10, {0, 0, 1})
    self.goal = Goal.new(self.game_world, goal_data.x, goal_data.y)

    self.obstacles = {}
    for i = 3, #self.obstacles_data do
        local obstacle_data = self.obstacles_data[i]
        table.insert(self.obstacles, Obstacle.new(self.game_world, obstacle_data.x, obstacle_data.y, obstacle_data.width, obstacle_data.height))
    end
    
    for _, client in ipairs(self.clients) do
        client.generate_level()
    end
end

function Server:next_level()
    self.level_index = self.level_index + 1
    if self.level_index > #levels then
        self.level_index = 1
    end
    self.game_world:destroy()
    self:generate_level()
end

function Server:launch_ball(velocity_x, velocity_y)
    self.golf_ball.body:applyForce(velocity_x, velocity_y)
    self.ball_in_motion = true
end

return Server
