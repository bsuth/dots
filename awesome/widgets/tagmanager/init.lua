
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
end


function _this._remove(tagmanager)
    local old_focus_tag = awful.screen.focused().selected_tag
    local new_focus_tag = awful.tag.find_fallback()

    for _, client in pairs(old_focus_tag:clients()) do
        client:kill()
    end

    tagmanager.tagbar:remove(old_focus_tag.index)
    tagmanager.history:remove(old_focus_tag.index)
    old_focus_tag:delete(new_focus_tag, true)
end


function _this._view_prev(tagmanager)
    local prev_tag = tagmanager.history:previous()

    tagmanager.tagbar:focus(awful.screen.focused().selected_tag.index, prev_tag)
    awful.screen.focused().tags[prev_tag]:view_only()
end


---------------------------------------
-- PUBLIC
---------------------------------------

function _this.new()
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

    return tagmanager
end


---------------------------------------
-- RETURN
---------------------------------------

return _this

