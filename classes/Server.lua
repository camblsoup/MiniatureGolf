local Server = {}
Server.__index = Server

local GolfBall = require("classes/GolfBall")
local Obstacle = require("classes/Obstacle")
local levels = require("levels")

function Server.new() -- load
    local self = setmetatable({}, Server)

    self.level_index = 1
    self.obstacles_data = {}
    self.obstacles = {}
    self.game_world = love.physics.newWorld(0, 0, true)
    self.current_player = 1 -- Current player doesn't currently change
    self.have_data_to_send = false
    -- self.golf_ball = GolfBall.new(self.gameWorld, 400, 300, 10)

    return self
end

function Server:update(dt)
    
end

function Server:draw()
    
end

function Server:generate_level()
    self.obstacles_data = levels[self.level_index]
    for _, obstacle_data in ipairs(self.obstacles_data) do
        local obstacle = Obstacle.new(self.game_world, obstacle_data.x, obstacle_data.y, obstacle_data.width, obstacle_data.height)
        table.insert(self.obstacles, obstacle)
    end
    self.have_data_to_send = true
    -- For each client, send the level data
end

return Server
