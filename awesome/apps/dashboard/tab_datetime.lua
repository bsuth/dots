local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

local volume = require 'singletons/volume'
local brightness = require 'singletons/brightness'
local battery = require 'singletons/battery'

local dial = require 'widgets/dial' 

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- Widgets --

local _volume = {}
local _brightness = {}
local _battery = {}

--------------------------------------------------------------------------------
-- WIDGET: VOLUME
--------------------------------------------------------------------------------

_volume = wibox.widget({
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
    _volume.percent = volume:get()
    _volume:emit_signal('widget::redraw_needed')
end)

--------------------------------------------------------------------------------
-- WIDGET: BRIGHTNESS
--------------------------------------------------------------------------------

_brightness = wibox.widget({
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
    _brightness.percent = brightness:get()
    _brightness:emit_signal('widget::redraw_needed')
end)

--------------------------------------------------------------------------------
-- WIDGET: BATTERY
--------------------------------------------------------------------------------

_battery = wibox.widget({
    forced_width = 70,
    forced_height = 70,

    icon = beautiful.icon('devices/battery.svg'),
    color = beautiful.colors.red,
    percent = battery:get(),

    widget = dial,
})

battery:connect_signal('update', function()
    _battery.percent = battery:get()
    _battery.icon = battery:get('status_icon')
    _battery:emit_signal('widget::redraw_needed')
end)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return {
    icon = beautiful.icon('todo'),
    keygrabber = {},
    widget = wibox.widget({
        {
            {
                {
                    {
                        {
                            format = ("<span color='%s'>%%H</span><span color='%s'>%%M</span>"):format(
                                beautiful.colors.white, beautiful.colors.cyan
                            ),
                            font = 'Titan One 50',
                            widget = wibox.widget.textclock,
                        },
                        widget = wibox.container.place,
                    },
                    {
                        {
                            format = "<span>%a %b %d, %Y</span>",
                            widget = wibox.widget.textclock,
                        },
                        widget = wibox.container.place,
                    },
                    {
                        {
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
                        },
                        top = 10,
                        widget = wibox.container.margin,
                    },
                    {
                        {
                            {
                                {
                                    _volume,
                                    _brightness,
                                    spacing = 50,
                                    layout = wibox.layout.flex.horizontal,
                                },
                                {
                                    _battery,
                                    widget = wibox.container.place,
                                },
                                layout = wibox.layout.flex.vertical,
                            },
                            top = 10,
                            widget = wibox.container.margin,
                        },
                        widget = wibox.container.place,
                    },
                    layout = wibox.layout.fixed.vertical,
                },
                margins = 50,
                widget = wibox.container.margin,
            },
            shape = gears.shape.circle,
            bg = beautiful.colors.black,
            widget = wibox.container.background,
        },
        widget = wibox.container.place,
    }),
}
