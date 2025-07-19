local Client = {
    game_world = nil,
    player = nil,
    golf_ball = nil,
    obstacles = {},
    obstacles_data = {},
    player_id = nil,
}

local Player = require("classes/Player")
local GolfBall = require("classes/GolfBall")
local Obstacle = require("classes/Obstacle")
local Server = require("classes/Server")

local server = nil

function Client.load()
    Client.game_world = love.physics.newWorld(0, 0, true)
    Client.player = Player.new()
    Client.golf_ball = GolfBall.new(Client.game_world, 400, 300, 10)

    server = Server.new()
    table.insert(server.clients, Client)
    Client.player_id = #server.clients
    server:generate_level()
end

function Client.update(dt)
    Client.game_world:update(dt)
    if love.mouse.isDown(1) and not Client.golf_ball:isMoving() then
        local mouse_x, mouse_y = love.mouse.getPosition()
        Client.player:aim(mouse_x, mouse_y, Client.golf_ball)
    end

    server:update(dt) -- Remove once server stands on its own
end

function Client.draw()
    Client.golf_ball:display()
    if Client.player.is_aiming then
        Client.player:display_aim(Client.golf_ball.body:getX(), Client.golf_ball.body:getY())
    end

    for _, obstacle in ipairs(Client.obstacles) do
        obstacle:draw()
    end

    server:draw() -- Remove once server stands on its own
end

function Client.mousereleased(x, y, button)
    if Client.player.is_aiming and button == 1 then
        Client.player:shoot(server, Client.golf_ball) -- Send data to server
    end
end

function Client.generate_level()
    Client.obstacles_data = server.obstacles_data
    for _, obstacle_data in ipairs(Client.obstacles_data) do
        local obstacle = Obstacle.new(Client.game_world, obstacle_data.x, obstacle_data.y, obstacle_data.width, obstacle_data.height)
        table.insert(Client.obstacles, obstacle)
    end
end

function Client.finish_ball_shoot()
    Client.golf_ball.body:setPosition(server.golf_ball.body:getX(), server.golf_ball.body:getY())
    Client.player.mouse_x = 0
    Client.player.mouse_y = 0
    Client.player.shooting_magnitude = 0
    Client.player.shooting_angle = 0
end

return Client