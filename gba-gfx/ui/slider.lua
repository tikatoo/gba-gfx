local UIWidget = require('ui.widget')

local UISlider = UIWidget:extend()

function UISlider:init(x, y, w, h)
    UIWidget.init(self, x, y, w, h)
    self.sliding = false
    self.value = nil
    self.block = 10
    self.weight = 2
    self.colors = {
        {0.4, 0.4, 0.4},
        {0.8, 0.8, 0.8}
    }
    function self.onchange(value) end
end

function UISlider:draw()
    if self.value == nil then
        love.graphics.setColor(self.colors[1])
    else
        love.graphics.setColor(self.colors[2])
    end

    local hblock = self.block / 2
    love.graphics.setLineWidth(self.weight)
    love.graphics.line(hblock, self.h / 2, self.w - hblock, self.h / 2)

    if self.value ~= nil then
        love.graphics.rectangle(
            'fill', (self.w - self.block) * self.value, 0,
            self.block, self.h
        )
    end
end

function UISlider:slide(x)
    self.value = (x - self.block / 2) / (self.w - self.block)
    if self.value < 0 then self.value = 0
    elseif self.value > 1 then self.value = 1
    end
    local v = self.onchange(self.value)
    if v ~= nil then self.value = v end
end

function UISlider:mousepressed(x, y, btn, istouch, presses)
    if UIWidget.mousepressed(self, x, y, btn, istouch, presses) then
        return true
    end

    if btn == 1 and self.value ~= nil then
        self.sliding = true
        self:slide(x)
        return true
    end
end

function UISlider:mousereleased(x, y, btn, istouch, presses)
    if UIWidget.mousereleased(self, x, y, btn, istouch, presses) then
        return true
    end

    if btn == 1 and self.sliding then
        self.sliding = false
        return true
    end
end

function UISlider:mousemoved(x, y, dx, dy, istouch)
    if UIWidget.mousemoved(self, x, y, dx, dy, istouch) then
        return true
    end

    if self.sliding then
        self:slide(x)
        return true
    end
end

return UISlider
