
local naughty = require('naughty')


---------------------------------------
-- INIT
---------------------------------------

local _this = {}


---------------------------------------
-- DEBUGGING
---------------------------------------

function _this.print_table(table)
    string = ''

    for key, val in pairs(table) do
        string = string .. tostring(key) .. ':' .. tostring(val) .. '\n'
    end

    naughty.notify({ text = string })
end


---------------------------------------
-- FILE OPERATIONS
---------------------------------------

function _this.file_read(file)
    local f = io.open(file, 'rb')
    local value = nil

    if f then
        value = f:read('*a')
        f:close()
    end

    return value
end


function _this.file_write(file, value)
    local f = io.open(file, 'w')

    if f then
        f:write(value)
        f:close()
    end
end


return _this
