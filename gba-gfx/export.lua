local ffi = require('ffi')

local export = {}

local function swap16(x)
    return bit.bswap(bit.lshift(x, 16))
end

local _emptypalette =
    '000000000000000' ..
    '000000000000000' ..
    '000000000000000' ..
    '000000000000000'

function export.palette(palette)
    if palette == nil then
        return {
            {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
            {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
            {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
            {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
        }
    elseif type(palette) == 'table' then
        -- Encoding palette
        local encoded = ''
        for i, c in ipairs(palette) do
            local cval = c[1] + bit.lshift(c[2], 5) + bit.lshift(c[3], 10)
            local swapped = swap16(cval)
            encoded = encoded .. bit.tohex(swapped, 4)
        end
        return encoded
    elseif type(palette) == 'string' then
        -- Decoding palette
        local decoded = export.palette()
        for i = 1, #palette, 4 do
            local n = tonumber(string.sub(palette, i, i + 3), 16)
            local ci = (i - 1) / 4 + 1
            n = swap16(n)
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
            .. "(nil, table, or string expected, got %s)"
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
            local n = tonumber(tile:sub(i, i + 1), 16)
            decoded[i] = bit.band(n, 0xf)
            decoded[i+1] = bit.rshift(n, 4)
        end
        return decoded
    else
        local msg =
            "bad argument #1 to 'export.tile' "
            .. "(nil, table, or string expected, got %s)"
        error(string.format(msg, type(tile)), 2)
    end
end

function export.obj(obj)
    if type(obj) == 'table' then
        -- Encoding obj
        local shape = nil
        local size = nil
        if obj.w == obj.h then
            shape = 0
            if obj.w == 1 then size = 0
            elseif obj.w == 2 then size = 1
            elseif obj.w == 4 then size = 2
            elseif obj.w == 8 then size = 3
            end
        elseif obj.w > obj.h then
            shape = 1
            if obj.w == 2 and obj.h == 1 then size = 0
            elseif obj.w == 4 and obj.h == 1 then size = 1
            elseif obj.w == 4 and obj.h == 2 then size = 2
            elseif obj.w == 8 and obj.h == 4 then size = 3
            end
        else
            shape = 2
            if obj.w == 1 and obj.h == 2 then size = 0
            elseif obj.w == 1 and obj.h == 4 then size = 1
            elseif obj.w == 2 and obj.h == 4 then size = 2
            elseif obj.w == 4 and obj.h == 8 then size = 3
            end
        end
        if size == nil then
            local msg = "unsupported size for obj (%sx%s)"
            error(string.format(msg, obj.w, obj.h), 2)
        end

        local attr0 = swap16(bit.lshift(shape, 14))
        local attr1 = swap16(bit.lshift(size, 14))
        local attr2 = swap16(bit.lshift(obj.palette, 12) + obj.tile)

        return bit.tohex(attr0, 4) .. bit.tohex(attr1, 4) .. bit.tohex(attr2, 4)
    elseif type(obj) == 'string' then
        -- Decoding obj
        local attr0 = swap16(tonumber(obj:sub(1, 4), 16))
        local attr1 = swap16(tonumber(obj:sub(5, 8), 16))
        local attr2 = swap16(tonumber(obj:sub(9, 12), 16))

        local shape = bit.rshift(attr0, 14)
        local size = bit.rshift(attr1, 14)
        local tile = bit.band(attr2, 0x3ff)
        local palette = bit.rshift(attr2, 12)

        local decoded = { tile = tile, palette = palette }
        if shape == 0 then
            decoded.w = bit.lshift(1, size)
            decoded.h = decoded.w
        elseif shape == 1 then
            if size == 0 then decoded.w = 2 decoded.h = 1
            elseif size == 1 then decoded.w = 4 decoded.h = 1
            elseif size == 2 then decoded.w = 4 decoded.h = 2
            elseif size == 3 then decoded.w = 8 decoded.h = 4
            end
        else
            if size == 0 then decoded.w = 1 decoded.h = 2
            elseif size == 1 then decoded.w = 1 decoded.h = 4
            elseif size == 2 then decoded.w = 2 decoded.h = 4
            elseif size == 3 then decoded.w = 4 decoded.h = 8
            end
        end

        return decoded
    else
        local msg =
            "bad argument #1 to 'export.obj' "
            .. "(table or string expected, got %s)"
        error(string.format(msg, type(obj)), 2)
    end
end

function export.save(filename, data)
    local file, msg = love.filesystem.newFile(filename, 'w')
    if not file then return file, msg end
    local status

    status, msg = file:write('% gba-gfx\n')
    if not status then return status, msg end

    local skipped = 0
    for i, palette in ipairs(data.palettes) do
        local encoded = export.palette(palette)
        if encoded == _emptypalette then
            skipped = skipped + 1
        else
            for i = 1, skipped do
                status, msg = file:write('p ' .. _emptypalette .. '\n')
                if not status then return status, msg end
            end
            skipped = 0
            status, msg = file:write('p ' .. encoded .. '\n')
            if not status then return status, msg end
        end
    end

    for i, tile in ipairs(data.tiles) do
        status, msg = file:write('t ' .. export.tile(tile) .. '\n')
        if not status then return status, msg end
    end

    for i, obj in ipairs(data.objs) do
        status, msg = file:write('o ' .. export.obj(obj) .. '\n')
        if not status then return status, msg end
    end

    file:close()
    return true
end

function export.load(filename)
    local file, msg = love.filesystem.newFile(filename, 'r')
    if file == nil then
        return nil, msg
    end

    local data = nil
    local i = 1
    for line in file:lines() do
        if line:sub(2, 2) ~= ' ' then
            return nil, "invalid file format at line " .. i
                .. " (expected space at col 2)"
        end

        local prefix = line:sub(1, 1)
        if data == nil and prefix ~= '%' then
            return nil, "invalid file format at line " .. i
                .. " (expected % at col 1)"
        end

        if prefix == '%' then
            local expect = '% gba-gfx'
            if line:sub(1, #expect) ~= expect then
                return nil, "invalid file format at line " .. i
                    .. " (expected file header)"
            end
            data = {
                settings = {},
                palettes = {},
                tiles = {},
                objs = {},
            }
        elseif prefix == 'p' then
            local encoded = line:sub(3)
            table.insert(data.palettes, export.palette(encoded))
        elseif prefix == 't' then
            local encoded = line:sub(3)
            table.insert(data.tiles, export.tile(encoded))
        elseif prefix == 'o' then
            local encoded = line:sub(3)
            table.insert(data.objs, export.obj(encoded))
        else
            return nil, "invalid file format at line " .. i
                .. " (unknown command)"
        end

        i = i + 1
    end

    file:close()
    return data
end

return export
