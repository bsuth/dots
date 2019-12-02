
local awful = require('awful')
local naughty = require('naughty')
local utils = require('utils')


---------------------------------------
-- INIT
---------------------------------------

local _this = {
    stack = {1},
    stack_pointer = 1,
    track = true,
}


---------------------------------------
-- INTERFACE
---------------------------------------

function _this:push(idx)
    table.insert(self.stack, 1, idx)
end


function _this:remove(idx)
    for key, val in pairs(self.stack) do
        if val == idx then
            table.remove(self.stack, key)
            break
        end
    end
end


function _this:previous()
    if self.stack_pointer == #self.stack then
        self.stack_pointer = 1
    else
        self.stack_pointer = self.stack_pointer + 1
    end

    return self.stack[self.stack_pointer]
end


function _this:commit()
    local new_stack_top = self.stack[self.stack_pointer]

    table.remove(self.stack, self.stack_pointer)
    table.insert(self.stack, 1, new_stack_top)

    self.stack_pointer = 1

    return self.stack[1]
end


---------------------------------------
-- RETURN
---------------------------------------

return _this
