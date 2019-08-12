local export = require('export')
local UIRoot = require('ui')
local UIShow = require('ui.show')
local UIPalette = require('ui.palette')
local UIPicker = require('ui.picker')
local UICanvas = require('ui.canvas')
local draw = require('ui.drawutil')

local ui = nil

function love.load()
    ui = UIRoot:new()
    ui:add(UIShow:new({0.15, 0.15, 0.15}))
    local palette = ui:add(UIPalette:new(40, 40, 20))
    local picker = ui:add(UIPicker:new(
        palette.x + palette.w + palette.scale, palette.y,
        -palette.x, palette.h
    ))
    local canvas = ui:add(UICanvas:new(
        40, 40 + 4 * palette.scale + 40, 16
    ))

    local settings, palettes, tiles = export.load()
    if settings == nil then
        -- palettes is the error message
        print('load error', palettes)
        -- Just continue anyway, with blank file.
        palettes = {}
        tiles = {}
    end
    if #palettes < 1 then
        table.insert(palettes, export.palette())
    end
    if #tiles < 1 then
        table.insert(tiles, export.tile())
    end

    palette.palette = palettes[1]
    canvas:settile(tiles[1])
    canvas.palette = palette.palette
    canvas.selected = palette.selected
    function palette.onselect(n)
        picker:setcolor(palette.palette[n])
        canvas.selected = n
    end

    ui.palette = palette
    ui.canvas = canvas
end

function love.quit()
    export.save({}, {ui.palette.palette}, {ui.canvas.tile})
end

function love.update(dt)
    ui:do_update(dt)
end

function love.draw()
    ui:do_draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    ui:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    ui:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    ui:mousemoved(x, y, dx, dy, istouch)
end
