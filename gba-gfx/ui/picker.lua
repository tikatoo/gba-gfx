require('extmath')
local UIWidget = require('ui.widget')
local UISlider = require('ui.slider')
local draw = require('ui.drawutil')

local UIPicker = UIWidget:extend()

function UIPicker:init(x, y, w, h)
    UIWidget.init(self, x, y, w, h)
    local sliderh = h / 4
    self.sliders = {
        self:add(UISlider:new(sliderh * 3, 0 * sliderh, nil, sliderh)),
        self:add(UISlider:new(sliderh * 3, 1.5 * sliderh, nil, sliderh)),
        self:add(UISlider:new(sliderh * 3, 3 * sliderh, nil, sliderh)),
    }
    for i, slider in ipairs(self.sliders) do
        function slider.onchange(value)
            self.color[i] = math.round(value * 31)
            return self.color[i] / 31
        end
    end
    self.color = nil
end

function UIPicker:setcolor(c)
    self.color = c
    if c == nil then
        self.sliders[1].value = nil
        self.sliders[2].value = nil
        self.sliders[3].value = nil
    else
        self.sliders[1].value = c[1] / 31
        self.sliders[2].value = c[2] / 31
        self.sliders[3].value = c[3] / 31
    end
end

function UIPicker:draw()
    local ps = self.h / 2
    local pp = ps / 2

    if self.color == nil then
        draw.tpcy(0, pp, ps, ps)
    else
        love.graphics.setColor(draw.gbacolor(self.color))
        love.graphics.rectangle('fill', 0, pp, ps, ps)
    end
end

return UIPicker
