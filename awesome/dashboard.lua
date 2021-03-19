local awful = require 'awful'
local beautiful = require 'beautiful'
local components = require 'components'
local gears = require 'gears'
local layout = require 'layout'
local lui = require 'lui'
local models = require 'models'
local wibox = require 'wibox'

-- -----------------------------------------------------------------------------
-- DASHBOARD
-- -----------------------------------------------------------------------------

local dashboard = gears.table.crush(wibox {
	visible = false,
	ontop = true,
	type = 'dock',
	bg = beautiful.colors.transparent,
}, {
	tag = awful.screen.focused().selected_tag,

	toggle = function(self)
		local s = awful.screen.focused()
		self.tag = s.selected_tag

		if not self.visible then
			gears.table.crush(self, {
				screen = s,
				visible = true,
				x = s.geometry.x,
				y = s.geometry.y,
				width = s.geometry.width,
				height = s.geometry.height,
			})
		else
			self.visible = false
		end
	end,
})

-- -----------------------------------------------------------------------------
-- BLUETOOTH
-- -----------------------------------------------------------------------------

local bluetooth = components.panel {
	text = 'Bluetooth Here',
	widget = wibox.widget.textbox,
}

-- -----------------------------------------------------------------------------
-- CLOCK
-- -----------------------------------------------------------------------------

local clock = lui.render {
  {
    format = ('<span color="%s" size="xx-large">%s</span>')
      :format(beautiful.colors.cyan, '%H:%M'),
    widget = wibox.widget.textclock,
  },
  {
    format = ('<span color="%s" size="small">%s</span>')
      :format(beautiful.colors.white, '%d-%m-%Y'),
    widget = wibox.widget.textclock,
  },

  flow = 'vertical',
  layout = 'fixed',
  padding = { 20, 100 },
	bg = beautiful.colors.void,
  border = { 2, beautiful.colors.dark_grey },
}

-- -----------------------------------------------------------------------------
-- DANGER ZONE
-- -----------------------------------------------------------------------------

function create_danger_zone_icon(icon)
	return wibox.widget {
		forced_width = 32,
		forced_height = 32,
		image = beautiful.svg(icon),
		widget = wibox.widget.imagebox,
	}
end

local danger_zone = wibox.widget {
	components.panel({
		create_danger_zone_icon('dashboard/danger/lock'),
		layout.hpad(72),
		create_danger_zone_icon('dashboard/danger/restart'),
		layout.hpad(72),
		create_danger_zone_icon('dashboard/danger/power'),
		layout = wibox.layout.fixed.horizontal,
	}, { xpad = 0, ypad = 8 }),
	layout.vpad(8),
	{
		components.panel(components.button {
			color = beautiful.colors.green,
			size = 48,
			safety_check = true,
			onpress = function()
				awful.spawn('physlock -m -p "Clearance Required"')
			end,
		}, { xpad = 16, ypad = 16 }),
		layout.hpad(8),
		components.panel(components.button {
			color = beautiful.colors.yellow,
			size = 48,
			safety_check = true,
			onpress = function()
				awful.spawn('/sbin/reboot')
			end,
		}, { xpad = 16, ypad = 16 }),
		layout.hpad(8),
		components.panel(components.button {
			color = beautiful.colors.red,
			size = 48,
			safety_check = true,
			onpress = function()
				awful.spawn('/sbin/poweroff')
			end,
		}, { xpad = 16, ypad = 16 }),
		layout = wibox.layout.fixed.horizontal,
	},
	layout = wibox.layout.fixed.vertical,
}

-- -----------------------------------------------------------------------------
-- KB LAYOUT
-- -----------------------------------------------------------------------------

function create_kb_layout_item(index, icon)
	return wibox.widget {
		layout.center {
			forced_width = 48,
			forced_height = 32,
			image = beautiful.svg(icon),
			widget = wibox.widget.imagebox,
		},
		layout.vpad(16),
		layout.center(components.button {
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
		}),
		layout = wibox.layout.fixed.vertical,
	}
end

local kb_layout = components.panel {
	create_kb_layout_item(1, 'dashboard/kb_layout/usa'),
	layout.hpad(24),
	create_kb_layout_item(2, 'dashboard/kb_layout/japan'),
	layout.hpad(24),
	create_kb_layout_item(3, 'dashboard/kb_layout/germany'),
	layout = wibox.layout.fixed.horizontal,
}

-- -----------------------------------------------------------------------------
-- LAUNCHERS
-- -----------------------------------------------------------------------------

local launchers = components.panel {
	components.launcher {
		icon = beautiful.svg('dashboard/launchers/flameshot'),
		onpress = function()
			dashboard.visible = false
			awful.spawn('flameshot gui')
		end,
	},
	layout.hpad(16),
	components.launcher {
		icon = beautiful.svg('dashboard/launchers/simplescreenrecorder'),
		onpress = function()
			dashboard.visible = false
			awful.spawn('simplescreenrecorder')
		end,
	},
	layout.hpad(16),
	components.launcher {
		icon = beautiful.svg('dashboard/launchers/gpick'),
		onpress = function()
			dashboard.visible = false
			awful.spawn.easy_async_with_shell('gpick -s -o | tr -d "\n" | xclip -sel c')
		end,
	},
	layout = wibox.layout.fixed.horizontal,
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
-- SWITCHES
-- -----------------------------------------------------------------------------

function create_switch_item(config)
	local icon = wibox.widget {
		forced_width = 40,
		forced_height = 40,
		image = config.model.active
			and config.active_icon
			or config.inactive_icon,
		widget = wibox.widget.imagebox,
	}

	config.model:connect_signal('update', function()
		icon.image = config.model.active
			and config.active_icon
			or config.inactive_icon
		icon:emit_signal('widget::redraw_needed')
	end)

	return wibox.widget {
		layout.center(icon),
		layout.vpad(16),
		layout.center(components.switch { model = config.model }),
		layout = wibox.layout.fixed.vertical,
	}
end

local switches = components.panel {
	create_switch_item {
		active_icon = beautiful.svg('dashboard/switches/volume-on'),
		inactive_icon = beautiful.svg('dashboard/switches/volume-off'),
		model = models.volume,
	},
	layout.hpad(8),
	create_switch_item {
		active_icon = beautiful.svg('dashboard/switches/bluetooth-on'),
		inactive_icon = beautiful.svg('dashboard/switches/bluetooth-off'),
		model = models.bluetooth,
	},
	layout.hpad(8),
	create_switch_item {
		active_icon = beautiful.svg('dashboard/switches/notifs-on'),
		inactive_icon = beautiful.svg('dashboard/switches/notifs-off'),
		model = models.notifs,
	},
	layout = wibox.layout.fixed.horizontal,
}

-- -----------------------------------------------------------------------------
-- TILING LAYOUT
-- -----------------------------------------------------------------------------

function create_tiling_layout_item(index, icon)
	return wibox.widget {
		layout.center {
			forced_width = 40,
			forced_height = 40,
			image = beautiful.svg(icon),
			widget = wibox.widget.imagebox,
		},
		layout.vpad(16),
		layout.center(components.button {
			is_pressed = function()
				return dashboard.tag.layout == awful.layout.layouts[index]
			end,

			onpress = function()
				awful.layout.set(awful.layout.layouts[index])
			end,

			hook = function(button)
				awful.tag.attached_connect_signal(nil, 'property::layout', function()
					button:emit_signal('widget::redraw_needed')
				end)
			end,
		}),
		layout = wibox.layout.fixed.vertical,
	}
end

local tiling_layout = components.panel {
	create_tiling_layout_item(1, 'dashboard/tiling/dwindle'),
	layout.hpad(32),
	create_tiling_layout_item(2, 'dashboard/tiling/fair'),
	layout.hpad(32),
	create_tiling_layout_item(3, 'dashboard/tiling/magnifier'),
	layout = wibox.layout.fixed.horizontal,
}

-- -----------------------------------------------------------------------------
-- WIFI
-- -----------------------------------------------------------------------------

local wifi = components.panel {
	text = 'Wifi Here',
	widget = wibox.widget.textbox,
}

-- -----------------------------------------------------------------------------
-- RETURN
-- -----------------------------------------------------------------------------

function outer_panel(widget)
	return components.panel(widget, {
		xpad = 16,
		ypad = 16,
		bg = beautiful.colors.black,
		border_color = beautiful.colors.void,
		nail_color = beautiful.colors.blacker,
	})
end

dashboard:setup {
	{
		layout.center {
			wifi,
			layout.vpad(32),
			bluetooth,
			layout = wibox.layout.fixed.vertical,
		},
		layout.center {
			outer_panel(clock),
			layout.vpad(32),
			outer_panel {
				launchers,
				layout.vpad(32),
				sliders,
				layout.vpad(32),
				meters,
				layout = wibox.layout.fixed.vertical,
			},
			layout = wibox.layout.fixed.vertical,
		},
		layout.center {
			outer_panel {
				switches,
				layout.vpad(16),
				kb_layout,
				layout.vpad(16),
				tiling_layout,
				layout = wibox.layout.fixed.vertical,
			},
			layout.vpad(32),
			outer_panel(danger_zone),
			layout = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.flex.horizontal,
	},
	bg = beautiful.colors.dimmed,
	widget = wibox.container.background,
}

return dashboard
