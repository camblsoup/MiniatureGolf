local Renderer = {}
Renderer.__index = Renderer

function Renderer.new()
	local self = setmetatable({}, Renderer)

	self.canvas = love.graphics.newCanvas(192, 108)
	self.width = 192
	self.heigh = 108

	return self
end

function Renderer:renderFrom(func)
	self.canvas:renderTo(func)
end

return Renderer
