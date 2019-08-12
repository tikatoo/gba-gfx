local UIWidget = require('ui.widget')
local draw = require('ui.drawutil')

local UICanvas = UIWidget:extend()
function UICanvas:init(x, y, scale)
    UIWidget.init(self, x, y, 8 * scale, 8 * scale)
    self.scale = scale
    self.tile = nil
    self.tileundo = export.tile()
    self.tilestroke = export.tile(nil, false)
    self.palette = nil
    self.selected = 0
    self.painting = false
end

function UICanvas:settile(tile)
    self.tile = tile
    self.tileundo = export.tile()
end

function UICanvas:draw()
    if self.tile == nil or self.palette == nil then return end

    local s = self.scale

    draw.tpcy(0, 0, s, s, 8, 8)
    for i, v in ipairs(self.tile) do
        i = i - 1
        local x = i % 8
        local y = (i - x) / 8
        if v > 0 then
            local c = self.palette[v]
            love.graphics.setColor(draw.gbacolor(c))
            love.graphics.rectangle('fill', x * s, y * s, s, s)
        end
    end

    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', 0, 0, 8 * s, 8 * s)
end

function UICanvas:paint(x, y)
    local xg = math.floor(x / self.scale)
    local yg = math.floor(y / self.scale)
    if xg >= 0 and xg < 8 and yg >= 0 and yg < 8 then
        local idx = xg + (8 * yg) + 1
        if self.tilestroke[idx] then return end
        self.tilestroke[idx] = true
        if self.painting == 'paint' then
            if self.tile[idx] == self.selected then return end
            self.tileundo[idx] = self.tile[idx]
            self.tile[idx] = self.selected
        elseif self.painting == 'undo' then
            local current = self.tile[idx]
            self.tile[idx] = self.tileundo[idx]
            self.tileundo[idx] = current
        end
    end
end

function UICanvas:mousepressed(x, y, btn, istouch, presses)
    if UIWidget.mousepressed(self, x, y, btn, istouch, presses) then
        return true
    elseif self.tile == nil or self.palette == nil then
        return false
    elseif btn == 1 and not self.painting then
        self.painting = 'paint'
        self:paint(x, y)
        return true
    elseif btn == 2 and not self.painting then
        self.painting = 'undo'
        self:paint(x, y)
        return true
    end
end

function UICanvas:mousereleased(x, y, btn, istouch, presses)
    if UIWidget.mousereleased(self, x, y, btn, istouch, presses) then
        return true
    end

    if btn == 1 or btn == 2 then
        self.painting = false
        self.tilestroke = export.tile(nil, false)
    end
end

function UICanvas:mousemoved(x, y, dx, dy, istouch)
    if UIWidget.mousemoved(self, x, y, dx, dy, istouch) then
        return true
    end

    if self.painting then
        self:paint(x, y)
        return true
    end
end

return UICanvas
