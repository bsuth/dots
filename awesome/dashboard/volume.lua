local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local hkeys = require('helpers.keys')

---------------------------------------
-- VOLUME WIDGET
---------------------------------------

local state = {
    value = 25,
    pvalue = nil,
}

local vprogressbar = wibox.widget({
    background_color = beautiful.colors.dark_grey,
    color = beautiful.colors.green,

    value = state.value,
    max_value = 100,

    widget = wibox.widget.progressbar,
})

local volume = wibox.widget({
    {
        {
            text   = 'v',
            widget = wibox.widget.textbox,
        },
        {
            vprogressbar,
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

    if state.pvalue then
        state.value = state.pvalue
        state.pvalue = nil
    else
        state.pvalue = state.value
        state.value = 0
    end

    vprogressbar:set_value(state.value)
end

function volume:change_rel(delta)
    local sign

    if delta < 0 then
        sign = '-'
        delta = math.max(delta, -state.value)
    else
        sign = '+'
        delta = math.min(delta, 100 - state.value)
    end

    if delta ~= 0 then
        awful.spawn.spawn(string.format('amixer sset -D pulse Master %d%%%s', math.abs(delta), sign))
        state.value = state.value + delta
        vprogressbar:set_value(state.value)
    end
end

---------------------------------------
-- RETURN
---------------------------------------

local cmd = [[ bash -c "
    amixer sget -D pulse Master |
    grep -oE '[0-9]+%' |
    head --lines 1
"]]

awful.spawn.easy_async(cmd, function(stdout)
    state.value = tonumber(string.sub(string.gsub(stdout, '%s+', ''), 1, -2), 10)
    vprogressbar:set_value(state.value)
end)

return volume
