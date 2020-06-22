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
        volume:change_rel(-5)
    end },
    {{ }, 'k', function() 
        volume:change_rel(5)
    end },
    {{ }, 'd', function() 
        volume:change_rel(-15)
    end },
    {{ }, 'u', function() 
        volume:change_rel(15)
    end },
    {{ }, 'Return', function() 
        volume:mute()
    end },
})

---------------------------------------
-- API
---------------------------------------

function volume:mute()
    awful.spawn.spawn('amixer -D pulse set Master 1+ toggle')

    if vslider.pvalue then
        vslider.value = vslider.pvalue
        vslider.pvalue = nil
        vslider.bar_color = beautiful.border_color
        vslider.handle_color = beautiful.bg_normal
    else
        vslider.pvalue = vslider.value
        vslider.value = 0
        vslider.bar_color = beautiful.colors.red
        vslider.handle_color = beautiful.colors.red
    end
end

function volume:change_rel(delta)
    local sign = delta < 0 and '-' or '+'
    awful.spawn.spawn(string.format('amixer sset -D pulse Master %d%%%s', math.abs(delta), sign))
    vslider.value = vslider.value + delta
end

---------------------------------------
-- RETURN
---------------------------------------

local cmd = [[ bash -c "amixer sget -D pulse Master | grep -oE '[0-9]+%' | head --lines 1" ]]

awful.spawn.easy_async(cmd, function(stdout, stderr, exitreason, exitcode)
    local x = tonumber(string.sub(stdout, 1, -2))
    naughty.notify({text=tostring(x)})
    naughty.notify({text=tostring(stdout)})
end)

return volume
