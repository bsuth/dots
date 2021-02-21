local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local layout = require 'layout'
local models = require 'models'
local wibox = require 'wibox'
local widgets = require 'widgets'

-- -----------------------------------------------------------------------------
-- CONFIG
-- -----------------------------------------------------------------------------

local config = {
	width = 1200,
	height = 600,
	margin = 100,
	padding = 10,
	border_width = 2,

	slider_width = 35,
	slider_height = 120,
	meter_size = 64,
}

local state = {
	taglist_was_active = false,
}

-- -----------------------------------------------------------------------------
-- COMPONENTS
-- -----------------------------------------------------------------------------

-- Slider

function slider(model, color)
	local wslider = wibox.widget {
		bar_shape = gears.shape.rounded_rect,
		bar_height = 10,
		bar_color = beautiful.colors.void,

		handle_width = 18,
		handle_color = color,
		handle_border_width = 2,
		handle_border_color = beautiful.colors.void,

		value = model.percent,
		widget = wibox.widget.slider,
	}

	wslider:connect_signal('property::value', function(val)
		model:set(wslider.value)
	end)

	model:connect_signal('update', function()
		wslider.value = model.percent
	end)

	return wibox.widget {
		wslider,
		direction = 'east',
		forced_width = config.slider_width,
		forced_height = config.slider_height,
		widget = wibox.container.rotate,
	}
end

-- Meter

function meter(id, model, update_hook)
	local needle = wibox.widget {
		rotatee = wibox.widget {
			image = beautiful.svg('dashboard/meter/needle'),
			widget = wibox.widget.imagebox,
		},
		widget = widgets.rotator,
	}

	local icon = wibox.widget {
		image = beautiful.svg('dashboard/'..id..'/icon'),
		widget = wibox.widget.imagebox,
	}

	function update()
		needle.theta = (1 - model.percent / 100) * -math.pi,
		needle:emit_signal('widget::layout_changed')
		if update_hook then (update_hook)(icon) end
	end

	update()
	model:connect_signal('update', update)

	return wibox.widget {
		{
			image = beautiful.svg('dashboard/meter/body'),
			widget = wibox.widget.imagebox,
		},
		needle,
		icon,
		{
			image = beautiful.svg('dashboard/'..id..'/button'),
			widget = wibox.widget.imagebox,
		},
		forced_width = config.meter_size,
		forced_height = config.meter_size,
		layout = wibox.layout.stack,
	}
end

-- -----------------------------------------------------------------------------
-- PARTIALS
-- -----------------------------------------------------------------------------

-- Locales

local locales = wibox.widget(gears.table.crush(
	gears.table.map(function(id)
		return wibox.widget {
			layout.center {
				image = beautiful.svg('dashboard/locale/'..id),
				forced_width = 60,
				forced_height = 40,
				widget = wibox.widget.imagebox,
			},
			layout = wibox.layout.fixed.vertical,
		}
	end, { 'usa', 'japan', 'germany' })
, { layout = wibox.layout.flex.horizontal }))

-- Sliders

local sliders = wibox.widget {
	layout.center(slider(models.volume, beautiful.colors.green)),
	layout.center(slider(models.brightness, beautiful.colors.yellow)),
	layout = wibox.layout.flex.horizontal,
}

-- Meters

local meters = layout.center {
	{
		image = beautiful.svg('dashboard/meter/panel'),
		widget = wibox.widget.imagebox,
	},
	layout.center {
		meter('disk', models.disk),
		layout.hpad(8),
		meter('ram', models.ram),
		layout.hpad(8),
		meter('battery', models.battery, function(icon)
			if models.battery.discharging then
				icon.image = beautiful.svg('dashboard/battery/discharging')
			else
				icon.image = beautiful.svg('dashboard/battery/charging')
			end
			icon:emit_signal('widget::redraw_needed')
		end),
		layout = wibox.layout.fixed.horizontal,
	},
	-- panel svg dimensions
	forced_width = 228,
	forced_height = 84,
	layout = wibox.layout.stack,
}

-- -----------------------------------------------------------------------------
-- NOTIF CENTER
-- -----------------------------------------------------------------------------

local notif_center = wibox.widget {
	text = 'Placeholder',
	widget = wibox.widget.textbox,
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
	notif_center,
	layout = wibox.layout.fixed.vertical,
}

local column3 = wibox.widget {
	text = 'Placeholder',
	widget = wibox.widget.textbox,
}

dashboard:setup {
	layout.center {
		{
			layout.center {
				notif_center,
				layout = wibox.layout.fixed.vertical,
			},
			layout.center {
				locales,
				layout.vpad(16),
				sliders,
				layout.vpad(16),
				meters,
				layout = wibox.layout.fixed.vertical,
			},
			layout.center {
				text = 'Placeholder',
				widget = wibox.widget.textbox,
			},
			layout = wibox.layout.flex.horizontal,
		},
		forced_width = config.width,
		forced_height = config.height,

		bg = beautiful.colors.black,
		shape = gears.shape.rectangle,
		shape_border_width = config.border_width,
		shape_border_color = beautiful.colors.white,

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
