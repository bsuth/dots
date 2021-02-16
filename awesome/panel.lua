local awful = require 'awful'
local beautiful = require 'beautiful'
local dial = require 'widgets/dial'
local gears = require 'gears'
local models = require 'newmodels'
local naughty = require 'naughty'
local rotator = require 'widgets/rotator'
local wibox = require 'wibox'

-- -----------------------------------------------------------------------------
-- CONFIG
-- -----------------------------------------------------------------------------

local config = {
	height = 75,
	padding = 15,
	border_width = 2,
	compass_size = 60,
	planets = {
		'volcano',
		'desert',
		'nature',
		'volcano',
		'volcano',
		'frost',
		'frost',
		'frost',
		'frost',
	},
}

-- -----------------------------------------------------------------------------
-- TAGLIST
-- -----------------------------------------------------------------------------

function taglist(s)
	local template = {
		layout = wibox.layout.fixed.horizontal,
	}

	for i = 1, 9 do
		local planet = wibox.widget {
			image = beautiful.icon('space/planets/' .. config.planets[i]),
			widget = wibox.widget.imagebox,
		}

		local spaceship = wibox.widget {
			image = beautiful.icon('space/spaceship-at-rest'),
			widget = wibox.widget.imagebox,
		}

		local moon = wibox.widget {
			image = beautiful.icon('space/moon'),
			widget = wibox.widget.imagebox,
		}

		function update()
			spaceship:set_visible(s.selected_tag.index == i)
			moon:set_visible(#s.tags[i]:clients() > 0)
			planet:emit_signal('widget::redraw_needed')
		end

		s:connect_signal('tag::history::update', update)
		s.tags[i]:connect_signal('tagged', update)
		s.tags[i]:connect_signal('untagged', update)
		update()

		template[i] = wibox.widget {
			{
				planet,
				{
					{
						spaceship,
						top = 20,
						bottom = 5,
						widget = wibox.container.margin,
					},
					widget = wibox.container.place,
				},
				{
					moon,
					bottom = 40,
					left = 40,
					widget = wibox.container.margin,
				},
				forced_width = config.height - 10,
				forced_height = config.height - 10,
				layout = wibox.layout.stack,
			},
			forced_width = config.height,
			forced_height = config.height,
			widget = wibox.container.place,
		}
	end

	return wibox.widget(template)
end

-- -----------------------------------------------------------------------------
-- VOLUME
-- -----------------------------------------------------------------------------

local volume = wibox.widget {
    forced_width = config.height,
    forced_height = config.height,

    icon = beautiful.icon('volume'),
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

    icon = beautiful.icon('brightness'),
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
    image = beautiful.icon('battery/meter'),
	widget = wibox.widget.imagebox,
}

local battery_arrow = wibox.widget {
    image = beautiful.icon('battery/arrow'),
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

	if models.battery.discharging then
		if models.battery.percent < 25 then
			battery_notice.image = beautiful.icon('battery/warning')
		else
			battery_notice.image = beautiful.icon('battery/discharging')
		end
	else
		battery_notice.image = beautiful.icon('battery/charging')
	end

    battery_notice:emit_signal('widget::layout_changed')
end)

-- -----------------------------------------------------------------------------
-- PANEL
-- -----------------------------------------------------------------------------

return {
	attach = function(s)
		local content = wibox.widget {
			taglist(s),
			{
				margins = config.height / 2,
				widget = wibox.container.margin,
			},
			volume,
			brightness,
			battery,
			-- wibox.widget.systray(),
			layout = wibox.layout.fixed.horizontal,
		}

		s.wibar = wibox {
			screen = s,
			x = s.geometry.x,
			y = s.geometry.y + s.geometry.height
				- config.height
				- 2 * config.padding
				- config.compass_size / 2
				- config.border_width,
			width = s.geometry.width,
			height = config.height
				+ 2 * config.padding
				+ config.compass_size / 2
				+ 2 * config.border_width,
			visible = true,
			ontop = true,
			type = 'dock',
			bg = '00000000',
		}

		s.wibar:setup {
			{
				{
					{
						content,
						margins = config.padding,
						widget = wibox.container.margin,
					},
					bg = beautiful.colors.black,
					shape = function(cr, width, height)
						gears.shape.partially_rounded_rect(cr, width, height, true, true)
					end,
					shape_border_width = config.border_width,
					shape_border_color = beautiful.colors.white,
					widget = wibox.container.background,
				},
				{
					{
						{
							forced_width = config.compass_size,
							forced_height = config.compass_size,
							image = beautiful.icon('compass'),
							widget = wibox.widget.imagebox,
						},
						top = -1 -- the svg itself has a 1px padding
							+ config.border_width
							- config.compass_size / 2,
						widget = wibox.container.margin,
					},
					valign = 'top',
					widget = wibox.container.place,
				},
				layout = wibox.layout.stack,
			},
			valign = 'bottom',
			widget = wibox.container.place,
		}
	end,
}
