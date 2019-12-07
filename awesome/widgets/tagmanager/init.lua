
local awful = require('awful')
local naughty = require('naughty')
local utils = require('utils')

local tagbar = require('widgets.tagmanager.tagbar')
local history = require('widgets.tagmanager.history')


---------------------------------------
-- INIT
---------------------------------------

local _this = {}


---------------------------------------
-- PRIVATE
---------------------------------------

function _this._add(tagmanager)
    local new_tag = awful.tag.add(tostring(#awful.screen.focused().tags + 1), {
        screen = awful.screen.focused(),
        layout = awful.layout.suit.tile,
    })

    tagmanager.tagbar:add()
    tagmanager.history:push(new_tag.index)
    new_tag:view_only()

    utils.print_table(awful.screen.focused().tags)
end


function _this._remove(tagmanager)
    local old_focus_tag = awful.screen.focused().selected_tag
    local old_index = old_focus_tag.index

    for _, client in pairs(old_focus_tag:clients()) do
        client:kill()
    end

    old_focus_tag:delete(awful.tag.find_fallback(), true)
    tagmanager.tagbar:remove(old_focus_tag.index)
    tagmanager.history:pop(old_focus_tag.index)
end


function _this._view_prev(tagmanager)
    local prev_tag = tagmanager.history:previous()

    tagmanager.tagbar:focus(awful.screen.focused().selected_tag.index, prev_tag)
    awful.screen.focused().tags[prev_tag]:view_only()
end


---------------------------------------
-- PUBLIC
---------------------------------------

function _this.new(screen)
    local tagmanager = {
        history = history.new(),
        tagbar = tagbar.new(),
    }

    function tagmanager:add()
        _this._add(self)
    end

    function tagmanager:remove()
        _this._remove(self)
    end

    function tagmanager:view_prev()
        _this._view_prev(self)
    end

    for i = 1, 5 do
        table.insert(tagmanager.history.stack, i)
    end

    awful.tag(tagmanager.history.stack, screen, awful.layout.layouts[1])
    tagmanager.tagbar:init(#tagmanager.history.stack)
    tagmanager.tagbar:focus(awful.screen.focused().selected_tag.index, awful.screen.focused().selected_tag.index)
    return tagmanager
end


---------------------------------------
-- RETURN
---------------------------------------

return _this

