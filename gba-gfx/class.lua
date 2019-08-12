
local class = {}
class.__index = class

function class:new(...)
    self = setmetatable({}, self)
    if self.new == class.new then self.new = nil end
    if self.extend == class.extend then self.extend = nil end
    self:init(...)
    return self
end

function class:extend()
    self = setmetatable({}, self)
    self.__index = self
    return self
end

return class
