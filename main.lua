package.path = package.path .. ";./?.lua"
local menu = require("menu_functions")

function love.draw()
    menu.title()
end
