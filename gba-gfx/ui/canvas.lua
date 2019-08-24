local UIWidget = require('ui.widget')
local draw = require('ui.drawutil')
local sprites = require('sprites')

local UICanvas = UIWidget:extend()
function UICanvas:init(x, y, w, h, scale)
    UIWidget.init(self, x, y, w, h)
    self.scale = scale
    self.obj = nil
    self.selected = 0
    self.tileundo = nil
    self.tilestroke = nil
    self.painting = false
    self.changed = false
    self.onchange = nil
end

function UICanvas:setobj(obj)
    self.obj = obj or self.obj
    if self.obj == nil then return end

    self.changed = false
    self.tileundo = {}
    self.tilestroke = {}
    for i = 1, self.obj.w * self.obj.h do
        table.insert(self.tileundo, sprites.newtile())
        table.insert(self.tilestroke, sprites.newtile(false))
    end
end

local function tileiter(w, h)
    local max = w * h
    return function (s, i)
        i = i + 1
        if i >= max then return nil end
        local x = i % w
        local y = (i - x) / w
        return i, x, y
    end, nil, -1
end

function UICanvas:draw()
    if self.obj == nil then return end

    local s = self.scale
    local obj = self.obj
    local palette = obj.palettes[obj.palette + 1]

    draw.tpcy(0, 0, s, s, 8 * obj.w, 8 * obj.h)
    for i, tx, ty in tileiter(obj.w, obj.h) do
        local tpx = 8 * s * tx
        local tpy = 8 * s * ty
        for j, v in ipairs(obj.tiles[obj.tile + i + 1]) do
            if v > 0 then
                j = j - 1
                local x = j % 8
                local y = (j - x) / 8
                local c = palette[v]
                love.graphics.setColor(draw.gbacolor(c))
                love.graphics.rectangle(
                    'fill', tpx + x * s, tpy + y * s, s, s
                )
            end
        end
    end

    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'line', 0, 0, 8 * s * obj.w, 8 * s * obj.h
    )
end

function UICanvas:paint(x, y)
    local xg = math.floor(x / self.scale)
    local yg = math.floor(y / self.scale)
    if xg >= 0 and xg < 8 * self.obj.w and
       yg >= 0 and yg < 8 * self.obj.h then
        local inx = xg % 8
        local iny = yg % 8
        local inidx = inx + (8 * iny) + 1
        local tx = (xg - inx) / 8
        local ty = (yg - iny) / 8
        local tidx = tx + self.obj.w * ty + 1
        local tile = self.obj.tiles[tidx]
        local tileundo = self.tileundo[tidx]
        local tilestroke = self.tilestroke[tidx]
        if tilestroke[inidx] then return end
        tilestroke[inidx] = true
        if self.painting == 'paint' then
            if tile[inidx] == self.selected then return end
            tileundo[inidx] = tile[inidx]
            tile[inidx] = self.selected
        elseif self.painting == 'undo' then
            local current = tile[inidx]
            tile[inidx] = tileundo[inidx]
            tileundo[inidx] = current
        end

        if not self.changed then
            self.changed = true
            if self.onchange ~= nil then
                self.onchange()
            end
        end
    end
end

function UICanvas:mousepressed(x, y, btn, istouch, presses)
    if UIWidget.mousepressed(self, x, y, btn, istouch, presses) then
        return true
    elseif self.obj == nil then
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
        self.tilestroke = {}
        for i = 1, #self.tileundo do
            table.insert(self.tilestroke, sprites.newtile(false))
        end
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
