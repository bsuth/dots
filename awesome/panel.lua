local awful = require 'awful'
local beautiful = require 'beautiful'
local dial = require 'widgets/dial'
local gears = require 'gears'
local models = require 'newmodels'
local naughty = require 'naughty'
local wibox = require 'wibox'

-- -----------------------------------------------------------------------------
-- CONFIG
-- -----------------------------------------------------------------------------

local config = {
	height = 75,
	padding = 15,
	planets = {
		'volcano',
		'volcano',
		'volcano',
		'volcano',
		'volcano',
		'frost',
		'frost',
		'frost',
		'frost',
	},
}

-- -----------------------------------------------------------------------------
-- TAGLIST ITEM
-- -----------------------------------------------------------------------------

function taglist_item(s, index)
	local planet = wibox.widget {
		image = beautiful.icon('space/planets/' .. config.planets[index]),
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
		spaceship:set_visible(s.selected_tag.index == index)
		moon:set_visible(#s.tags[index]:clients() > 0)
		planet:emit_signal('widget::redraw_needed')
	end

	s:connect_signal('tag::history::update', update)
	s.tags[index]:connect_signal('tagged', update)
	s.tags[index]:connect_signal('untagged', update)
	update()

	return wibox.widget {
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

-- -----------------------------------------------------------------------------
-- VOLUME
-- -----------------------------------------------------------------------------

local volume = wibox.widget {
    forced_width = config.height,
    forced_height = config.height,

    icon = beautiful.icon('volume'),
    percent = models.volume.percent,

    color = beautiful.colors.green,
	background = '#181818',
	border_width = 5,

    onscrollup = function() models.volume:shift(5) end,
    onscrolldown = function() models.volume:shift(-5) end,

    widget = dial,
}

models.volume:connect_signal('update', function()
    volume.percent = models.volume.percent

	-- widget::layout_changed needed to update icon
    volume:emit_signal('widget::layout_changed')
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
	background = '#181818',
	border_width = 5,

    onscrollup = function() models.brightness:shift(5) end,
    onscrolldown = function() models.brightness:shift(-5) end,

    widget = dial,
}

models.brightness:connect_signal('update', function()
    brightness.percent = models.brightness.percent

	-- widget::layout_changed needed to update icon
    brightness:emit_signal('widget::layout_changed')
    brightness:emit_signal('widget::redraw_needed')
end)

-- -----------------------------------------------------------------------------
-- BATTERY
-- -----------------------------------------------------------------------------

local battery = wibox.widget {
    forced_width = config.height,
    forced_height = config.height,

    icon = beautiful.icon('battery-discharging'),
    percent = models.volume.percent,

    color = beautiful.colors.red,
	background = '#181818',
	border_width = 5,

    widget = dial,
}

models.battery:connect_signal('update', function()
    battery.percent = models.battery.percent

	-- widget::layout_changed needed to update icon
    battery:emit_signal('widget::layout_changed')
    battery:emit_signal('widget::redraw_needed')
end)

-- -----------------------------------------------------------------------------
-- PANEL
-- -----------------------------------------------------------------------------

return {
	attach = function(s)
		local content = wibox.widget {
			{
				taglist_item(s, 1),
				taglist_item(s, 2),
				taglist_item(s, 3),
				taglist_item(s, 4),
				taglist_item(s, 5),
				taglist_item(s, 6),
				taglist_item(s, 7),
				taglist_item(s, 8),
				taglist_item(s, 9),
				layout = wibox.layout.fixed.horizontal,
			},
			{
				margins = config.height / 2,
				widget = wibox.container.margin,
			},
			volume,
			brightness,
			battery,
			wibox.widget.systray(),
			layout = wibox.layout.fixed.horizontal,
		}

		s.wibar = wibox {
			screen = s,
			x = s.geometry.x,
			y = s.geometry.y + s.geometry.height - config.height - 2 * config.padding,
			width = s.geometry.width,
			height = config.height + 2 * config.padding,
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
					shape = gears.shape.rounded_bar,
					shape_border_width = 5,
					shape_border_color = '#e0e0e0',
					widget = wibox.container.background,
				},
				widget = wibox.container.place,
			},
			bottom = 10,
			widget = wibox.container.margin,
		}
	end,
}