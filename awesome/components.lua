local beautiful = require 'beautiful'
local gears = require 'gears'
local layout = require 'layout'
local wibox = require 'wibox'
local widgets = require 'widgets'

-- -----------------------------------------------------------------------------
-- BUTTON
-- -----------------------------------------------------------------------------

function button(config)
	local _button = wibox.widget {
		{
			margins = config.size / 4,
			widget = wibox.container.margin,
		},

		forced_width = config.size,
		forced_height = config.size,

		bg = beautiful.colors.white,
		shape = function(cr, width, height)
			local a = width / 2
			local b = height /4

			local bottom = height - b
			local top = bottom - b * (config.is_pressed() and 1 or 2)

			local color = beautiful.hex2rgb(beautiful.colors.void)
			cr:set_source_rgb(color[1], color[2], color[3])

			function ellipse(y, rgb)
				cr:save()
				cr:set_source_rgb(rgb[1], rgb[2], rgb[3])
				cr:scale(1, b / a)
				cr:arc(a, y * (a / b), a, 0, 2 * math.pi)
				cr:fill()
				cr:restore()
			end

			ellipse(bottom, color)
			cr:rectangle(0, top, width, math.max(0, height - top - b))
			cr:fill()
			ellipse(top, beautiful.hex2rgb(beautiful.colors.white))
		end,
		widget = wibox.container.background,
	}

	config.model:connect_signal('update', function()
		_button:emit_signal('widget::redraw_needed')
	end)

	return {
		layout.center {
			forced_width = config.icon_size,
			forced_height = config.icon_size,

			image = config.icon,
			widget = wibox.widget.imagebox,
		},
		layout.center(_button),
		layout = wibox.layout.fixed.vertical,
	}
end

-- -----------------------------------------------------------------------------
-- SLIDER
-- -----------------------------------------------------------------------------

function slider(config)
	local _slider = wibox.widget {
		bar_shape = gears.shape.rounded_rect,
		bar_height = config.width / 3,
		bar_color = beautiful.colors.void,

		handle_width = config.height / 7,
		handle_color = config.color,
		handle_border_width = 2,
		handle_border_color = beautiful.colors.void,

		value = config.model.percent,
		widget = wibox.widget.slider,
	}

	_slider:connect_signal('property::value', function(val)
		config.model:set(_slider.value)
	end)

	config.model:connect_signal('update', function()
		_slider.value = config.model.percent
	end)

	return wibox.widget {
		_slider,

		forced_width = config.width,
		forced_height = config.height,

		direction = 'east',
		widget = wibox.container.rotate,
	}
end

-- -----------------------------------------------------------------------------
-- METER
-- -----------------------------------------------------------------------------

function meter(config)
	local needle = wibox.widget {
		rotatee = wibox.widget {
			image = beautiful.svg('components/meter/needle'),
			widget = wibox.widget.imagebox,
		},

		theta = (1 - config.model.percent / 100) * -math.pi,
		widget = widgets.rotator,
	}

	local icon = wibox.widget {
		image = config.icon,
		widget = wibox.widget.imagebox,
	}

	config.model:connect_signal('update', function()
		needle.theta = (1 - config.model.percent / 100) * -math.pi,
		needle:emit_signal('widget::layout_changed')

		if config.onupdate then
			local updated_config = (config.onupdate)(icon)
			if not updated_config then return end

			if updated_config.icon then
				icon.image = updated_config.icon
				icon:emit_signal('widget::redraw_needed')
			end
		end
	end)

	return wibox.widget {
		{
			image = beautiful.svg('components/meter/body'),
			widget = wibox.widget.imagebox,
		},
		needle,
		icon,
		{
			image = beautiful.svg('components/meter/decoration-'..config.color),
			widget = wibox.widget.imagebox,
		},

		forced_width = config.size,
		forced_height = config.size,

		layout = wibox.layout.stack,
	}
end

-- -----------------------------------------------------------------------------
-- EXPORT
-- -----------------------------------------------------------------------------

return {
	button = button,
	meter = meter,
	slider = slider,
}
