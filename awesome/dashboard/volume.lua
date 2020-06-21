local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local hkeys = require('helpers.keys')

---------------------------------------
-- VOLUME WIDGET
---------------------------------------

local vslider = wibox.widget({
    bar_shape = gears.shape.rounded_rect,
    bar_height = 3,
    bar_color = beautiful.border_color,

    handle_color = beautiful.bg_normal,
    handle_width = 30,
    handle_shape = gears.shape.circle,
    handle_border_color = beautiful.border_color,
    handle_border_width = 1,
    value = 25,

    widget = wibox.widget.slider,
})

local volume = wibox.widget({
    {
        {
            text   = 'v',
            widget = wibox.widget.textbox,
        },
        {
            vslider,
            direction = 'east',
            widget = wibox.container.rotate,
        },

        layout = wibox.layout.fixed.vertical,
    },

    shape = gears.shape.rounded_rect,
    shape_border_width = 2,
    shape_border_color = beautiful.colors.dark_grey,
    widget  = wibox.container.background,
})

---------------------------------------
-- KEYBINDINGS
---------------------------------------

volume.keys = hkeys.create_keys({
    {{ }, 'j', function() 
        awful.spawn.spawn('amixer sset -D pulse Master 5%-')
        vslider.value = vslider.value - 5
    end },
    {{ }, 'k', function() 
        awful.spawn.spawn('amixer sset -D pulse Master 5%+')
        vslider.value = vslider.value + 5
    end },
    {{ }, 'd', function() 
        awful.spawn.spawn('amixer sset -D pulse Master 15%-')
        vslider.value = vslider.value - 15
    end },
    {{ }, 'u', function() 
        awful.spawn.spawn('amixer sset -D pulse Master 15%+')
        vslider.value = vslider.value + 15
    end },
    {{ }, 'Return', function() 
        awful.spawn.spawn('amixer -D pulse set Master 1+ toggle')
    end },
})

---------------------------------------
-- RETURN
---------------------------------------

return volume
