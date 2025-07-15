local funcDefined
local SceneManager = {}
SceneManager.__index = SceneManager

function SceneManager.new()
    local self = setmetatable({}, SceneManager)

    self.scene = nil
    self.sceneFolder = nil
    self.dir = nil
    
    return self
end

function SceneManager.setScenesPath(path)
    
end

function SceneManager.load(path)
    if not self.sceneFolder then
        if love.filesystem.exists(path) then
            self.scene = require(path)

            if (funcDefined(path)) then
                self.scene.load()
            end
        end
    else
        path = self.sceneFolder .. path
        if love.filesystem.exists(path) then
            self.scene = require(path)

            if (funcDefined(path)) then
                self.scene.load()
            end
        end
    end
end

funcDefined = function (func)
    if self.scene[func] then
        if type(self.scene[func]) == "function" then
            return true
        else
            error("in: " .. self.scene .. ", " .. func .. " must be a function")
        end
    else 
        error("in: " .. self.scene .. ", " .. func .. " must be a function")
    end
        
    end
    
end