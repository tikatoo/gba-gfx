local func = {}

function func.filter(filterer, f, s, var)
    if f == nil then return f, s, v end

    local function stepper(...)
        var = ...
        if var == nil then
            return nil
        elseif filterer(...) then
            return ...
        else
            return stepper(f(s, var))
        end
    end

    return function (s, var)
        return stepper(f(s, var))
    end, s, var
end

function func.map(mapper, f, s, var)
    if f == nil then return f, s, v end

    local function stepper(...)
        var = ...
        if var == nil then return nil
        else return mapper(...)
        end
    end

    return function (s, _var)
        return stepper(f(s, var))
    end, s, var
end

function func.reduce(init, reducer, f, s, var)
    if f == nil then return f, s, v end

    local total = init

    local function stopper(total) return total end

    local function breaker(...)
        var = ...
        if var == nil then reducer = stopper end
        return ...
    end

    local function stepper(...)
        var = ...
        if var == nil then return total
        else return reducer(total, ...)
        end
    end

    while true do
        total = stepper(f(s, var))
        if var == nil then break end
    end

    return total
end

function func.collect(f, s, var)
    if f == nil then return f, s, v end

    local function reducer(rs, rv)
        table.insert(rs, rv)
        return rs
    end

    return func.reduce({}, reducer, f, s, v)
end

function func.join(joiner, f, s, var)
    if f == nil then return f, s, v end

    local function reducer(rs, rv)
        if rs == nil then
            return tostring(rv)
        else
            return rs .. joiner .. rv
        end
    end

    return func.reduce(nil, reducer, f, s, var)
end

function func.split(by, value)
    if by == nil then return nil, 'split by is nil' end
    if value == nil then return nil, 'split value is nil' end

    return function (s, var)
        local i = s.i
        local p
        if i == nil then return nil end
        local st, ed = string.find(value, by, s.i, false)
        if st == nil then
            s.i = nil
            return string.sub(value, i)
        else
            s.i = ed + 1
            return string.sub(value, i, st - 1)
        end
    end, { i = 1 }, nil
end

return func
