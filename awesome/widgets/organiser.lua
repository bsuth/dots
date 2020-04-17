local awful = require('awful')
local naughty = require('naughty')

---------------------------------------
-- ORGANISER
---------------------------------------

local Organiser = {}


function Organiser:new(t)
    local organiser = {
    }

    setmetatable(organiser, { __index = self })
    return organiser
end


---------------------------------------
-- RETURN
---------------------------------------

return Organiser
