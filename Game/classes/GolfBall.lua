local GolfBall = {}
GolfBall.__index = GolfBall

local VELOCITY_DECREASE = 0.5 -- Decrease velocity over time to simulate friction
local BALL_RADIUS = 10
local VIRTUAL_WIDTH = 192
local VIRTUAL_HEIGHT = 108
local FORCE_SCALE = 150 -- Scale up the force applied to the golf ball

function GolfBall.new(world, id, x, y, audiosource)
	local self = setmetatable({}, GolfBall)

	-- Physics
	self.body = love.physics.newBody(world, x, y, "dynamic")      -- Creates a rigid body for the ball
	self.shape = love.physics.newCircleShape(BALL_RADIUS)         -- Gives the body a circular shape
	self.fixture = love.physics.newFixture(self.body, self.shape, 1) -- Attaches the shape to the body and gives a density of 1
	self.fixture:setUserData("golf_ball")
	self.fixture:setRestitution(1.0)                              -- Makes the balls bounce more
	self.body:setLinearDamping(1)                                 -- Gives the body friction when moving around the world

	-- Communication
	self.ball_id = id
	self.current_shooter_id = 0 -- Locked when id is not 0
	self.color = { 1, 1, 1 }
	self.scored = false

	-- Shooting
	self.is_aiming = false
	self.rolling = false
	self.mouse_x = 0
	self.mouse_y = 0
	self.normalized_mouse_x = 0
	self.normalized_mouse_y = 0
	self.shooting_magnitude = 0
	self.shooting_angle = 0
	self.hit_sfx = audiosource

	return self
end

-- Runs in update()
-- Golf balls wait for their client to click on it
function GolfBall:aim(client, mouse_x, mouse_y)
	if
		self.scored
		or self.current_shooter_id ~= 0
		or self:isMoving()
		or (client.current_ball_id ~= 0 and client.current_ball_id ~= self.ball_id)
	then
		self.is_aiming = false
		return
	end

	local dx = mouse_x - self.body:getX()
	local dy = mouse_y - self.body:getY()
	if not self.is_aiming then
		local initial_magnitude = math.sqrt(dx * dx + dy * dy)
		if initial_magnitude <= self.shape:getRadius() then
			self.is_aiming = true
			client.current_ball_id = self.ball_id
		else
			return
		end
	end

	local scale_x = love.graphics.getWidth() / VIRTUAL_WIDTH
	local scale_y = love.graphics.getHeight() / VIRTUAL_HEIGHT
	local ball_x = self.body:getX() / scale_x
	local ball_y = self.body:getY() / scale_y

	self.mouse_x = mouse_x
	self.mouse_y = mouse_y
	self.normalized_mouse_x = mouse_x / scale_x
	self.normalized_mouse_y = mouse_y / scale_y

	dx = (self.normalized_mouse_x - ball_x) / love.physics.getMeter()
	dy = (self.normalized_mouse_y - ball_y) / love.physics.getMeter()

	self.shooting_angle = math.atan2(dy, dx)
	self.shooting_magnitude = math.sqrt(dx * dx + dy * dy)
	if self.shooting_magnitude > 1.0 then
		self.shooting_magnitude = 1.0
	end
end

function GolfBall:display()
	if self.scored then
		return
	end

	love.graphics.setColor(self.color)
	love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())

	if self.is_aiming and not self:isMoving() then
		love.graphics.setColor(1, 1, 1)
		love.graphics.line(self.mouse_x, self.mouse_y, self.body:getX(), self.body:getY())
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function GolfBall:shoot(force, angle)
	self.hit_sfx:play()
	self.is_aiming = false
	self.rolling = true
	force = force * FORCE_SCALE -- Scale the force applied to the golf ball
	local velocity_y = -force * math.sin(angle)
	local velocity_x = -force * math.cos(angle)
	self.body:applyLinearImpulse(velocity_x, velocity_y)
end

function GolfBall:isMoving()
	local threshold = 5
	local velocity_x, velocity_y = self.body:getLinearVelocity()
	return math.abs(velocity_x) > threshold or math.abs(velocity_y) > threshold
end

function GolfBall:finish_ball_shoot()
	self.current_shooter_id = 0
	self.rolling = false
	self.color = { 1, 1, 1 }
	self.mouse_x = 0
	self.mouse_y = 0
	self.shooting_magnitude = 0
	self.shooting_angle = 0
end

function GolfBall:update_color(color)
	self.color = color
end

return GolfBall
