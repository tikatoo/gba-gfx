local export = require('export')

-- This module is temporary, and will be tidied up in the next commit.
local misc = {}

function misc.newtile(v)
    return export.tile(nil, v)
end

function misc.newpalette()
    return export.palette()
end

return misc
