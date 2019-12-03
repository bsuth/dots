
local awful = require("awful")
local wibox = require("wibox")
local theme = require("theme")
local utils = require('utils')


---------------------------------------
-- INIT
---------------------------------------

local _this = {}


---------------------------------------
-- PRIVATE
---------------------------------------

function _this._factory()
    local tag = wibox.widget.base.make_widget()

    function tag:fit(context, width, height)
        local m = math.min(width, height, 20)
        return m, m
    end

    function tag:draw(context, cr, width, height)
        _this._draw_focused(context, cr, width, height)
    end

    return tag
end


function _this._draw_normal(context, cr, width, height)
    cr:set_source_rgb(1, 0, 0)
    cr:arc(width / 2, height / 2, 0.6 * height / 2, 0, 2 * math.pi)
    cr:fill()
end


function _this._draw_focused(context, cr, width, height)
    cr:set_source_rgb(0, 1, 0)
    cr:arc(width / 2, height / 2, 0.6 * height / 2, 0, 2 * math.pi)
    cr:fill()
end


function _this._add(tagbar)
    local children = tagbar.widget:get_widget():get_children()
    local old_focus_index = awful.screen.focused().selected_tag.index
    local old_child = children[old_focus_index]

    function old_child:draw(context, cr, width, height)
        _this._draw_normal(context, cr, width, height)
    end
    old_child:emit_signal('widget::redraw_needed')

    tagbar.widget:get_widget():add(_this._factory())
end


function _this._remove(tagbar, idx)
    local children = tagbar.widget:get_widget():get_children()
    local new_focus_index = awful.screen.focused().selected_tag.index
    local new_child = children[new_focus_index]

    function new_child:draw(context, cr, width, height)
        _this._draw_focused(context, cr, width, height)
    end
    new_child:emit_signal('widget::redraw_needed')

    tagbar.widget:get_widget():remove(idx)
end


function _this._focus(tagbar, old_idx, new_idx)
    local children = tagbar.widget:get_widget():get_children()

    local old_focus = children[old_idx]
    local new_focus = children[new_idx]

    function old_focus:draw(context, cr, width, height)
        _this._draw_normal(context, cr, width, height)
    end
    old_focus:emit_signal('widget::redraw_needed')

    function new_focus:draw(context, cr, width, height)
        _this._draw_focused(context, cr, width, height)
    end
    new_focus:emit_signal('widget::redraw_needed')
end


---------------------------------------
-- PUBLIC
---------------------------------------

function _this.new()
    local tagbar = awful.popup({
        widget = {
            {
                _this._factory(),
                layout = wibox.layout.fixed.horizontal,
            },
            margins = 10,
            widget  = wibox.container.margin
        },

        fg = '#e8e8e8',
        bg = '#000000',

        border_color = theme.border_focus,
        border_width = 1,

        ontop = true,
        placement = awful.placement.centered + awful.placement.bottom,
        visible = false,
    })

    function tagbar:add()
        _this._add(self)
    end

    function tagbar:remove(idx)
        _this._remove(self, idx)
    end

    function tagbar:toggle()
        self.visible = not self.visible
    end

    function tagbar:focus(old_idx, new_idx)
        _this._focus(self, old_idx, new_idx)
    end

    return tagbar
end


---------------------------------------
-- RETURN
---------------------------------------

return _this

