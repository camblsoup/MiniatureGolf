local Player = {}
Player.__index = Player

function Player.new()
    local self = setmetatable({}, Player)

    self.score = 0

    -- Calculated when aiming
    self.is_aiming = false
    self.mouse_x = 0
    self.mouse_y = 0
    self.magnitude = 0
    self.angle = 0

    return self
end

-- Called when player holds mouse1 on golf ball
function Player:aim(mouse_x, mouse_y, golf_ball)
    -- Initial click, prevent aiming if the player doesn't click on the golf ball
    if not self.is_aiming then
        local dx = mouse_x - golf_ball.body:getX()
        local dy = mouse_y - golf_ball.body:getY()

        local initial_magnitude = math.sqrt(dx * dx + dy * dy)
        if initial_magnitude <= golf_ball.shape:getRadius() then
            self.is_aiming = true
        else
            return
        end
    end

    local dx = mouse_x - golf_ball.body:getX()
    local dy = mouse_y - golf_ball.body:getY()

    self.mouse_x = mouse_x
    self.mouse_y = mouse_y
    self.magnitude = math.sqrt(dx * dx + dy * dy) * 400
    if self.magnitude > 200000 then
        self.magnitude = 200000
    end
    self.angle = math.atan2(dy, dx)
end

function Player:display_aim(golf_ball_x, golf_ball_y)
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(self.mouse_x, self.mouse_y, golf_ball_x, golf_ball_y)
end

-- Called when player releases the mouse button
function Player:shoot()
    -- SEND DATA TO SERVER

    self.is_aiming = false
    self.mouse_x = 0
    self.mouse_y = 0
    self.magnitude = 0
    self.angle = 0
end

return Player
