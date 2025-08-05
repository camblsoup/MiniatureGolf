local Server = {}

local socket = require("socket")

Server.__index = Server

local GolfBall = require("../classes/GolfBall")
local Obstacle = require("../classes/Obstacle")
local Goal = require("../classes/Goal")
local levels = require("../levels")

local NUM_BALLS = 16

function Server.new() -- load
    local self = setmetatable({}, Server)

    -- self.level_index = 1
    -- self.obstacles_data = {}
    -- self.obstacles = {}
    self.clients = {}
    self.points = {0, 0, 0, 0}
    self.data_to_send = {}
    self.data_received = {}
    
    self.game_world = love.physics.newWorld(0, 0, true)
    self.goal = Goal.new(self.game_world, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    self.golf_balls = {}
    self.num_golf_balls = NUM_BALLS

    for i = 1, NUM_BALLS do
        local x = math.random(0, love.graphics.getWidth())
        local y = math.random(0, love.graphics.getHeight())
        local new_golf_ball = GolfBall.new(self.game_world, i, x, y, true)
        table.insert(self.golf_balls, new_golf_ball)
    end
    self.data_to_send = {
        type = "setup",
        data = {
            golf_balls = self.golf_balls,
            -- goal = self.goal,
        }
    }

    return self
end

function Server:update(dt)
    -- Receive data from clients
    for i, new_client_data in ipairs(self.data_received) do
        if new_client_data == nil then goto continue end
        print("Server received data from client:", i, new_client_data.type)
        
        local data_type = new_client_data.type
        local data = new_client_data.data
        self.data_received[i] = nil

        if data_type == "shoot" then
            local golf_ball = self.golf_balls[data.ball_id]
            golf_ball.current_shooter_id = i
            golf_ball:shoot(data.shooting_magnitude, data.shooting_angle)
            self.data_to_send = {
                type = "shoot",
                data = {
                    ball_id = data.ball_id,
                    client_id = i,
                    shooting_magnitude = data.shooting_magnitude,
                    shooting_angle = data.shooting_angle,
                }
            }
        end
        ::continue::
    end

    -- Send data to clients
    if self.data_to_send.type ~= nil then
        print("Server sending data:", self.data_to_send.type)
        for _, client in ipairs(self.clients) do
            client.receive_data(self.data_to_send)
        end
        self.data_to_send = {}
    end

    self.game_world:update(dt)
    for _, golf_ball in ipairs(self.golf_balls) do
        if golf_ball.rolling and not golf_ball:isMoving() then
            golf_ball:finish_ball_shoot()
            self.data_to_send = {
                type = "finish_shoot",
                data = {
                    ball_id = golf_ball.ball_id,
                    x = golf_ball.body:getX(),
                    y = golf_ball.body:getY(),
                }
            }
        end
        if self.goal:check_reached(golf_ball.body) then
            self.golf_balls[golf_ball.ball_id].scored = true
            self.golf_balls[golf_ball.ball_id].body:setPosition(-50, -50) -- Move the ball off-screen
            self.num_golf_balls = self.num_golf_balls - 1
            self.points[golf_ball.current_shooter_id] = self.points[golf_ball.current_shooter_id] + 1
            self.data_to_send = {
                type = "goal_reached",
                data = {
                    ball_id = golf_ball.ball_id,
                    client_scored = golf_ball.current_shooter_id,
                }
            }
        end
    end
end

function Server:receive_data(client_id, pipeline)
    self.data_received[client_id] = pipeline
end

-- function Server:generate_level()
--     local screen_width = love.graphics.getWidth()
--     local screen_height = love.graphics.getHeight()

--     self.game_world = love.physics.newWorld(0, 0, true)
--     self.obstacles_data = levels[self.level_index]

--     local golf_ball_data = self.obstacles_data[1]
--     local goal_data = self.obstacles_data[2]
--     self.golf_ball = GolfBall.new(self.game_world, screen_width * golf_ball_data.x, screen_height * golf_ball_data.y, 10, true)
--     self.goal = Goal.new(self.game_world, screen_width * goal_data.x, screen_height * goal_data.y)

--     self.obstacles = {}
--     for i = 3, #self.obstacles_data do
--         local obstacle_data = self.obstacles_data[i]
--         table.insert(self.obstacles,
--             Obstacle.new(self.game_world, screen_width * obstacle_data.x, screen_height * obstacle_data.y, screen_width * obstacle_data.width, screen_height * obstacle_data.height))
--     end

--     for _, client in ipairs(self.clients) do
--         client.generate_level()
--     end
-- end

-- function Server:next_level()
--     self.level_index = self.level_index + 1
--     if self.level_index > #levels then
--         self.level_index = 1
--         if self.high_score == 0 then
--             self.high_score = self.current_shots
--         else
--             self.high_score = math.min(self.high_score, self.current_shots)
--         end
--         self.current_shots = 0
--     end
--     self.game_world:destroy()
--     self:generate_level()
-- end

return Server
