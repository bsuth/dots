
local awful = require('awful')
local naughty = require('naughty')


---------------------------------------
-- CONFIG
---------------------------------------

local LAYOUT = awful.layout.suit.tile
local TAG_STACK = { 1 }


---------------------------------------
-- TAGGER
---------------------------------------

local Tagger = {}


function Tagger:new(screen)
    local tagger = {
        stack = TAG_STACK,
        stack_pointer = 1,
        screen = screen,
    }

    setmetatable(tagger, { __index = self })
    awful.tag(TAG_STACK, screen, LAYOUT)
    return tagger
end


function Tagger:push()
    local tag = awful.tag.add('', {
        screen = self.screen,
        layout = LAYOUT,
    })

    table.insert(self.stack, 1, tag.index)
    tag:view_only()
end


function Tagger:pop()
    local tag = self.screen.selected_tag

    -- kill all clients
    for _, client in pairs(tag:clients()) do
        client:kill()
    end

    -- remove tag index from the stack
    table.remove(self.stack, 1)

    -- delete the tag
    tag:delete(awful.tag.find_fallback(), true)
end


function Tagger:prev()
    if self.stack_pointer == #self.stack then
        self.stack_pointer = 1
    else
        self.stack_pointer = self.stack_pointer + 1
    end

    self.screen.tags[self.stack[self.stack_pointer]]:view_only()
end


function Tagger:commit()
    table.insert(self.stack, 1, table.remove(self.stack, self.stack_pointer))
    self.stack_pointer = 1
end


return Tagger
