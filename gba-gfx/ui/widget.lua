local class = require('class')

local UIWidget = class:extend()

function UIWidget:init(x, y, w, h)
    self.parent = nil
    self.children = {}
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.focus = nil
    self.transform = nil
    self.background = nil
    self._mouseactive = nil
    if parent ~= nil then
        parent:add(self)
    end
end

function UIWidget:_reflow()
    if self.parent == nil then return end
    
    local didrew = false
    if self.parent.w ~= nil and self.parent.w >= 0 then
        didrew = true
        if self.w == nil then self.w = self.parent.w - self.x
        elseif self.w < 0 then self.w = self.parent.w + self.w - self.x
        else didrew = false
        end
    end
    
    local didreh = false
    if self.parent.h ~= nil and self.parent.h >= 0 then
        didreh = true
        if self.h == nil then self.h = self.parent.h - self.y
        elseif self.h < 0 then self.h = self.parent.h + self.h - self.y
        else didreh = false
        end
    end
    
    if didrew or didreh then
        for i, child in ipairs(self.children) do
            child:_reflow()
        end
    end
end

function UIWidget:add(child)
    child.parent = self
    child:_reflow()
    table.insert(self.children, child)
    return child
end

function UIWidget:do_update(dt)
    self:update(dt)
    for i, child in ipairs(self.children) do
        child:do_update(dt)
    end
end

function UIWidget:do_draw()
    love.graphics.push('all')
    if self.transform ~= nil then
        love.graphics.applyTransform(self.transform)
    else
        love.graphics.translate(self.x, self.y)
    end

    self:draw()
    for i, child in ipairs(self.children) do
        child:do_draw()
    end

    love.graphics.pop()
end

function UIWidget:update(dt) end

function UIWidget:draw()
    if self.background == nil then return end

    if type(self.background.typeOf) == 'function' then
        if self.background:typeOf('Texture') then
            local bw, bh = self.background:getPixelDimensions()
            local sx = 1
            local sy = 1
            local bx = 0
            local by = 0
            if self.w < bw then sx = self.w / bw
            else bx = (self.w / 2) - (bw / 2)
            end
            if self.h < bh then sy = self.h / bh
            else by = (self.h / 2) - (bh / 2)
            end
            love.graphics.draw(self.background, bx, by, 0, sx, sy)
        elseif self.background:typeOf('Drawable') then
            love.graphics.draw(self.background)
        end
    elseif type(self.background) == 'table' then
        love.graphics.setColor(self.background)
        love.graphics.rectangle('fill', 0, 0, self.w, self.h)
    end
end

local function revpairs(t)
    return function (s, var)
        var = var - 1
        if var == 0 then return nil end
        return var, s[var]
    end, t, #t + 1
end

function UIWidget:findchild(x, y, deep)
    for i, child in revpairs(self.children) do
        local rx = x - child.x
        local ry = y - child.y
        if rx >= 0 and rx < child.w and ry >= 0 and ry < child.h then
            if deep then
                return child:findchild(rx, ry)
            else
                return child, rx, ry
            end
        end
    end

    return self, x, y
end

function UIWidget:mousepressed(x, y, button, istouch, presses)
    if self._mouseactive then return false end
    self._mouseactive = button
    local child, rx, ry = self:findchild(x, y)
    self.focus = child
    if child == self then
        return false
    else
        return child:mousepressed(rx, ry, button, istouch, presses)
    end
end

function UIWidget:mousereleased(x, y, button, istouch, presses)
    if button ~= self._mouseactive then return false end
    local child = self.focus
    self.focus = nil
    self._mouseactive = nil
    if child == self then
        return false
    else
        local rx = x - child.x
        local ry = y - child.y
        return child:mousereleased(rx, ry, button, istouch, presses)
    end
end

function UIWidget:mousemoved(x, y, dx, dy, istouch)
    local child = self.focus
    if child == nil then
        child = self:findchild(x, y)
    end

    if child == self then
        return false
    else
        local rx = x - child.x
        local ry = y - child.y
        return child:mousemoved(rx, ry, dx, dy, istouch)
    end
end

function UIWidget:wheelmoved(x, y, atx, aty)
    local child = self.focus
    if child == nil then
        child, atx, aty = self:findchild(atx, aty)
    end

    if child == self then
        return false
    else
        return child:wheelmoved(x, y, atx, aty)
    end
end

return UIWidget
