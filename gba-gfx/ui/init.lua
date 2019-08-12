local UIWidget = require('ui.widget')

local UIRoot = UIWidget:extend()

function UIRoot:init()
    UIWidget.init(self, 0, 0, love.graphics.getDimensions())
end

return UIRoot
