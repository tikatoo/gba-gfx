local export = require('export')
local UIRoot = require('ui')
local UIWidget = require('ui.widget')
local UIPalette = require('ui.palette')
local UIPicker = require('ui.picker')
local UICanvas = require('ui.canvas')
local draw = require('ui.drawutil')

local ui = nil
local data = nil

function love.load()
    ui = UIRoot:new()
    ui:add(UIWidget:new(0, 0)).background = {0.15, 0.15, 0.15}

    local palettes = ui:add(UIPalette:new(40, 40, 16))
    local palette = ui:add(UIPalette:new(
        palettes.x + palettes.w + palettes.scale, palettes.y,
        palettes.scale
    ))
    local picker = ui:add(UIPicker:new(
        palette.x + palette.w + palette.scale, palette.y,
        -palettes.x, palette.h
    ))
    local canvas = ui:add(UICanvas:new(
        palette.x, palette.y + palette.h + 32,
        960, 640, 10
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
    while #data.palettes < 16 do
        table.insert(data.palettes, export.palette())
    end
    if #data.tiles < 1 then
        table.insert(data.tiles, export.tile())
    end
    if #data.objs < 1 then
        table.insert(data.objs, { w = 1, h = 1, palette = 0, tile = 0 })
    end

    local objid = 1
    function palettes.onselect(n)
        local selpal = data.palettes[n + 1]
        palette.palette = selpal
        canvas.palette = selpal
        data.objs[objid].palette = n
        palette:select(palette.selected)
    end
    function palette.onselect(n)
        picker:setcolor(palette.palette[n])
        canvas.selected = n
    end

    palettes.palettes = data.palettes
    local obj = data.objs[objid]
    canvas:setobj(obj, data.tiles)
    palettes:select(obj.palette)
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
