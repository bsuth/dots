local awful = require('awful')
local naughty = require('naughty')

---------------------------------------
-- ALTTAB
---------------------------------------

local Alttab = {}


function Alttab:new(t)
    local alttab = {
        stack = {},
        stack_pointer = 1,
    }

    for _, c in ipairs(t:clients()) do
        table.insert(alttab.stack, c)
    end

    setmetatable(alttab, { __index = self })
    return alttab
end


function Alttab:get()
    local t = awful.screen.focused().selected_tag

    if not t.alttab then
        t.alttab = Alttab:new(t)
    end

    return t.alttab
end


function Alttab:prev()
    local sp = self.stack_pointer
    self.stack_pointer = (sp == #self.stack and 1 or sp + 1)

    local c = self.stack[self.stack_pointer]
    client.focus = c
    c:raise()
end


function Alttab:next()
    local sp = self.stack_pointer
    self.stack_pointer = (sp == 1 and #self.stack or sp - 1)

    local c = self.stack[self.stack_pointer]
    client.focus = c
    c:raise()
end


function Alttab:commit()
    table.insert(self.stack, 1, table.remove(self.stack, self.stack_pointer))
    self.stack_pointer = 1

    for i = #self.stack, 1, -1 do
        self.stack[i]:raise()
    end

    client.focus = self.stack[1]
end


---------------------------------------
-- SIGNALS
---------------------------------------

tag.connect_signal('request::select', function (t)
    if not t.alttab then
        t.alttab = Alttab:new()
    end
end)

client.connect_signal('manage', function (c)
    local alttab = Alttab:get()

    for i, _c in ipairs(alttab.stack) do
        if c == _c then
            return
        end
    end

    table.insert(alttab.stack, 1, c)
end)

client.connect_signal('unmanage', function (c)
    local alttab = Alttab:get()

    for i, _c in ipairs(alttab.stack) do
        if c == _c then
            table.remove(alttab.stack, i)
            return
        end
    end
end)


---------------------------------------
-- RETURN
---------------------------------------

return Alttab
