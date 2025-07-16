package.path = package.path .. ";./?.lua"

local SM = require("lib.SceneManager")
local Renderer = require("lib.Renderer")

function love.load()
	SM.loadScene("MainMenu")
	Renderer = Renderer.new()
	love.graphics.setCanvas(Renderer.canvas)
end

function love.update(dt)
	SM.update(dt)
end

function love.draw()
	SM.draw()
end

function love.mousepressed(x, y, button)
	SM.mousepressed(x, y, button)
end
