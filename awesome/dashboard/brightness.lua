local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local hkeys = require('helpers.keys')

---------------------------------------
-- BRIGHTNESS WIDGET
---------------------------------------

local state = {
    value = 25,
    pvalue = nil,
}

local bprogressbar  = wibox.widget({
    background_color = beautiful.colors.dark_grey,
    color = beautiful.colors.yellow,

    value = state.value,
    max_value = 100,

    widget = wibox.widget.progressbar,
})

local brightness = wibox.widget({
    {
        {
            text   = 'b',
            widget = wibox.widget.textbox,
        },
        {
            bprogressbar,
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

brightness.keys = hkeys.create_keys({
    {{ }, 'j', function() 
        brightness:change_rel(-5)
    end },
    {{ }, 'k', function() 
        brightness:change_rel(5)
    end },
    {{ }, 'd', function() 
        brightness:change_rel(-15)
    end },
    {{ }, 'u', function() 
        brightness:change_rel(15)
    end },
})

---------------------------------------
-- API
---------------------------------------

function brightness:change_rel(delta)
    local sign

    if delta < 0 then
        sign = '-'
        delta = math.max(delta, -1 * state.value)
    else
        sign = '+'
        delta = math.min(delta, 100 - state.value)
    end

    if delta ~= 0 then
        awful.spawn.spawn(string.format('xbacklight %s%d', sign, math.abs(delta)))
        state.value = state.value + delta
        bprogressbar:set_value(state.value)
    end
end

---------------------------------------
-- RETURN
---------------------------------------

local cmd = [[ bash -c "xbacklight | sed -E 's/([0-9]+)\..*/\1/'"]]

awful.spawn.easy_async(cmd, function(stdout)
    state.value = tonumber(string.gsub(stdout, '%s+', ''), 10)
    bprogressbar:set_value(state.value)
end)

return brightness
