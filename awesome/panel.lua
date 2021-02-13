local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'

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
-- TAGLIST
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

	local w = wibox.widget {
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

	function update()
		spaceship:set_visible(s.selected_tag.index == index)
		moon:set_visible(#s.tags[index]:clients() > 0)
		planet:emit_signal('widget::redraw_needed')
	end

	s:connect_signal('tag::history::update', update)
	s.tags[index]:connect_signal('tagged', update)
	s.tags[index]:connect_signal('untagged', update)

	update()
	return w
end

-- -----------------------------------------------------------------------------
-- PANEL
-- -----------------------------------------------------------------------------

local panel = {}

function panel.attach(s)
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
					{
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
						wibox.widget.systray(),
						layout = wibox.layout.fixed.horizontal,
					},
					margins = config.padding,
					widget = wibox.container.margin,
				},
				bg = '#181818',
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
end

return panel
