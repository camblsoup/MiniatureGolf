local SceneManager = {
	currentScene = nil,
	currentScenePath = nil,
	port = 5000
}

function SceneManager.loadScene(sceneName)
	assert(type(sceneName) == "string", "Function 'loadScene': first parameter must be a string")
	assert(love.filesystem.getInfo("scenes/" .. sceneName .. ".lua"), "Function: 'loadScene': scene file not found")

	-- unload current scene
	if SceneManager.currentScene and SceneManager.currentScene.unload then
		SceneManager.currentScene.unload()
	end
	if SceneManager.currentScene then
		SceneManager.unloadScene(SceneManager.currentScenePath)
	end

	-- Update current scenes path
	SceneManager.currentScenePath = "scenes/" .. sceneName

	-- load the new scene
	local scene = require(SceneManager.currentScenePath)
	if scene.load then
		scene.load()
	end

	-- set the new scene
	SceneManager.currentScene = scene
end

function SceneManager.unloadScene(sceneName)
	assert(type(sceneName) == "string", "Function 'unloadScene': parameter must be a string")
	assert(love.filesystem.getInfo(sceneName .. ".lua"), "Function 'unloadScene': scene file not found")

	if package.loaded[sceneName] then
		package.loaded[sceneName] = nil
	end
end

function SceneManager.update(dt)
	assert(type(dt) == "number", "Function 'update': parameter must be a number")
	if SceneManager.currentScene and SceneManager.currentScene.update then
		SceneManager.currentScene.update(dt)
	end
end

function SceneManager.draw()
	assert(
		SceneManager.currentScene.draw,
		"Function 'draw': " .. SceneManager.currentScenePath .. "doesn't store a draw function"
	)

	SceneManager.currentScene.draw()
end

function SceneManager.mousepressed(x, y, button)
	if SceneManager.currentScene and SceneManager.currentScene.mousepressed then
		SceneManager.currentScene.mousepressed(x, y, button)
	end
end

function SceneManager.mousereleased(x, y, button)
	if SceneManager.currentScene and SceneManager.currentScene.mousereleased then
		SceneManager.currentScene.mousereleased(x, y, button)
	end
end

function SceneManager.keypressed(key)
	if SceneManager.currentScene and SceneManager.currentScene.keypressed then
		SceneManager.currentScene.keypressed(key)
	end
end

return SceneManager
