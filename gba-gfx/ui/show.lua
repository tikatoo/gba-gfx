local UIWidget = require('ui.widget')

local UIShow = UIWidget:extend()

function UIShow:init(x, y, w, h, color)
    if type(x) == 'table' then
        color = x
        x = 0 y = 0
        w = nil h = nil
    end
    UIWidget.init(self, x, y, w, h)
    self.color = color or {0, 0, 0, 0}
end

function UIShow:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', 0, 0, self.w, self.h)
end

return UIShow
