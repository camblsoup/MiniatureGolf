local Client = {
    client_id = 1,
    data_to_send = {},
    data_received = {},

    game_world = nil,
    -- obstacles_data = {},
    -- obstacles = {},
    goal = nil,
    golf_balls = {},
    current_ball_id = 0,

    -- scoreboard show/hide buttons
    scoreboard_buttons = {}
}

local GolfBall = require("classes/GolfBall")
local Obstacle = require("classes/Obstacle")
local Goal = require("classes/Goal")
local Server = require("lib/Server")

local server = nil

local scoreboard_font = love.graphics.newFont("assets/dogicapixelbold.ttf", 15)


function Client.load()
    server = Server.new()
    table.insert(server.clients, Client)
    Client.game_world = love.physics.newWorld(0, 0, true)
    Client.goal = Goal.new(Client.game_world, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    -- server:generate_level()
end

function Client.update(dt)
    -- Receive data from server
    if Client.data_received.type ~= nil then
        print("Client received data:", Client.data_received.type)
        local data_type = Client.data_received.type
        local data = Client.data_received.data
        Client.data_received = {}

        if data_type == "setup" then
            Client.golf_balls = {}
            for _, golf_ball in ipairs(data.golf_balls) do
                local golf_ball = GolfBall.new(Client.game_world, golf_ball.ball_id, golf_ball.body:getX(),
                    golf_ball.body:getY())
                table.insert(Client.golf_balls, golf_ball)
            end
            -- Client.goal = Goal.new(Client.game_world, new_server_data.data.goal.x, new_server_data.data.goal.y)
        end

        if data_type == "shoot" then
            local golf_ball = Client.golf_balls[data.ball_id]
            golf_ball.current_shooter_id = data.client_id
            golf_ball:update_color(data.client_id)
            golf_ball:shoot(data.shooting_magnitude, data.shooting_angle)
        end

        if data_type == "finish_shoot" then
            local golf_ball = Client.golf_balls[data.ball_id]
            golf_ball.body:setPosition(data.x, data.y)
            golf_ball:finish_ball_shoot()
        end

        if data_type == "goal_reached" then
            Client.golf_balls[data.ball_id].scored = true
        end
    end

    -- Send data to server
    if Client.data_to_send.type then
        print("Client sending data:", Client.data_to_send.type)
        server:receive_data(Client.client_id, Client.data_to_send)
        Client.data_to_send = {}
    end

    Client.game_world:update(dt)
    -- for_, golf_ball in ipairs(Client.golf_balls) do
    --     if golf_ball.rolling and not golf_ball:isMoving() then
    --         golf_ball:finish_ball_shoot()
    --     end
    -- end

    if love.mouse.isDown(1) then
        for _, golf_ball in ipairs(Client.golf_balls) do
            golf_ball:aim(Client, love.mouse.getX(), love.mouse.getY())
        end
    end

    server:update(dt) -- Remove once server stands on its own
end

function Client.draw()
    Client.goal:draw()
    -- for _, obstacle in ipairs(Client.obstacles) do
    --     obstacle:draw()
    -- end

    for _, golf_ball in ipairs(Client.golf_balls) do
        golf_ball:display()
    end
    for _, golf_ball in ipairs(server.golf_balls) do
        golf_ball:display()
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("\nCurrent Client: " .. Client.client_id, 10, 10)

    Client.Scoreboard()
end

function Client.Scoreboard()
    love.graphics.setFont(scoreboard_font)

    local scoreboard_posX = love.graphics.getWidth() - 200
    local scoreboard_posY = 20
    local scoreboard_width = 175
    local scoreboard_height = 200

    love.graphics.rectangle("line", scoreboard_posX, scoreboard_posY, scoreboard_width, scoreboard_height, 5, 5)
    love.graphics.print("SCOREBOARD", scoreboard_posX + 10, 30)

    for i = 1, 4 do
        local padding = 20
        local next_height = padding + 40 * i
        love.graphics.print("Client", scoreboard_posX + 10, next_height)
        love.graphics.print(":", scoreboard_posX + 110, next_height)

        love.graphics.print(i, scoreboard_posX + 95, next_height)
        -- TODO: print the scores
        love.graphics.print("0", scoreboard_posX + 120, next_height)
    end

    Client.scoreboard_buttons = {
        show = {
            img = love.graphics.newImage("/assets/img/showButton.png"),
            x = 10,
            y = 10,
            action = function()
                Client.ShowScoreboard()
            end
        },
        hide = {
            img = love.graphics.newImage("/assets/img/hideButton.png"),
            x = 10,
            y = 10,
            action = function()
                Client.ShowScoreboard()
            end
        }
    }

    for _, button in pairs(Client.scoreboard_buttons) do
        button.width = 100
        button.height = 20
    end
end

function Client.ShowScoreboard()
end

function Client.HideScoreboard()
end

---------------------------------------------------

function Client.mousereleased(x, y, button)
    if button ~= 1 then
        return
    end
    Client.current_ball_id = 0
    for _, golf_ball in ipairs(Client.golf_balls) do
        if golf_ball.is_aiming and golf_ball.current_shooter_id == 0 and not golf_ball:isMoving() then
            Client.data_to_send = {
                type = "shoot",
                client_id = Client.client_id,
                data = {
                    ball_id = golf_ball.ball_id,
                    shooting_magnitude = golf_ball.shooting_magnitude,
                    shooting_angle = golf_ball.shooting_angle,
                }
            }
        end
    end
end

-- For testing purposes
function Client.receive_data(pipeline)
    Client.data_received = pipeline
end

-- Once we have an actual server-client architecture, this will be removed (Client id should not ever change)
function Client.keypressed(key)
    if key == "q" then
        Client.client_id = Client.client_id % 4 + 1
    end
end

-- function Client.generate_level()
--     local screen_width = love.graphics.getWidth()
--     local screen_height = love.graphics.getHeight()

--     Client.game_world = love.physics.newWorld(0, 0, true)
--     Client.obstacles_data = server.obstacles_data

--     local golf_ball_data = Client.obstacles_data[1]
--     local goal_data = Client.obstacles_data[2]
--     Client.golf_ball = GolfBall.new(Client.game_world, screen_width * golf_ball_data.x, screen_height * golf_ball_data.y, 10)
--     Client.goal = Goal.new(Client.game_world, screen_width * goal_data.x, screen_height * goal_data.y)

--     Client.obstacles = {}
--     local screen_width = love.graphics.getWidth()
--     local screen_height = love.graphics.getHeight()
--     for i = 3, #Client.obstacles_data do
--         local obstacle_data = Client.obstacles_data[i]
--         table.insert(Client.obstacles, Obstacle.new(Client.game_world, screen_width * obstacle_data.x, screen_height * obstacle_data.y, screen_width * obstacle_data.width, screen_height * obstacle_data.height))
--     end
-- end

function Client.mousepressed(x, y, button)
    -- left click
    if button == 1 then
        for _, btn in pairs(Client.buttons) do
            -- find position
            if x > btn.x and x < btn.x + btn.width and
                y > btn.y and y < btn.y + btn.height then
                -- button function
                btn.action()
            end
        end
    end
end

return Client
