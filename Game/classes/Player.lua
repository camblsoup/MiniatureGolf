-- OBSOLETE

local Player = {}
Player.__index = Player

function Player.new()
    local self = setmetatable({}, Player)

    self.score = 0

    -- Calculated when aiming
    self.is_aiming = false
    self.mouse_x = 0
    self.mouse_y = 0
    self.normalized_mouse_x = 0
    self.normalized_mouse_y = 0
    self.shooting_magnitude = 0
    self.shooting_angle = 0

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

    local scale_x = love.graphics.getWidth() / VIRTUAL_WIDTH
    local scale_y = love.graphics.getHeight() / VIRTUAL_HEIGHT

    self.mouse_x = mouse_x
    self.mouse_y = mouse_y
    self.normalized_mouse_x = mouse_x / scale_x
    self.normalized_mouse_y = mouse_y / scale_y

    local dx = (self.mouse_x - golf_ball.body:getX())
    local dy = (self.mouse_y - golf_ball.body:getY())

    self.shooting_angle = math.atan2(dy, dx)

    local ball_x = golf_ball.body:getX() / scale_x
    local ball_y = golf_ball.body:getY() / scale_y

    dx = (self.normalized_mouse_x - ball_x) / love.physics.getMeter()
    dy = (self.normalized_mouse_y - ball_y) / love.physics.getMeter()

    self.shooting_magnitude = math.sqrt(dx * dx + dy * dy)
    if self.shooting_magnitude > 1.0 then
        self.shooting_magnitude = 1.0
    end
end

function Player:display_aim(golf_ball_x, golf_ball_y)
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(self.mouse_x, self.mouse_y, golf_ball_x, golf_ball_y)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Called when player releases the mouse button
function Player:shoot(server, golf_ball)
    self.is_aiming = false
    local force = self.shooting_magnitude * FORCE_SCALE
    local angle = self.shooting_angle
    local velocity_x = -force * math.cos(angle)
    local velocity_y = -force * math.sin(angle)
    golf_ball.body:applyLinearImpulse(velocity_x, velocity_y)

    server:launch_ball(velocity_x, velocity_y)
end

function Player:finish_ball_shoot()
    self.mouse_x = 0
    self.mouse_y = 0
    self.shooting_magnitude = 0
    self.shooting_angle = 0
end

return Player
