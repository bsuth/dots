local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

---------------------------------------
-- WIDGET
---------------------------------------

local state = {
    value = 25,
    pvalue = nil,
}

local gradient = { 
    type = 'linear',
    from = { 0, 0 },
    to = { 100, 0 },
    stops = {
        { 0, '#70fabc' },
        { 1, '#78f597' },
    },
}

local vprogressbar = wibox.widget({
    background_color = beautiful.colors.black,
    color = gradient,

    value = state.value,
    max_value = 100,

    shape = gears.shape.rounded_bar,
    bar_shape = gears.shape.rounded_bar,
    widget = wibox.widget.progressbar,
})

local volume = wibox.widget({
    {
        {
            text   = 'volume',
            widget = wibox.widget.textbox,
        },

        vprogressbar,
        layout = wibox.layout.fixed.horizontal,
    },

    widget  = wibox.container.background,
})

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
