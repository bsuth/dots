
local awful = require('awful')
local naughty = require('naughty')
local utils = require('utils')


---------------------------------------
-- INIT
---------------------------------------

local _this = {
    tagbar = require('widgets.tagmanager.tagbar'),
    history = require('widgets.tagmanager.history'),
}


---------------------------------------
-- INTERFACE
---------------------------------------

function _this:add()
    local new_tag_name = #awful.screen.focused().tags + 1

    awful.tag.add(tostring(new_tag_name), {
        screen = awful.screen.focused(),
        layout = awful.layout.suit.tile,
    }):view_only()

    self.tagbar:add()
    self.tagbar:refresh()
    self.history:push(new_tag_name)
end


function _this:remove()
    local tag = awful.screen.focused().selected_tag
    local idx = tag.index
    local fallback_tag = awful.tag.find_fallback()

    for _, client in pairs(tag:clients()) do
        client:kill()
    end

    tag:delete(fallback_tag, true)

    self.tagbar:remove()
    self.tagbar:refresh()
    self.history:remove(tag.index)
end


function _this:view_prev()
    local prev_tag = self.history:previous()
    awful.screen.focused().tags[prev_tag]:view_only()
    self.tagbar:refresh()
end


---------------------------------------
-- RETURN
---------------------------------------

return _this

