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
        for i = 1, #tile, 2 do
            local n = tonumber(string.sub(tile, i, i + 1), 16)
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

function export.save(palette, tile)
    local outf = love.filesystem.newFile('savedata.gfx', 'w')

    assert(outf:write('gba-gfx\n'))
    assert(outf:write(export.palette(palette) .. '\n'))
    assert(outf:write(export.tile(tile) .. '\n'))

    outf:close()
end

function export.load()
    local palette = export.palette()
    local tile = export.tile()

    local inf = love.filesystem.newFile('savedata.gfx', 'r')
    if inf == nil then
        return palette, tile
    end

    local nextline = inf:lines()
    if nextline() ~= 'gba-gfx' then
        inf:close()
        return palette, tile
    end

    palette = export.palette(assert(nextline()))
    tile = export.tile(assert(nextline()))

    inf:close()
    return palette, tile
end

return export
