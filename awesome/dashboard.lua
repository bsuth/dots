local awful = require 'awful'
local beautiful = require 'beautiful'
local components = require 'components'
local gears = require 'gears'
local layout = require 'layout'
local models = require 'models'
local wibox = require 'wibox'

-- -----------------------------------------------------------------------------
-- CONFIG
-- -----------------------------------------------------------------------------

local config = {
	width = 1400,
	height = 800,
	margin = 100,
	padding = 10,
	border_width = 2,
}

local state = {
	taglist_was_active = false,
	tag = awful.screen.focused().selected_tag,
}

-- -----------------------------------------------------------------------------
-- METERS
-- -----------------------------------------------------------------------------

local meters = components.panel {
	components.meter {
		icon = beautiful.svg('dashboard/meters/disk'),
		color = 'purple',
		model = models.disk,
	},
	layout.hpad(8),
	components.meter {
		icon = beautiful.svg('dashboard/meters/ram'),
		color = 'blue',
		model = models.ram,
	},
	layout.hpad(8),
	components.meter {
		icon = models.battery.discharging
		and beautiful.svg('dashboard/meters/battery-discharging')
		or beautiful.svg('dashboard/meters/battery-charging'),
		color = 'red',
		model = models.battery,
		onupdate = function()
			return {
				icon = models.battery.discharging
				and beautiful.svg('dashboard/meters/battery-discharging')
				or beautiful.svg('dashboard/meters/battery-charging'),
			}
		end,
	},
	layout = wibox.layout.fixed.horizontal,
}

-- -----------------------------------------------------------------------------
-- SLIDERS
-- -----------------------------------------------------------------------------

local sliders_defaults = {
	width = 35,
	height = 120,
}

local sliders = wibox.widget {
	layout.center(components.slider(gears.table.join({
		color = beautiful.colors.green,
		model = models.volume,
	}, sliders_defaults))),
	layout.center(components.slider(gears.table.join({
		color = beautiful.colors.yellow,
		model = models.brightness,
	}, sliders_defaults))),
	layout = wibox.layout.flex.horizontal,
}

-- -----------------------------------------------------------------------------
-- KB LAYOUT
-- -----------------------------------------------------------------------------

function create_kb_config(index, icon)
	return {
		icon_width = 64,
		icon_height = 32,
		icon = beautiful.svg(icon),

		is_pressed = function()
			return models.kb_layout.index == index
		end,

		onpress = function()
			models.kb_layout:set(index)
		end,

		hook = function(button)
			models.kb_layout:connect_signal('update', function()
				button:emit_signal('widget::redraw_needed')
			end)
		end,
	}
end

local kb_layout = components.panel {
	components.button(create_kb_config(1, 'dashboard/locale/usa')),
	layout.hpad(16),
	components.button(create_kb_config(2, 'dashboard/locale/japan')),
	layout.hpad(16),
	components.button(create_kb_config(3, 'dashboard/locale/germany')),
	layout = wibox.layout.fixed.horizontal,
}

-- -----------------------------------------------------------------------------
-- TILING LAYOUT
-- -----------------------------------------------------------------------------

function create_tiling_config(index, icon)
	return {
		icon_width = 40,
		icon_height = 40,
		icon = beautiful.svg(icon),

		is_pressed = function()
			return state.tag.layout == awful.layout.layouts[index]
		end,

		onpress = function()
			awful.layout.set(awful.layout.layouts[index])
		end,

		hook = function(button)
			awful.tag.attached_connect_signal(nil, 'property::layout', function()
				button:emit_signal('widget::redraw_needed')
			end)
		end,
	}
end

local tiling_layout = components.panel {
	components.button(create_tiling_config(1, 'dashboard/tiling/dwindle')),
	layout.hpad(32),
	components.button(create_tiling_config(2, 'dashboard/tiling/fair')),
	layout.hpad(32),
	components.button(create_tiling_config(3, 'dashboard/tiling/magnifier')),
	layout = wibox.layout.fixed.horizontal,
}

-- -----------------------------------------------------------------------------
-- DANGER ZONE
-- -----------------------------------------------------------------------------

local danger_zone = wibox.widget {
	components.panel(components.big_button {
		icon = beautiful.svg('dashboard/lock'),
		color = beautiful.colors.green,
		onpress = function()
			require('naughty').notify { text = 'sleep' }
		end,
	}, 16, 16),
	layout.hpad(8),
	components.panel(components.big_button {
		icon = beautiful.svg('dashboard/restart'),
		color = beautiful.colors.yellow,
		onpress = function()
			require('naughty').notify { text = 'reboot' }
		end,
	}, 16, 16),
	layout.hpad(8),
	components.panel(components.big_button {
		icon = beautiful.svg('dashboard/power'),
		color = beautiful.colors.red,
		onpress = function()
			require('naughty').notify { text = 'shutdown' }
		end,
	}, 16, 16),
	layout = wibox.layout.fixed.horizontal,
}

-- -----------------------------------------------------------------------------
-- DASHBOARD
-- -----------------------------------------------------------------------------

local dashboard = wibox {
	visible = false,
	ontop = true,
	type = 'dock',
	bg = beautiful.colors.transparent,
}

local column1 = wibox.widget {
	text = 'Placeholder',
	widget = wibox.widget.textbox,
}

local column3 = wibox.widget {
	text = 'Placeholder',
	widget = wibox.widget.textbox,
}

dashboard:setup {
	layout.center {
		{
			layout.center {
				column1,
				layout = wibox.layout.fixed.vertical,
			},
			layout.center {
				components.mount {
					widget = wibox.widget.textclock,
				},
				layout.vpad(32),
				components.mount {
					meters,
					layout.vpad(32),
					sliders,
					layout = wibox.layout.fixed.vertical,
				},
				layout = wibox.layout.fixed.vertical,
			},
			{
				layout.center(components.mount {
					kb_layout,
					layout.vpad(16),
					tiling_layout,
					layout = wibox.layout.fixed.vertical,
				}),
				layout.vpad(32),
				layout.center(components.mount(danger_zone)),
				layout = wibox.layout.fixed.vertical,
			},
			layout = wibox.layout.flex.horizontal,
		},

		forced_width = config.width,
		forced_height = config.height,

		widget = wibox.container.background,
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
			state.tag = s.selected_tag

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
