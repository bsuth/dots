
local awful = require("awful")
local wibox = require("wibox")
local theme = require("theme")
local utils = require('utils')


---------------------------------------
-- HELPERS
---------------------------------------

function factory()
    local tag = wibox.widget.base.make_widget()

    function tag:fit(context, width, height)
        local m = math.min(width, height, 20)
        return m, m
    end

    function tag:draw(context, cr, width, height)
        draw_normal(context, cr, width, height)
    end

    return tag
end


function draw_normal(context, cr, width, height)
    cr:set_source_rgb(1, 0, 0)
    cr:arc(width / 2, height / 2, 0.6 * height / 2, 0, 2 * math.pi)
    cr:fill()
end


function draw_focused(context, cr, width, height)
    cr:set_source_rgb(0, 1, 0)
    cr:arc(width / 2, height / 2, 0.6 * height / 2, 0, 2 * math.pi)
    cr:fill()
end


---------------------------------------
-- INIT
---------------------------------------

local default_tag = factory()

function default_tag:draw(context, cr, width, height)
    draw_focused(context, cr, width, height)
end


local _this = awful.popup({
    widget = {
        {
            default_tag,
            layout = wibox.layout.fixed.horizontal,
        },
        margins = 10,
        widget  = wibox.container.margin
    },

    fg = '#e8e8e8',
    bg = '#00000000',

    border_color = theme.border_focus,
    border_width = 1,

    ontop = true,
    placement = awful.placement.centered + awful.placement.bottom,
    visible = false,
})

_this.state = {
    current_idx = 1,
}


---------------------------------------
-- MAIN
---------------------------------------

function _this:toggle()
    self.visible = not self.visible
end


function _this:add()
    self.widget:get_widget():add(factory())
end


function _this:remove()
    self.widget:get_widget():remove(1)
end


function _this:refresh()
    local tag_collection = self.widget:get_widget():get_children()
    local new_idx = awful.screen.focused().selected_tag.index

    if self.state.current_idx ~= new_idx then
        local old_tag = tag_collection[self.state.current_idx]
        if old_tag then
            function old_tag:draw(context, cr, width, height)
                draw_normal(context, cr, width, height)
            end
            old_tag:emit_signal('widget::redraw_needed')
        end

        local new_tag = tag_collection[new_idx]
        if new_tag then
            function new_tag:draw(context, cr, width, height)
                draw_focused(context, cr, width, height)
            end
            new_tag:emit_signal('widget::redraw_needed')
        end

        self.state.current_idx = new_idx
    end
end


return _this
