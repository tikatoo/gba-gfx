
-- Super hacky, but Lua doesn't provide
-- a proper math.round so whaddya gonna do.
function math.round(n)
    if n >= 0 then return math.floor(n + 0.5)
    else return math.ceil(n - 0.5)
    end
end
