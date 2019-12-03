
local awful = require('awful')
local naughty = require('naughty')
local utils = require('utils')


---------------------------------------
-- INIT
---------------------------------------

local _this = {}


---------------------------------------
-- PRIVATE
---------------------------------------

function _this._push(history, idx)
    table.insert(history.stack, 1, idx)
end


function _this._remove(history, idx)
    for key, val in pairs(history.stack) do
        if val == idx then
            table.remove(history.stack, key)
            break
        end
    end
end


function _this._previous(history)
    if history.stack_pointer == #history.stack then
        history.stack_pointer = 1
    else
        history.stack_pointer = history.stack_pointer + 1
    end

    return history.stack[history.stack_pointer]
end


function _this._commit(history)
    local new_stack_top = history.stack[history.stack_pointer]

    table.remove(history.stack, history.stack_pointer)
    table.insert(history.stack, 1, new_stack_top)

    history.stack_pointer = 1
end


---------------------------------------
-- PUBLIC
---------------------------------------

function _this.new()
    local history = {
        stack = { 1 },
        stack_pointer = 1,
    }

    function history:push(idx)
        _this._push(self, idx)
    end

    function history:remove(idx)
        _this._remove(self, idx)
    end

    function history:previous()
        return _this._previous(self)
    end

    function history:commit()
        _this._commit(self)
    end

    return history
end


---------------------------------------
-- RETURN
---------------------------------------

return _this

