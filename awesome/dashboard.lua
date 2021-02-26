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
	width = 1200,
	height = 600,
	margin = 100,
	padding = 10,
	border_width = 2,
}

local state = {
	taglist_was_active = false,
}

-- -----------------------------------------------------------------------------
-- SLIDERS
-- -----------------------------------------------------------------------------

local sliders_defaults = {
	width = 35,
	height = 120,
}

local sliders = wibox.widget {
	layout.center(components.slider(gears.table.crush({
		color = beautiful.colors.green,
		model = models.volume,
	}, sliders_defaults))),
	layout.center(components.slider(gears.table.crush({
		color = beautiful.colors.yellow,
		model = models.brightness,
	}, sliders_defaults))),
	layout = wibox.layout.flex.horizontal,
}

-- -----------------------------------------------------------------------------
-- METERS
-- -----------------------------------------------------------------------------

local meters = layout.center(components.panel {
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
})

-- -----------------------------------------------------------------------------
-- BUTTON PANEL
-- -----------------------------------------------------------------------------

local button_panel_kb_defaults = {
	icon_width = 64,
	icon_height = 32,
	model = models.kb_layout,
}

local button_panel = components.panel {
	{
		components.button(gears.table.crush({
			icon = beautiful.svg('dashboard/locale/usa'),
			is_pressed = function() return models.kb_layout.index == 1 end,
			onpress = function() models.kb_layout:set(1) end,
		}, button_panel_kb_defaults)),
		layout.hpad(16),
		components.button(gears.table.crush({
			icon = beautiful.svg('dashboard/locale/japan'),
			is_pressed = function() return models.kb_layout.index == 2 end,
			onpress = function() models.kb_layout:set(2) end,
		}, button_panel_kb_defaults)),
		layout.hpad(16),
		components.button(gears.table.crush({
			icon = beautiful.svg('dashboard/locale/germany'),
			is_pressed = function() return models.kb_layout.index == 3 end,
			onpress = function() models.kb_layout:set(3) end,
		}, button_panel_kb_defaults)),
		layout = wibox.layout.fixed.horizontal,
	},
	layout = wibox.layout.fixed.vertical,
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
				{
					widget = wibox.widget.textclock,
				},
				layout.vpad(16),
				sliders,
				layout.vpad(16),
				meters,
				layout = wibox.layout.fixed.vertical,
			},
			layout.center(button_panel),
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
