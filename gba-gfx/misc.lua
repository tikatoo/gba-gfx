local misc = {}

function misc.newtile(v)
    if v ==  nil then v = 0 end
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

function misc.newpalette() 
    return {
        {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
        {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
        {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0},
        {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {31, 31, 31},
    }
end

return misc
