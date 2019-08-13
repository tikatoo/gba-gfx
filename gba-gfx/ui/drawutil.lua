
local draw = {}

draw.tpcy_default = {
    {0.2, 0.2, 0.2},
    {0.5, 0.5, 0.5},
}

function draw.tpcy(x, y, cw, ch, nx, ny, tpcy)
    nx = nx or 1
    ny = ny or 1
    tpcy = tpcy or draw.tpcy_default

    love.graphics.setColor(tpcy[1])
    love.graphics.rectangle('fill', x, y, cw * nx, ch * ny)

    local hw = cw / 2
    local hh = ch / 2
    love.graphics.setColor(tpcy[2])
    for cx = 0, nx-1 do
        local acx = x + (cx * cw)
        for cy = 0, ny-1 do
            local acy = y + (cy * ch)
            love.graphics.rectangle('fill', acx, acy + hh, hw, hh)
            love.graphics.rectangle('fill', acx + hw, acy, hw, hh)
        end
    end
end

function draw.gbacolor(c)
    return c[1] / 31, c[2] / 31, c[3] / 31
end

return draw
