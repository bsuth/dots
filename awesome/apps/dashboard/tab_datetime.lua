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
    forced_width = 100,
    forced_height = 100,

    icon = beautiful.icon('volume'),
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
    forced_width = 100,
    forced_height = 100,

    icon = beautiful.icon('brightness'),
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
    forced_width = 100,
    forced_height = 100,

    icon = battery:get('icon'),
    color = beautiful.colors.red,
    percent = battery:get(),

    widget = dial,
})

battery:connect_signal('update', function()
    _battery.percent = battery:get()
    _battery.icon = battery:get('icon')

	-- layout_changed needed to update icon
    _battery:emit_signal('widget::layout_changed')
    _battery:emit_signal('widget::redraw_needed')
end)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return {
    icon = beautiful.icon('clock'),
    keygrabber = {},
    widget = wibox.widget({
		{
			{
				{
					format = ("<span color='%s'>%%H</span><span color='%s'>%%M</span>"):format(
						beautiful.colors.white, beautiful.colors.cyan
					),
					font = 'Titan One 75',
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
								forced_width = 225,
								forced_height = 7,
								widget = wibox.widget.separator,
							},
							widget = wibox.container.place,
						},
						{
							{
								image = beautiful.icon('clock'),
								forced_width = 50,
								forced_height = 50,
								widget = wibox.widget.imagebox,
							},
							widget = wibox.container.place,
						},
						{
							{
								color = beautiful.colors.cyan,
								shape = gears.shape.rounded_bar,
								forced_width = 225,
								forced_height = 7,
								widget = wibox.widget.separator,
							},
							widget = wibox.container.place,
						},
						spacing = 30,
						layout = wibox.layout.fixed.horizontal,
					},
					widget = wibox.container.place,
				},
				top = 30,
				bottom = 20,
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
        widget = wibox.container.place,
    }),
}
