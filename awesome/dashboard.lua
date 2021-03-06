local awful = require 'awful'
local beautiful = require 'beautiful'
local components = require 'components'
local gears = require 'gears'
local layout = require 'layout'
local models = require 'models'
local wibox = require 'wibox'

-- -----------------------------------------------------------------------------
-- STATE / DASHBOARD
-- -----------------------------------------------------------------------------

local state = {
	tag = awful.screen.focused().selected_tag,
}

local dashboard = wibox {
	visible = false,
	ontop = true,
	type = 'dock',
	bg = beautiful.colors.transparent,
}

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

local clock = wibox.widget {
	{
		{
			layout.center {
				format = ('<span color="%s" size="xx-large">%s</span>')
					:format(beautiful.colors.cyan, '%H:%M'),
				widget = wibox.widget.textclock,
			},
			layout.center {
				format = ('<span color="%s" size="small">%s</span>')
					:format(beautiful.colors.white, '%d-%m-%Y'),
				widget = wibox.widget.textclock,
			},
			layout = wibox.layout.fixed.vertical,
		},
		top = 20,
		bottom = 20,
		left = 100,
		right = 100,
		widget = wibox.container.margin,
	},

	bg = beautiful.colors.void,
	shape = gears.shape.rectangle,
	shape_border_width = 2,
	shape_border_color = beautiful.colors.dark_grey,
	widget = wibox.container.background,
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
	}, 0, 8),
	layout.vpad(8),
	{
		components.panel(components.button {
			color = beautiful.colors.green,
			size = 48,
			safety_check = true,
			onpress = function()
				require('naughty').notify { text = 'sleep' }
			end,
		}, 16, 16),
		layout.hpad(8),
		components.panel(components.button {
			color = beautiful.colors.yellow,
			size = 48,
			safety_check = true,
			onpress = function()
				require('naughty').notify { text = 'reboot' }
			end,
		}, 16, 16),
		layout.hpad(8),
		components.panel(components.button {
			color = beautiful.colors.red,
			size = 48,
			safety_check = true,
			onpress = function()
				require('naughty').notify { text = 'shutdown' }
			end,
		}, 16, 16),
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
	layout.hpad(16),
	create_kb_layout_item(2, 'dashboard/kb_layout/japan'),
	layout.hpad(16),
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
-- DASHBOARD
-- -----------------------------------------------------------------------------

dashboard:setup {
	{
		layout.center {
			wifi,
			layout.vpad(32),
			bluetooth,
			layout = wibox.layout.fixed.vertical,
		},
		layout.center {
			layout.center(components.mount(clock)),
			layout.vpad(32),
			layout.center(components.mount {
				launchers,
				layout.vpad(32),
				sliders,
				layout.vpad(32),
				switches,
				layout = wibox.layout.fixed.vertical,
			}),
			layout = wibox.layout.fixed.vertical,
		},
		layout.center {
			layout.center(components.mount(meters)),
			layout.vpad(32),
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
	bg = beautiful.colors.dimmed,
	widget = wibox.container.background,
}

return {
	toggle = function()
		local s = awful.screen.focused()
		state.tag = s.selected_tag

		if not dashboard.visible then
			gears.table.crush(dashboard, {
				screen = s,
				visible = true,
				x = s.geometry.x,
				y = s.geometry.y,
				width = s.geometry.width,
				height = s.geometry.height,
			})
		else
			dashboard.visible = false
		end
	end,
}
