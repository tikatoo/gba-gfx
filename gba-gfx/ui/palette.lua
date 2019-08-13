local UIWidget = require('ui.widget')
local draw = require('ui.drawutil')
local export = require('export')

local UIPallete = UIWidget:extend()

function UIPallete:init(x, y, scale)
    UIWidget.init(self, x, y, 4 * scale, 4 * scale)
    self.scale = scale
    self.palette = nil
    self.palettes = nil
    self.selected = 0
    function self.onselect(n) end
end

function UIPallete:select(n)
    self.selected = n
    self.onselect(n)
end

local function drawpalette(palette, s)
    if s < 8 then
        love.graphics.setColor(draw.tpcy_default[2])
        love.graphics.rectangle('fill', 0, 0, s, s)
    else
        draw.tpcy(0, 0, s, s)
    end
    for i, c in ipairs(palette) do
        local x = i % 4
        local y = (i - x) / 4
        love.graphics.setColor(draw.gbacolor(c))
        love.graphics.rectangle('fill', x * s, y * s, s, s)
    end
end

function UIPallete:draw()
    local s = self.scale
    if self.palette ~= nil then
        -- Main palette
        drawpalette(self.palette, s)
    elseif self.palettes ~= nil then
        -- Full palette set
        local qs = s / 4
        love.graphics.push()
        love.graphics.setLineWidth(1)
        for i = 1, 16 do
            local palette = self.palettes[i]
            if palette == nil then
                palette = export.palette()
            end
            drawpalette(palette, qs)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle('line', 0, 0, s, s)
            if i % 4 == 0 then
                love.graphics.translate(-(s*3), s)
            else
                love.graphics.translate(s, 0)
            end
        end
        love.graphics.pop()
    else
        -- No palette!
        return
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
        self:select(
            math.floor(x / self.scale)
            + (4 * math.floor(y / self.scale))
        )
        return true
    end
end

return UIPallete
