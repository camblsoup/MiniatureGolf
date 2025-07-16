local SceneManager = {
    currentScene = nil
}

function SceneManager.loadScene(sceneName)
    -- unload current scene
    if SceneManager.currentScene and SceneManager.currentScene.unload then
        SceneManager.currentScene.unload()
    end 

    -- load the new scene
    local scene = require("scenes/" .. sceneName)
    if scene.load then
        scene.load()
    end

    -- set the new scene
    SceneManager.currentScene = scene
end

function SceneManager.update(dt)
    if SceneManager.currentScene and SceneManager.currentScene.update then
        SceneManager.currentScene.update(dt)
    end
end

function SceneManager.draw()
    if SceneManager.currentScene and SceneManager.currentScene.draw then
        SceneManager.currentScene.draw()
    end
end

function SceneManager.mousepressed(x, y, button)
    if SceneManager.currentScene and SceneManager.currentScene.mousepressed then
        SceneManager.currentScene.mousepressed(x, y, button)
    end
end
 
return SceneManager