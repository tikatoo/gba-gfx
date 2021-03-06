local class = require('class')

local Sprite = class:extend()
local Spriteset = class:extend()
local encode = {}
local decode = {}


local function newtile(v)
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
end

local function copytile(t)
    return {
        t[ 1], t[ 2], t[ 3], t[ 4], t[ 5], t[ 6], t[ 7], t[ 8],
        t[ 9], t[10], t[11], t[12], t[13], t[14], t[15], t[16],
        t[17], t[18], t[19], t[20], t[21], t[22], t[23], t[24],
        t[25], t[26], t[27], t[28], t[29], t[30], t[31], t[32],
        t[33], t[34], t[35], t[36], t[37], t[38], t[39], t[40],
        t[41], t[42], t[43], t[44], t[45], t[46], t[47], t[48],
        t[49], t[50], t[51], t[52], t[53], t[54], t[55], t[56],
        t[57], t[58], t[59], t[60], t[61], t[62], t[63], t[64],
    }
end

local function newpalette()
    return {
        {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
        {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
        {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
        {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
    }
end

local function getdims(shape, size)
    local w, h
    if shape == 0 then
        w = bit.lshift(1, size)
        h = w
    elseif shape == 1 then
        if size == 0 then w = 2 h = 1
        elseif size == 1 then w = 4 h = 1
        elseif size == 2 then w = 4 h = 2
        elseif size == 3 then w = 8 h = 4
        end
    else
        if size == 0 then w = 1 h = 2
        elseif size == 1 then w = 1 h = 4
        elseif size == 2 then w = 2 h = 4
        elseif size == 3 then w = 4 h = 8
        end
    end

    return w, h
end


function Sprite:init(obj, set)
    self.set = set
    self.tiles = set.tiles
    self.palettes = set.palettes

    if obj == nil then
        obj = { tile = #self.tiles, palette = 0, shape = 0, size = 0 }
        table.insert(self.tiles, newtile())
    end
    self.tile = obj.tile
    self.palette = obj.palette
    self:_resize(obj.shape, obj.size)
    self:setchanged()
end

function Sprite:_resize(shape, size)
    self.shape = shape
    if size == nil then size = self.size
    else self.size = size
    end
    self.w, self.h = getdims(shape, size)
    self.len = self.w * self.h
    return shape, size
end

function Sprite:setchanged()
    self.original = nil
end

function Sprite:resize(shape, size)
    local startlen = self.len
    local startw = self.w
    if self.original == nil then
        self.original = { shape = self.shape, size = self.size,
                          w = self.w, h = self.h }
        for i = 1, startlen do
            table.insert(self.original, copytile(self.tiles[self.tile + i]))
        end
    end

    shape, size = self:_resize(shape, size)

    self.set:shift(self.tile, startlen, self.len)

    for i = 1, self.len do
        local xi = i - 1
        local x = xi % self.w
        local y = (xi - x) / self.w
        if x < self.original.w and y < self.original.h then
            local oi = (y * self.original.w) + x
            self.tiles[self.tile + i] = copytile(self.original[oi + 1])
        else
            self.tiles[self.tile + i] = newtile()
        end
    end
end


function Spriteset:init(objs, tiles, palettes, settings)
    self.tiles = tiles or {}
    self.palettes = palettes or {}
    self.settings = settings or {}

    while #self.palettes < 16 do
        table.insert(self.palettes, newpalette())
    end

    self.objs = {}
    if objs ~= nil then
        for i, obj in ipairs(objs) do
            table.insert(self.objs, Sprite:new(obj, self))
        end
    end
end

function Spriteset:encode(writeline)
    return encode.lines(writeline, self)
end

function Spriteset:newsprite()
    local obj = Sprite:new(nil, self)
    table.insert(self.objs, obj)
    return #self.objs, obj
end

function Spriteset:shift(tile, oldlen, newlen)
    local shiftby = newlen - oldlen

    if shiftby == 0 then
        -- No change happening
        return
    elseif shiftby > 0 then
        -- Need to insert some tiles
        for i = oldlen + 1, newlen do
            -- Tile must be manually populated after this function
            table.insert(self.tiles, tile + i, {})
        end
    elseif shiftby < 0 then
        -- Need to remove some tiles
        for i = oldlen, newlen + 1, -1 do
            table.remove(self.tiles, tile + i)
        end
    end

    -- Update objects
    for i, obj in ipairs(self.objs) do
        if obj.tile > tile then
            obj.tile = obj.tile + shiftby
        end
    end
end


local function swap16(x)
    return bit.bswap(bit.lshift(x, 16))
end

function encode.obj(obj)
    local attr0 = swap16(bit.lshift(obj.shape, 14))
    local attr1 = swap16(bit.lshift(obj.size, 14))
    local attr2 = swap16(bit.lshift(obj.palette, 12) + obj.tile)
    return bit.tohex(attr0, 4) .. bit.tohex(attr1, 4) .. bit.tohex(attr2, 4)
end

function decode.obj(src)
    local attr0 = swap16(tonumber(src:sub(1, 4), 16))
    local attr1 = swap16(tonumber(src:sub(5, 8), 16))
    local attr2 = swap16(tonumber(src:sub(9, 12), 16))

    local shape = bit.rshift(attr0, 14)
    local size = bit.rshift(attr1, 14)
    local tile = bit.band(attr2, 0x3ff)
    local palette = bit.rshift(attr2, 12)

    return {
        tile = tile, palette = palette,
        size = size, shape = shape,
    }
end


function encode.tile(tile)
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
end

function decode.tile(src)
    local decoded = newtile()
    for i = 1, #src, 2 do
        local n = tonumber(src:sub(i, i + 1), 16)
        decoded[i] = bit.band(n, 0xf)
        decoded[i+1] = bit.rshift(n, 4)
    end
    return decoded
end


function encode.palette(palette)
    local encoded = ''
    for i, c in ipairs(palette) do
        local cval = c[1] + bit.lshift(c[2], 5) + bit.lshift(c[3], 10)
        local swapped = swap16(cval)
        encoded = encoded .. bit.tohex(swapped, 4)
    end
    return encoded
end

function decode.palette(src)
    local decoded = newpalette()
    for i = 1, #src, 4 do
        local n = tonumber(string.sub(src, i, i + 3), 16)
        n = swap16(n)
        decoded[(i - 1) / 4 + 1] = {
            bit.band(n, 0x1f),
            bit.band(bit.rshift(n, 5), 0x1f),
            bit.band(bit.rshift(n, 10), 0x1f),
        }
    end
    return decoded
end


local _emptypalette = encode.palette(newpalette())

function encode.lines(writeline, data)
    local status, msg = writeline('% gba-gfx')
    if not status then return status, msg end

    for i, obj in ipairs(data.objs) do
        status, msg = writeline('o ' .. encode.obj(obj))
        if not status then return status, msg end
    end

    for i, tile in ipairs(data.tiles) do
        status, msg = writeline('t ' .. encode.tile(tile))
        if not status then return status, msg end
    end

    local skipped = 0
    for i, palette in ipairs(data.palettes) do
        local encoded = encode.palette(palette)
        if encoded == _emptypalette then
            skipped = skipped + 1
        else
            for i = 1, skipped do
                status, msg = writeline('p ' .. _emptypalette)
                if not status then return status, msg end
            end
            skipped = 0
            status, msg = writeline('p ' .. encoded)
            if not status then return status, msg end
        end
    end

    return true
end

function decode.lines(f, s, var)
    local data = nil
    local i = 1
    for line in f, s, var do
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
                objs = {},
                tiles = {},
                palettes = {},
                settings = {},
            }
        elseif prefix == 'p' then
            local encoded = line:sub(3)
            table.insert(data.palettes, decode.palette(encoded))
        elseif prefix == 't' then
            local encoded = line:sub(3)
            table.insert(data.tiles, decode.tile(encoded))
        elseif prefix == 'o' then
            local encoded = line:sub(3)
            table.insert(data.objs, decode.obj(encoded))
        else
            return nil, "invalid file format at line " .. i
                .. " (unknown command)"
        end

        i = i + 1
    end

    return data
end


return {
    newtile = newtile, newpalette = newpalette,
    load = function (f, s, var)
        if f == nil then
            return Spriteset:new()
        else
            local data, msg = decode.lines(f, s, var)
            if data == nil then return data, msg end
            return Spriteset:new(
                data.objs, data.tiles,
                data.palettes, data.settings
            )
        end
    end,
}
