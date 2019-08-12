local ffi = require('ffi')

local export = {}

function export.palette(palette)
    if palette == nil then
        return {
            {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
            {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
            {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
            {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {31, 31, 31},
        }
    elseif type(palette) == 'table' then
        -- Encoding palette
        local encoded = ''
        for i, c in ipairs(palette) do
            local cval = c[1] + bit.lshift(c[2], 5) + bit.lshift(c[3], 10)
            local swapped = bit.bswap(bit.lshift(cval, 16))
            encoded = encoded .. bit.tohex(swapped, 4)
        end
        return encoded
    elseif type(palette) == 'string' then
        -- Decoding palette
        local decoded = export.palette()
        for i = 1, #palette, 4 do
            local n = tonumber(string.sub(palette, i, i + 3), 16)
            local ci = (i - 1) / 4 + 1
            n = bit.bswap(bit.lshift(n, 16))
            decoded[ci] = {
                bit.band(n, 0x1f),
                bit.band(bit.rshift(n, 5), 0x1f),
                bit.band(bit.rshift(n, 10), 0x1f),
            }
        end
        return decoded
    else
        local msg =
            "bad argument #1 to 'export.palette' "
            .. " (nil, table, or string expected, got %s)"
        error(string.format(msg, type(palette)), 2)
    end
end

function export.tile(tile, v)
    if tile == nil then
        if v == nil then v = 0 end
        return {
            v, v, v, v, v, v, v, v,
            v, v, v, v, v, v, v, v,
            v, v, v, v, v, v, v, v,
            v, v, v, v, v, v, v, v,
            v, v, v, v, v, v, v, v,
            v, v, v, v, v, v, v, v,
            v, v, v, v, v, v, v, v,
            v, v, v, v, v, v, v, v,
        }
    elseif type(tile) == 'table' then
        -- Encoding tile
        local encoded = ''
        if tile.palette ~= nil then
            encoded = '(' .. tile.palette .. ')'
        end

        local last = nil
        for i, v in ipairs(tile) do
            if last == nil then
                last = v
            else
                encoded = encoded .. bit.tohex(bit.lshift(v, 4) + last, 2)
                last = nil
            end
        end
        return encoded
    elseif type(tile) == 'string' then
        -- Decoding tile
        local decoded = export.tile()
        if tile:sub(1, 1) == '(' then
            local ed = tile:find(')', 2, true)
            decoded.palette = tonumber(tile:sub(2, ed - 1))
            tile = tile:sub(ed + 1)
        end

        for i = 1, #tile, 2 do
            local n = tonumber(tile:sub(i, i + 1), 16)
            decoded[i] = bit.band(n, 0xf)
            decoded[i+1] = bit.rshift(n, 4)
        end
        return decoded
    else
        local msg =
            "bad argument #1 to 'export.tile' "
            .. " (nil, table, or string expected, got %s)"
        error(string.format(msg, type(tile)), 2)
    end
end

function export.save(settings, palettes, tiles)
    local file, msg = love.filesystem.newFile('savedata.gfx', 'w')
    if not file then return file, msg end
    local status

    status, msg = file:write('% gba-gfx\n')
    if not status then return status, msg end

    for i, palette in ipairs(palettes) do
        status, msg = file:write('p ' .. export.palette(palette) .. '\n')
        if not status then return status, msg end
    end

    for i, tile in ipairs(tiles) do
        status, msg = file:write('t ' .. export.tile(tile) .. '\n')
        if not status then return status, msg end
    end

    file:close()
    return true
end

function export.load()
    local palettes = {}
    local tiles = {}

    local file, msg = love.filesystem.newFile('savedata.gfx', 'r')
    if file == nil then
        return nil, msg
    end

    local settings = nil
    local i = 1
    for line in file:lines() do
        if line:sub(2, 2) ~= ' ' then
            return nil, "invalid file format at line " .. i
                .. " (expected space at col 2)"
        end

        local prefix = line:sub(1, 1)
        if settings == nil and prefix ~= '%' then
            return nil, "invalid file format at line " .. i
                .. " (expected % at col 1)"
        end

        if prefix == '%' then
            local expect = '% gba-gfx'
            if line:sub(1, #expect) ~= expect then
                return nil, "invalid file format at line " .. i
                    .. " (expected file header)"
            end
            settings = {}
        elseif prefix == 'p' then
            local encoded = line:sub(3)
            table.insert(palettes, export.palette(encoded))
        elseif prefix == 't' then
            local encoded = line:sub(3)
            table.insert(tiles, export.tile(encoded))
        else
            return nil, "invalid file format at line " .. i
                .. " (unknown command)"
        end

        i = i + 1
    end

    file:close()
    return settings, palettes, tiles
end

return export
