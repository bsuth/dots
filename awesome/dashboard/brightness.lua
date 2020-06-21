local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

---------------------------------------
-- BRIGHTNESS WIDGET
---------------------------------------

local brightness = wibox.widget({
    {
        {
            text   = 'b',
            widget = wibox.widget.textbox,
        },
        {
            {
                bar_shape = gears.shape.rounded_rect,
                bar_height = 3,
                bar_color = beautiful.border_color,

                handle_width = 30,
                handle_color = beautiful.colors.yellow,
                handle_shape = gears.shape.circle,
                handle_border_color = beautiful.border_color,
                handle_border_width = 1,
                value = 25,

                widget = wibox.widget.slider,
            },

            direction = 'east',
            widget = wibox.container.rotate,
        },

        layout = wibox.layout.fixed.vertical,
    },

    shape = gears.shape.rounded_rect,
    shape_border_width = 2,
    shape_border_color = beautiful.colors.dark_grey,
    widget = wibox.container.background,
})

---------------------------------------
-- KEYBINDINGS
---------------------------------------

---------------------------------------
-- RETURN
---------------------------------------

return brightness
