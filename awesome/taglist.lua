local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'

-- -----------------------------------------------------------------------------
-- CONSTANTS / CONFIG
-- -----------------------------------------------------------------------------

-- Properties of the solarsystem svg
local svg = {
	width = 832,
	height = 64,
	padding = 8,
	block_size = 64,
}

local config = {
	spaceship_width = 30,
	moon_size = 20,
	compass_size = 40,
	border_width = 2,
}

-- -----------------------------------------------------------------------------
-- SPACESHIP
-- -----------------------------------------------------------------------------

function create_spaceship(s)
	local spaceship = wibox.widget {
		layout = wibox.layout.manual,
	}

	spaceship:add_at(wibox.widget {
		forced_width = config.spaceship_width,
		image = beautiful.icon('space/spaceship-at-rest'),
		widget = wibox.widget.imagebox,
	}, { x = 0, y = 0 })

	function update_spaceship()
		local i = s.selected_tag.index
		spaceship:move(1, {
			x = 3 * svg.block_size
				+ (i - 1) * svg.block_size
				+ svg.block_size / 2
				- config.spaceship_width / 2,
			y = svg.padding + 10,
		})
	end

	s:connect_signal('tag::history::update', update_spaceship)
	update_spaceship()
	return spaceship
end

-- -----------------------------------------------------------------------------
-- MOONS
-- -----------------------------------------------------------------------------

function create_moons(s)
	local moons = wibox.widget {
		layout = wibox.layout.manual,
	}

	for i = 1, 9 do
		local moon = wibox.widget {
			forced_width = config.moon_size,
			forced_height = config.moon_size,
			image = beautiful.icon('space/moon'),
			widget = wibox.widget.imagebox,
		}

		moons:add_at(moon, {
			x = 3 * svg.block_size
				+ (i - 1) * svg.block_size
				+ svg.block_size
				- svg.padding
				- config.moon_size / 2
				- 5,
			y = svg.padding,
		})

		function update()
			moon:set_visible(#s.tags[i]:clients() > 0)
		end

		s.tags[i]:connect_signal('tagged', update)
		s.tags[i]:connect_signal('untagged', update)
		update()
	end

	return moons
end

-- -----------------------------------------------------------------------------
-- TAGLIST
-- -----------------------------------------------------------------------------

return {
	attach = function(s)
		s.taglist = wibox {
			screen = s,
			x = s.geometry.x
				+ s.geometry.width / 2
				- svg.width / 2,
			y = s.geometry.y
				+ s.geometry.height
				- svg.height
				- config.compass_size / 2
				- config.border_width,
			width = svg.width,
			height = svg.height
				+ config.compass_size / 2
				+ 2 * config.border_width,
			visible = true,
			ontop = true,
			type = 'dock',
			bg = '00000000',
		}
		
		-- Do not group this into one call. We need to assign s.taglist and
		-- :setup returns void
		s.taglist:setup {
			{
				top = config.compass_size / 2,
				widget = wibox.container.margin,
			},
			{
				{
					{
						image = beautiful.icon('space/solarsystem'),
						widget = wibox.widget.imagebox,
					},
					shape = gears.shape.rectangle,
					shape_border_width = config.border_width,
					shape_border_color = beautiful.colors.white,
					widget = wibox.container.background,
				},
				create_spaceship(s),
				create_moons(s),
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
			layout = wibox.layout.fixed.vertical,
		}
	end,

	toggle = function()
		local taglist = awful.screen.focused().taglist
		taglist.visible = not taglist.visible
	end,
}
