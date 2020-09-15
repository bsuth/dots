local awful = require 'awful' 
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

local volume_slider = slider({
    icon = 'vol',
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
    icon = 'br',
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
    icon = 'bat',
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
