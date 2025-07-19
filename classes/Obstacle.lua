local Obstacle = {}
Obstacle.__index = Obstacle

function Obstacle.new(world, x, y, width, height)
    local self = setmetatable({}, Obstacle)

    self.body = love.physics.newBody(world, x, y, "static")
    self.shape = love.physics.newRectangleShape(width, height)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.8)

    return self
end

function Obstacle:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

return Obstacle
