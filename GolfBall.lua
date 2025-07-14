local GolfBall = {}
GolfBall.__index = GolfBall

function GolfBall.new(x, y, radius)
    local self = setmetatable({}, GolfBall)

    self.x = x
    self.y = y
    self.radius = radius or 10

    return self
end

function GolfBall:display()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

return GolfBall