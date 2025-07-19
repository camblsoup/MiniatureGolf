local GolfBall = {}
GolfBall.__index = GolfBall

local VELOCITY_DECREASE = 0.98 -- Decrease velocity over time to simulate friction

function GolfBall.new(world, x, y, radius, color)
    local self = setmetatable({}, GolfBall)

    self.body = love.physics.newBody(world, x, y, "dynamic")         -- Creates a rigid body for the ball
    self.shape = love.physics.newCircleShape(radius)                 -- Gives the body a circular shape
    self.fixture = love.physics.newFixture(self.body, self.shape, 1) -- Attaches the shape to the body and gives a density of 1
    self.body:setLinearDamping(1)                                    -- Gives the body friction when moving around the world
    self.color = color or {1, 1, 1} -- Testing purposes
    self.is_moving = false

    return self
end

function GolfBall:display()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
end

function GolfBall:isMoving()
    local threshold = 1
    local velocity_x, velocity_y = self.body:getLinearVelocity()
    return math.abs(velocity_x) > threshold or math.abs(velocity_y) > threshold
end

return GolfBall
