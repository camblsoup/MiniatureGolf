local Server = {}
Server.__index = Server

local GolfBall = require("classes/GolfBall")
local Obstacle = require("classes/Obstacle")
local Goal = require("classes/Goal")
local levels = require("levels")

function Server.new() -- load
    local self = setmetatable({}, Server)

    -- Server state variables
    self.level_index = 1
    self.clients = {}
    self.current_shooter = 1
    self.obstacles_data = {}
    self.obstacles = {}
    self.goal = nil
    self.golf_ball = nil
    self.ball_in_motion = false

    -- Gameplay variables
    self.current_shots = 0
    self.high_score = 0

    return self
end

function Server:update(dt)
    self.game_world:update(dt)

    if self.ball_in_motion then
        if not self.golf_ball:isMoving() then
            self:finish_ball_shoot()
        end
    end

    if self.goal:check_reached(self.golf_ball.body) then
        self:next_level()
    end
end

function Server:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Server Current Shooter: " .. self.current_shooter, 10, 10)
    love.graphics.print("\n\nCurrent Shots: " .. self.current_shots, 10, 30)
    love.graphics.print("\n\n\nHigh Score: " .. self.high_score, 10, 50)
    self.golf_ball:display() -- Testing purposes
end

function Server:generate_level()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()

    self.game_world = love.physics.newWorld(0, 0, true)
    self.obstacles_data = levels[self.level_index]

    local golf_ball_data = self.obstacles_data[1]
    local goal_data = self.obstacles_data[2]
    self.golf_ball = GolfBall.new(self.game_world, screen_width * golf_ball_data.x, screen_height * golf_ball_data.y, 10, true)
    self.goal = Goal.new(self.game_world, screen_width * goal_data.x, screen_height * goal_data.y)

    self.obstacles = {}
    for i = 3, #self.obstacles_data do
        local obstacle_data = self.obstacles_data[i]
        table.insert(self.obstacles,
            Obstacle.new(self.game_world, screen_width * obstacle_data.x, screen_height * obstacle_data.y, screen_width * obstacle_data.width, screen_height * obstacle_data.height))
    end

    for _, client in ipairs(self.clients) do
        client.generate_level()
    end
end

function Server:launch_ball(velocity_x, velocity_y)
    self.golf_ball.body:applyLinearImpulse(velocity_x, velocity_y)
    self.ball_in_motion = true
    self.current_shots = self.current_shots + 1
end

function Server:finish_ball_shoot()
    self.ball_in_motion = false
    self.current_shooter = self.current_shooter % 4 + 1 -- Cycle through clients

    for _, client in ipairs(self.clients) do
        client.finish_ball_shoot(self.current_shooter)
    end
end

function Server:next_level()
    self.level_index = self.level_index + 1
    if self.level_index > #levels then
        self.level_index = 1
        if self.high_score == 0 then
            self.high_score = self.current_shots
        else
            self.high_score = math.min(self.high_score, self.current_shots)
        end
        self.current_shots = 0
    end
    self.game_world:destroy()
    self:generate_level()
end

return Server
