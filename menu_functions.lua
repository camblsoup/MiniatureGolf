local menu = {}

function menu.title()
    local width  = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    love.graphics.printf("MINIATURE GOLF", 0, height / 2, width, "center")
end

return menu;
