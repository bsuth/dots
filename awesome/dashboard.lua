local awful = require 'awful'
local beautiful = require 'beautiful'
local dial = require 'widgets/dial'
local gears = require 'gears'
local models = require 'models'
local naughty = require 'naughty'
local rotator = require 'widgets/rotator'
local taglist = require 'taglist'
local wibox = require 'wibox'

-- -----------------------------------------------------------------------------
-- CONFIG
-- -----------------------------------------------------------------------------

local config = {
	width = 1000,
	height = 50,
	margin = 100,
	padding = 10,
	border_width = 2,
}

local state = {
	taglist_was_active = false,
}

-- -----------------------------------------------------------------------------
-- VOLUME
-- -----------------------------------------------------------------------------

local volume = wibox.widget {
    forced_width = config.height,
    forced_height = config.height,

    icon = beautiful.icon('systray/volume-unmute'),
    percent = models.volume.percent,

    color = beautiful.colors.green,
	background = '#000000',
	border_width = 5,

    onscrollup = function() models.volume:shift(5) end,
    onscrolldown = function() models.volume:shift(-5) end,

    widget = dial,
}

models.volume:connect_signal('update', function()
    volume.percent = models.volume.percent
    volume:emit_signal('widget::redraw_needed')
end)

-- -----------------------------------------------------------------------------
-- BRIGHTNESS
-- -----------------------------------------------------------------------------

local brightness = wibox.widget {
    forced_width = config.height,
    forced_height = config.height,

    icon = beautiful.icon('systray/brightness'),
    percent = models.volume.percent,

    color = beautiful.colors.yellow,
	background = '#000000',
	border_width = 5,

    onscrollup = function() models.brightness:shift(5) end,
    onscrolldown = function() models.brightness:shift(-5) end,

    widget = dial,
}

models.brightness:connect_signal('update', function()
    brightness.percent = models.brightness.percent
    brightness:emit_signal('widget::redraw_needed')
end)

-- -----------------------------------------------------------------------------
-- BATTERY
-- -----------------------------------------------------------------------------

function calc_arrow_rot(p)
	return (math.pi / 4) * (6 * p / 100 - 5)
end

local battery_meter = wibox.widget {
    image = beautiful.icon('systray/battery-meter'),
	widget = wibox.widget.imagebox,
}

local battery_arrow = wibox.widget {
    image = beautiful.icon('systray/battery-arrow'),
	widget = wibox.widget.imagebox,
}

local battery_arrow_rotation = wibox.widget {
	origin_x = 32.8125,
	origin_y = 37.5,
	theta = calc_arrow_rot(models.battery.percent),
	rotatee = battery_arrow,
	widget = rotator,
}

local battery_notice = wibox.widget {
	widget = wibox.widget.imagebox,
}

local battery = wibox.widget {
	battery_meter,
	battery_arrow_rotation,
	battery_notice,
	forced_width = config.height,
	forced_height = config.height,
	layout = wibox.layout.stack,
}

models.battery:connect_signal('update', function()
	battery_arrow_rotation.theta = calc_arrow_rot(models.battery.percent)
	battery_arrow_rotation:emit_signal('widget::layout_changed')
	local icon_src = 'systray/battery-charging'

	if models.battery.discharging then
		if models.battery.percent < 25 then
			icon_src = 'systray/battery-warning'
		else
			icon_src = 'systray/battery-discharging'
		end
	end

	battery_notice.image = beautiful.icon(icon_src)
    battery_notice:emit_signal('widget::layout_changed')
end)

-- -----------------------------------------------------------------------------
-- DASHBOARD
-- -----------------------------------------------------------------------------

local dashboard = wibox {
	visible = false,
	ontop = true,
	type = 'dock',
	bg = '00000000',
}

local content = {
	{
		volume,
		brightness,
		battery,
		wibox.widget.systray(),
		layout = wibox.layout.fixed.horizontal,
	},
	forced_width = 1000,
	forced_height = 600,
	bg = beautiful.colors.black,
	shape = gears.shape.rectangle,
	shape_border_width = config.border_width,
	shape_border_color = beautiful.colors.white,
	widget = wibox.container.background,
}

dashboard:setup {
	{
		content,
		widget = wibox.container.place,
	},
	bg = beautiful.colors.dimmed,
	widget = wibox.container.background,
}

return {
	toggle = function()
		local s = awful.screen.focused()

		if not dashboard.visible then
			gears.table.crush(dashboard, {
				screen = s,
				visible = true,
				x = s.geometry.x,
				y = s.geometry.y,
				width = s.geometry.width,
				height = s.geometry.height,
			})

			state.taglist_was_active = s.taglist.visible

			-- Make sure the taglist appears on top of the dimmed background
			s.taglist.visible = false 
			s.taglist.visible = true 
		else
			if not state.taglist_was_active then
				s.taglist.visible = false 
			end

			dashboard.visible = false
		end
	end,
}
