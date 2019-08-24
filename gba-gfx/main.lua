local sprites = require('sprites')
local UIRoot = require('ui')
local UIWidget = require('ui.widget')
local UIPalette = require('ui.palette')
local UIPicker = require('ui.picker')
local UICanvas = require('ui.canvas')
local draw = require('ui.drawutil')

local ui = nil
local data = nil

function love.load()
    local img = {
        shape = {
            love.graphics.newImage('res/shape-square.png'),
            love.graphics.newImage('res/shape-horz.png'),
            love.graphics.newImage('res/shape-vert.png'),
        },
        size = {
            love.graphics.newImage('res/size-s.png'),
            love.graphics.newImage('res/size-m.png'),
            love.graphics.newImage('res/size-l.png'),
            love.graphics.newImage('res/size-x.png'),
        },
    }

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

    local shapebtn = ui:add(UIWidget:new(
        palette.x + 4, palette.y + palette.h + 8, 16, 16
    ))
    local sizebtn = ui:add(UIWidget:new(
        shapebtn.x + shapebtn.w * 2, shapebtn.y, 16, 16
    ))

    function shapebtn:setshape(shape)
        self.background = img.shape[shape + 1]
    end
    function sizebtn:setsize(size)
        self.background = img.size[size + 1]
    end

    local file, errmsg = love.filesystem.newFile('savedata.gfx', 'r')
    if file == nil then
        print('load error', errmsg)
    else
        data, errmsg = sprites.load(file:lines())
        if data == nil then
            print('load error', errmsg)
            -- The file exists, but is broken.
            -- Give users the chance to fix the file.
            local savedir = love.filesystem.getSaveDirectory()
            love.filesystem.remove('savedata.bad.gfx')
            os.rename(savedir .. '/savedata.gfx', savedir .. '/savedata.bad.gfx')
        end
        file:close()
    end
    if data == nil then
        -- Just continue anyway, with blank data.
        data = sprites.load()
    end

    if #data.objs < 1 then
        data:newsprite()
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
    function canvas.onchange()
        data.objs[objid].original = nil
    end
    function shapebtn:mousereleased(x, y, btn)
        if btn == 1 then
            local obj = data.objs[objid]
            obj:resize((obj.shape + 1) % 3)
            canvas:setobj(obj)
            self:setshape(obj.shape)
        end
    end
    function sizebtn:mousereleased(x, y, btn)
        if btn == 1 then
            local obj = data.objs[objid]
            obj:resize(obj.shape, (obj.size + 1) % 4)
            canvas:setobj(obj)
            self:setsize(obj.size)
        end
    end

    palettes.palettes = data.palettes
    local obj = data.objs[objid]
    canvas:setobj(obj, data.tiles)
    palettes:select(obj.palette)
    shapebtn:setshape(obj.shape)
    sizebtn:setsize(obj.size)
end

function love.quit()
    local file = assert(love.filesystem.newFile('savedata.gfx', 'w'))
    assert(data:encode(function (line) return file:write(line .. '\n') end))
    file:close()
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
