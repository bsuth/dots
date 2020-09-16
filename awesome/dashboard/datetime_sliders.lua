local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

local volume = require 'singletons/volume'
local brightness = require 'singletons/brightness'
local battery = require 'singletons/battery'

local slider = require 'widgets/slider' 

--------------------------------------------------------------------------------
-- TIME
--------------------------------------------------------------------------------

local time = wibox.widget({
    format = ("<span color='%s'>%%H</span><span color='%s'>%%M</span>"):format(
        beautiful.colors.white, beautiful.colors.cyan
    ),
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
})

--------------------------------------------------------------------------------
-- SLIDERS
--------------------------------------------------------------------------------

local volume_slider = slider({
    icon = beautiful.icon('apps/cs-sound.svg'),
    color = beautiful.colors.green,
    init = function(self)
        self:set_value(volume:get())
        volume:connect_signal('update', function()
            self:set_value(volume:get())
        end)
    end,
    scroll_up = function(self) volume:shift(5) end,
    scroll_down = function(self) volume:shift(-5) end,
})

local brightness_slider = slider({
    icon = beautiful.icon('apps/display-brightness.svg'),
    color = beautiful.colors.yellow,
    init = function(self)
        self:set_value(brightness:get())
        brightness:connect_signal('update', function()
            self:set_value(brightness:get())
        end)
    end,
    scroll_up = function(self) brightness:shift(5) end,
    scroll_down = function(self) brightness:shift(-5) end,
})

local battery_slider = slider({
    icon = beautiful.icon('apps/cs-power.svg'),
    color = beautiful.colors.red,
    init = function(self)
        self:set_value(battery:get())
        battery:connect_signal('update', function()
            self:set_value(battery:get())
        end)
    end,
})

local sliders = wibox.widget({
    {
        {
            volume_slider,
            brightness_slider,
            battery_slider,
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
                    {
                        separator,
                        top = 10,
                        widget = wibox.container.margin,
                    },
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
        shape_border_color = beautiful.colors.cyan,
        shape_border_width = 2,
        bg = '#181818',
        widget = wibox.container.background,
    },
    widget = wibox.container.place,
})
