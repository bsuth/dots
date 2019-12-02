local naughty = require('naughty')
local utils = {}


---------------------------------------
-- DEBUGGING
---------------------------------------

function utils.print_table(table)
    string = ''

    for key, val in pairs(table) do
        string = string .. tostring(key) .. ':' .. tostring(val) .. '\n'
    end

    naughty.notify({ text = string })
end


---------------------------------------
-- FILE OPERATIONS
---------------------------------------

function utils.file_read(file)
    local f = io.open(file, 'rb')
    local value = nil

    if f then
        value = f:read('*a')
        f:close()
    end

    return value
end


return utils
