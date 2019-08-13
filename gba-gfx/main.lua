local export = require('export')
local UIRoot = require('ui')
local UIShow = require('ui.show')
local UIPalette = require('ui.palette')
local UIPicker = require('ui.picker')
local UICanvas = require('ui.canvas')
local draw = require('ui.drawutil')

local ui = nil
local data = nil

function love.load()
    ui = UIRoot:new()
    ui:add(UIShow:new({0.15, 0.15, 0.15}))
    local palette = ui:add(UIPalette:new(40, 40, 16))
    local picker = ui:add(UIPicker:new(
        palette.x + palette.w + palette.scale, palette.y,
        -palette.x, palette.h
    ))
    local canvas = ui:add(UICanvas:new(
        40, 40 + 4 * palette.scale + 40, 16
    ))

    local errmsg
    data, errmsg = export.load('savedata.gfx')
    if data == nil then
        print('load error', errmsg)
        if love.filesystem.getInfo('savedata.gfx', 'file') ~= nil then
            -- The file exists, but is broken.
            -- Give users the chance to fix the file.
            local savedir = love.filesystem.getSaveDirectory()
            love.filesystem.remove('savedata.bad.gfx')
            os.rename(savedir .. '/savedata.gfx', savedir .. '/savedata.bad.gfx')
        end
        -- Just continue anyway, with blank data.
        data = {
            settings = {},
            palettes = {},
            tiles = {},
            objs = {},
        }
    end
    if #data.palettes < 1 then
        table.insert(data.palettes, export.palette())
    end
    if #data.tiles < 1 then
        table.insert(data.tiles, export.tile())
    end
    if #data.objs < 1 then
        table.insert(data.objs, { w = 1, h = 1, palette = 0, tile = 0 })
    end

    local obj = data.objs[1]

    palette.palette = data.palettes[obj.palette + 1]
    canvas:settile(data.tiles[obj.tile + 1])
    canvas.palette = palette.palette
    canvas.selected = palette.selected
    function palette.onselect(n)
        picker:setcolor(palette.palette[n])
        canvas.selected = n
    end
end

function love.quit()
    export.save('savedata.gfx', data)
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
