local ffi = require('ffi')
local func = require('func')
local misc = require('misc')

local export = {}

function export.encpal(palette)
    return func.join('/', func.map(
        function (i, c) return table.concat(c, ',') end,
        ipairs(palette)
    ))
end

function export.enctile(tile)
    return table.concat(tile, ' ')
end

function export.save(palette, tile)
    local outf = love.filesystem.newFile('savedata.gfx', 'w')
    assert(outf:write('gba-gfx\n'))

    assert(outf:write(export.encpal(palette) .. '\n'))

    assert(outf:write(export.enctile(tile) .. '\n'))

    outf:close()
end

function export.load()
    local inf = love.filesystem.newFile('savedata.gfx', 'r')
    if inf == nil then
        return misc.newpalette(), misc.newtile()
    end

    local nextline = inf:lines()
    if nextline() ~= 'gba-gfx' then
        inf:close()
        return misc.newpalette(), misc.newtile()
    end

    local palette = assert(func.collect(func.map(
        function (part) return func.collect(func.map(tonumber, func.split(',', part))) end,
        func.split('/', nextline())
    )))

    local tile = assert(func.collect(func.map(tonumber, func.split(' ', nextline()))))

    inf:close()
    return palette, tile
end

return export
