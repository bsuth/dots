local gears = require 'gears' 
local wibox = require 'wibox' 

local slider = require 'widgets/slider' 

--------------------------------------------------------------------------------
-- TIME
--------------------------------------------------------------------------------

local time = wibox.widget({
    format = "<span color='#ff0000'>%H</span><span color='#00ff00'>%M</span>",
    font = 'Titan One 50',
    widget = wibox.widget.textclock,
})

--------------------------------------------------------------------------------
-- DATE
--------------------------------------------------------------------------------

local date = wibox.widget({
    format = "<span>%a %b %d, %Y</span>",
    font = 'Titan One 15',
    widget = wibox.widget.textclock,
})

--------------------------------------------------------------------------------
-- SEPARATOR
--------------------------------------------------------------------------------

local separator = wibox.widget({
    {
        {
            color = '#ff0000',
            shape = gears.shape.rounded_bar,
            forced_width = 100,
            forced_height = 5,
            widget = wibox.widget.separator,
        },
        widget = wibox.container.place,
    },
    {
        {
            markup = 'h',
            widget = wibox.widget.textbox,
        },
        widget = wibox.container.place,
    },
    {
        {
            color = '#ff0000',
            shape = gears.shape.rounded_bar,
            forced_width = 100,
            forced_height = 5,
            widget = wibox.widget.separator,
        },
        widget = wibox.container.place,
    },
    spacing = 15,
    layout = wibox.layout.fixed.horizontal,
})

--------------------------------------------------------------------------------
-- SLIDERS
--------------------------------------------------------------------------------

-- local volume_slider = slider({ icon = 'vol', value = 50, })
-- local brightness_slider = slider({ icon = 'br', value = 50, })
-- local battery_slider = slider({ icon = 'bat', value = 50, })

local sliders = wibox.widget({
    {
        {
            slider({ icon = 'vol', value = 50 }),
            slider({ icon = 'br', value = 50 }),
            slider({ icon = 'bat', value = 50 }),
            spacing = 20,
            forced_width = 200,
            forced_height = 100,
            layout = wibox.layout.flex.vertical,
        },
        top = 20,
        bottom = 20,
        widget = wibox.container.margin,
    },
    widget = wibox.container.place,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return wibox.widget({
    {
        {
            {
                {
                    time,
                    widget = wibox.container.place,
                },
                {
                    date,
                    widget = wibox.container.place,
                },
                {
                    separator,
                    widget = wibox.container.place,
                },
                {
                    sliders,
                    widget = wibox.container.place,
                },
                spacing = 0,
                layout = wibox.layout.fixed.vertical,
            },
            top = 20,
            bottom = 20,
            left = 50,
            right = 50,
            widget = wibox.container.margin,
        },
        shape = gears.shape.rectangle,
        shape_border_color = '#d8d8d8',
        shape_border_width = 2,
        bg = '#181818',
        widget = wibox.container.background,
    },
    widget = wibox.container.place,
})
