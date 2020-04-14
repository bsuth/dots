local awful = require('awful')
local naughty = require('naughty')

---------------------------------------
-- CONFIG
---------------------------------------

-- local LAYOUT = awful.layout.suit.tile
local LAYOUT = awful.layout.suit.floating


---------------------------------------
-- TAGGER
---------------------------------------

local Tagger = {}


function Tagger:new(screen)
    local tagger = {
        stack = { '1' },
        stack_pointer = 1,
        next_id = 2,
        screen = screen,
    }

    setmetatable(tagger, { __index = self })
    awful.tag(tagger.stack, screen, LAYOUT)
    return tagger
end


function Tagger:push()
    local tag = awful.tag.add(tostring(self.next_id), {
        screen = self.screen,
        layout = LAYOUT,
    })

    self.next_id = self.next_id + 1
    table.insert(self.stack, 1, tag.name)
    tag:view_only()
end


function Tagger:pop()
    local tag = self.screen.selected_tag

    for _, client in pairs(tag:clients()) do
        client:kill()
    end

    table.remove(self.stack, 1)
    tag:delete(awful.tag.find_fallback(), true)
end


function Tagger:prev()
    local sp = self.stack_pointer
    self.stack_pointer = (sp == #self.stack and 1 or sp + 1)
    awful.tag.find_by_name(self.screen, self.stack[self.stack_pointer]):view_only()
end


function Tagger:next()
    local sp = self.stack_pointer
    self.stack_pointer = (sp == 1 and #self.stack or sp - 1)
    awful.tag.find_by_name(self.screen, self.stack[self.stack_pointer]):view_only()
end


function Tagger:commit()
    table.insert(self.stack, 1, table.remove(self.stack, self.stack_pointer))
    self.stack_pointer = 1
end


return Tagger
