local GolfBall = {}
GolfBall.__index = GolfBall

local VELOCITY_DECREASE = 0.98 -- Decrease velocity over time to simulate friction

function GolfBall.new(x, y, radius)
    local self = setmetatable({}, GolfBall)

    self.x = x
    self.y = y
    self.radius = radius

    self.is_moving = false
    self.velocity_x = 0
    self.velocity_y = 0

    return self
end

function GolfBall:roll()
    self.x = self.x + self.velocity_x
    self.y = self.y + self.velocity_y
    self.velocity_x = self.velocity_x * VELOCITY_DECREASE
    self.velocity_y = self.velocity_y * VELOCITY_DECREASE

    if math.abs(self.velocity_x) < 0.1 and math.abs(self.velocity_y) < 0.1 then
        self.is_moving = false -- Stop moving if velocity is very low
        self.velocity_x = 0
        self.velocity_y = 0
        print("Golf ball stopped moving")
    end
end

function GolfBall:display()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

return GolfBall