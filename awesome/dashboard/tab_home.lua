local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

local volume_model = require 'models/volume'
local brightness_model = require 'models/brightness'
local battery_model = require 'models/battery'
local ram_model = require 'models/ram'
local cpu_model = require 'models/cpu'

local dial = require 'widgets/dial' 

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- Widgets --

local volume_widget = {}
local brightness_widget = {}
local battery_widget = {}
local ram_widget = {}
local cpu_widget = {}

--------------------------------------------------------------------------------
-- WIDGET: VOLUME
--------------------------------------------------------------------------------

volume_widget = wibox.widget({
    forced_width = 100,
    forced_height = 100,

    icon = beautiful.icon('volume'),
    color = beautiful.colors.green,
    percent = volume_model.percent,

    onscrollup = function(self) volume_model:shift(5) end,
    onscrolldown = function(self) volume_model:shift(-5) end,

    widget = dial,
})

--------------------------------------------------------------------------------
-- WIDGET: BRIGHTNESS
--------------------------------------------------------------------------------

brightness_widget = wibox.widget({
    forced_width = 100,
    forced_height = 100,

    icon = beautiful.icon('brightness'),
    color = beautiful.colors.yellow,
    percent = brightness_model.percent,

    onscrollup = function(self) brightness_model:shift(5) end,
    onscrolldown = function(self) brightness_model:shift(-5) end,

    widget = dial,
})

--------------------------------------------------------------------------------
-- WIDGET: BATTERY
--------------------------------------------------------------------------------

battery_widget = wibox.widget({
    forced_width = 100,
    forced_height = 100,

    icon = battery_model.icon,
    color = beautiful.colors.red,
    percent = battery_model.percent,

    widget = dial,
})

--------------------------------------------------------------------------------
-- WIDGET: RAM
--------------------------------------------------------------------------------

ram_widget = wibox.widget({
    forced_width = 100,
    forced_height = 100,

    icon = beautiful.icon('ram'),
    color = beautiful.colors.purple,
    percent = ram_model.percent,

    widget = dial,
})

--------------------------------------------------------------------------------
-- WIDGET: CPI
--------------------------------------------------------------------------------

cpu_widget = wibox.widget({
    forced_width = 100,
    forced_height = 100,

    icon = beautiful.icon('cpu'),
    color = beautiful.colors.blue,
    percent = cpu_model.percent,

    widget = dial,
})

--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------

volume_model:connect_signal('update', function()
    volume_widget.percent = volume_model.percent
    volume_widget:emit_signal('widget::redraw_needed')
end)

brightness_model:connect_signal('update', function()
    brightness_widget.percent = brightness_model.percent
    brightness_widget:emit_signal('widget::redraw_needed')
end)

battery_model:connect_signal('update', function()
    battery_widget.percent = battery_model.percent
    battery_widget.icon = battery_model.icon

	-- layout_changed needed to update icon
    battery_widget:emit_signal('widget::layout_changed')
    battery_widget:emit_signal('widget::redraw_needed')
end)

ram_model:connect_signal('update', function()
    ram_widget.percent = ram_model.percent
    ram_widget:emit_signal('widget::redraw_needed')
end)

cpu_model:connect_signal('update', function()
    cpu_widget.percent = cpu_model.percent
    cpu_widget:emit_signal('widget::redraw_needed')
end)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return {
    icon = beautiful.icon('home'),
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
							volume_widget,
							brightness_widget,
							spacing = 75,
							layout = wibox.layout.flex.horizontal,
						},
						widget = wibox.container.place,
					},
					{
						{
							ram_widget,
							battery_widget,
							cpu_widget,
							spacing = 75,
							layout = wibox.layout.flex.horizontal,
						},
						widget = wibox.container.place,
					},
					layout = wibox.layout.flex.vertical,
				},
				top = 10,
				widget = wibox.container.margin,
			},
			layout = wibox.layout.fixed.vertical,
		},
        widget = wibox.container.place,
    }),
}
