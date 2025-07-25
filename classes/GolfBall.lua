local GolfBall = {}
GolfBall.__index = GolfBall

local VELOCITY_DECREASE = 0.98 -- Decrease velocity over time to simulate friction
local colors = {
    {1, 0, 0},
    {0, 1, 0},
    {0, 0, 1},
    {1, 1, 0},
}

function GolfBall.new(world, x, y, radius, server_ball)
    local self = setmetatable({}, GolfBall)

    self.body = love.physics.newBody(world, x, y, "dynamic")         -- Creates a rigid body for the ball
    self.shape = love.physics.newCircleShape(radius)                 -- Gives the body a circular shape
    self.fixture = love.physics.newFixture(self.body, self.shape, 1) -- Attaches the shape to the body and gives a density of 1
    self.body:setLinearDamping(1)                                    -- Gives the body friction when moving around the world
    self.color = colors[1]
    self.is_moving = false
    self.server_ball = server_ball or false -- Flag to indicate if this is a server-side ball

    return self
end

function GolfBall:display()
    if not self.server_ball then
        love.graphics.setColor(self.color)
        love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
    else
        -- For testing purposes
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", self.body:getX(), self.body:getY(), self.shape:getRadius())
    end
end

function GolfBall:isMoving()
    local threshold = 1
    local velocity_x, velocity_y = self.body:getLinearVelocity()
    return math.abs(velocity_x) > threshold or math.abs(velocity_y) > threshold
end

function GolfBall:update_color(current_shooter_id)
    self.color = colors[current_shooter_id]
end

return GolfBall
