local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

local volume = require 'singletons/volume'
local brightness = require 'singletons/brightness'
local battery = require 'singletons/battery'

local dial = require 'widgets/dial' 

--------------------------------------------------------------------------------
-- TIME
--------------------------------------------------------------------------------

local time = wibox.widget({
    {
        format = ("<span color='%s'>%%H</span><span color='%s'>%%M</span>"):format(
            beautiful.colors.white, beautiful.colors.cyan
        ),
        font = 'Titan One 50',
        widget = wibox.widget.textclock,
    },
    widget = wibox.container.place,
})

--------------------------------------------------------------------------------
-- DATE
--------------------------------------------------------------------------------

local date = wibox.widget({
    {
        format = "<span>%a %b %d, %Y</span>",
        font = 'Titan One 15',
        widget = wibox.widget.textclock,
    },
    widget = wibox.container.place,
})

--------------------------------------------------------------------------------
-- SEPARATOR
--------------------------------------------------------------------------------

local separator = wibox.widget({
    {
        {
            {
                color = beautiful.colors.cyan,
                shape = gears.shape.rounded_bar,
                forced_width = 100,
                forced_height = 5,
                widget = wibox.widget.separator,
            },
            widget = wibox.container.place,
        },
        {
            {
                image = beautiful.icon('apps/cs-date-time.svg'),
                forced_width = 30,
                forced_height = 30,
                widget = wibox.widget.imagebox,
            },
            widget = wibox.container.place,
        },
        {
            {
                color = beautiful.colors.cyan,
                shape = gears.shape.rounded_bar,
                forced_width = 100,
                forced_height = 5,
                widget = wibox.widget.separator,
            },
            widget = wibox.container.place,
        },
        spacing = 15,
        layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
})

--------------------------------------------------------------------------------
-- DIALS
--------------------------------------------------------------------------------

local volume_dial = wibox.widget({
    forced_width = 70,
    forced_height = 70,

    icon = beautiful.icon('apps/cs-sound.svg'),
    color = beautiful.colors.green,
    percent = volume:get(),

    onscrollup = function(self) volume:shift(5) end,
    onscrolldown = function(self) volume:shift(-5) end,

    widget = dial,
})

volume:connect_signal('update', function()
    volume_dial.percent = volume:get()
    volume_dial:emit_signal('widget::redraw_needed')
end)

local brightness_dial = wibox.widget({
    forced_width = 70,
    forced_height = 70,

    icon = beautiful.icon('apps/display-brightness.svg'),
    color = beautiful.colors.yellow,
    percent = brightness:get(),

    onscrollup = function(self) brightness:shift(5) end,
    onscrolldown = function(self) brightness:shift(-5) end,

    widget = dial,
})

brightness:connect_signal('update', function()
    brightness_dial.percent = brightness:get()
    brightness_dial:emit_signal('widget::redraw_needed')
end)

local battery_dial = wibox.widget({
    forced_width = 70,
    forced_height = 70,

    icon = beautiful.icon('devices/battery.svg'),
    color = beautiful.colors.red,
    percent = battery:get(),

    widget = dial,
})

battery:connect_signal('update', function()
    battery_dial.percent = battery:get()
    battery.icon = battery:get('status_icon')
    brightness_dial:emit_signal('widget::redraw_needed')
end)

local dials = wibox.widget({
    {
        {
            {
                volume_dial,
                brightness_dial,
                spacing = 50,
                layout = wibox.layout.flex.horizontal,
            },
            {
                battery_dial,
                widget = wibox.container.place,
            },
            layout = wibox.layout.flex.vertical,
        },
        top = 10,
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
                time,
                date,
                {
                    separator,
                    top = 10,
                    widget = wibox.container.margin,
                },
                dials,
                layout = wibox.layout.fixed.vertical,
            },
            margins = 50,
            widget = wibox.container.margin,
        },
        shape = gears.shape.circle,
        shape_border_color = beautiful.colors.cyan,
        shape_border_width = 5,
        bg = beautiful.colors.black,
        widget = wibox.container.background,
    },
    widget = wibox.container.place,
})
