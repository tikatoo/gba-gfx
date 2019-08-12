local UIWidget = require('ui.widget')
local draw = require('ui.drawutil')

local UIPallete = UIWidget:extend()

function UIPallete:init(x, y, scale)
    UIWidget.init(self, x, y, 4 * scale, 4 * scale)
    self.scale = scale
    self.palette = nil
    self.selected = 0
    function self.onselect(n) end
end

function UIPallete:draw()
    if self.palette == nil then return end

    local s = self.scale
    draw.tpcy(0, 0, s, s)

    for i, c in ipairs(self.palette) do
        local x = i % 4
        local y = (i - x) / 4
        love.graphics.setColor(draw.gbacolor(c))
        love.graphics.rectangle('fill', x * s, y * s, s, s)
    end

    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', 0, 0, self.w, self.h)

    love.graphics.setLineWidth(3)
    love.graphics.setColor(1, 1, 1)
    local x = self.selected % 4
    local y = (self.selected - x) / 4
    love.graphics.rectangle('line', x * s, y * s, s, s)
end

function UIPallete:mousepressed(x, y, btn, istouch, presses)
    if UIWidget.mousepressed(self, x, y, btn, istouch, presses) then
        return true
    end

    if btn == 1 then
        self.selected =
            math.floor(x / self.scale)
            + (4 * math.floor(y / self.scale))
        self.onselect(self.selected)
        return true
    end
end

return UIPallete
