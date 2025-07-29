local Goal = {}
Goal.__index = Goal

local RADIUS = 30

function Goal.new(world, x, y)
    local self = setmetatable({}, Goal)

    self.body = love.physics.newBody(world, x, y, "static")
    self.shape = love.physics.newCircleShape(RADIUS)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.8)

    return self
end

function Goal:draw()
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
end

function Goal:check_reached(golf_ball_body)
    return self.body:isTouching(golf_ball_body)
end

return Goal
