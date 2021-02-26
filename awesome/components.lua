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
			forced_width = 32,
			forced_height = 32 + 8,
			widget = wibox.container.margin,
		},

		shape = function(cr, width, height)
			local R = width / 2
			local r = R - 4
			local bottom = height - R
			local top = config.is_pressed()
				and bottom - 4
				or bottom - 8
			local color = beautiful.hex2rgb(beautiful.colors.black)

			cr:set_source_rgb(color[1], color[2], color[3])
			cr:arc(R, bottom, R, 0, 2 * math.pi)
			cr:fill()

			color = beautiful.hex2rgb(beautiful.colors.void)
			cr:set_source_rgb(color[1], color[2], color[3])
			cr:arc(R, bottom, r, 0, 2 * math.pi)
			cr:rectangle(4, top, width - 8, bottom - top)
			cr:fill()

			color = beautiful.hex2rgb(beautiful.colors.dark_grey)
			cr:set_source_rgb(color[1], color[2], color[3])
			cr:arc(R, top, r, 0, 2 * math.pi)
			cr:fill()
		end,

		widget = wibox.container.background,
	}

	config.model:connect_signal('update', function()
		_button:emit_signal('widget::redraw_needed')
	end)

	if config.onpress ~= nil then
		_button:connect_signal('button::press', function(_, _, _, button)
			if button == 1 then
				(config.onpress)()
			end
		end)

		_button:connect_signal('mouse::enter', function()
			mouse.current_wibox.cursor = 'hand1'
		end)

		_button:connect_signal('mouse::leave', function()
			mouse.current_wibox.cursor = 'arrow'
		end)
	end

	return wibox.widget {
		layout.center {
			forced_width = config.icon_width,
			forced_height = config.icon_height,
			image = config.icon,
			widget = wibox.widget.imagebox,
		},
		layout.vpad(16),
		layout.center(_button),
		layout = wibox.layout.fixed.vertical,
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

		forced_width = 64,
		forced_height = 64,

		layout = wibox.layout.stack,
	}
end

-- -----------------------------------------------------------------------------
-- PANEL
-- -----------------------------------------------------------------------------

function panel(widget)
	local bg = beautiful.hex2rgb(beautiful.colors.blacker)

	local border_color = beautiful.hex2rgb(beautiful.colors.black)
	local border_width = 8

	local nail_color = beautiful.hex2rgb(beautiful.colors.white)
	local nail_offset = border_width + 8
	local nail_size = 4

	return wibox.widget {
		{
			widget,
			top = border_width + 16,
			bottom = border_width + 16,
			left = border_width + 32,
			right = border_width + 32,
			widget = wibox.container.margin,
		},

		shape = function(cr, width, height)
			cr:set_source_rgb(bg[1], bg[2], bg[3])
			cr:rectangle(0, 0, width, height)
			cr:fill()

			cr:set_source_rgb(border_color[1], border_color[2], border_color[3])
			cr:set_line_width(border_width)
			cr:rectangle(0, 0, width, height)
			cr:stroke()

			cr:set_source_rgb(nail_color[1], nail_color[2], nail_color[3])

			cr:arc(nail_offset, nail_offset, nail_size, 0, 2 * math.pi)
			cr:fill()

			cr:arc(nail_offset, height - nail_offset, nail_size, 0, 2 * math.pi)
			cr:fill()

			cr:arc(width - nail_offset, nail_offset, nail_size, 0, 2 * math.pi)
			cr:fill()

			cr:arc(width - nail_offset, height - nail_offset, nail_size, 0, 2 * math.pi)
			cr:fill()
		end,

		widget = wibox.container.background,
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
-- EXPORT
-- -----------------------------------------------------------------------------

return {
	button = button,
	meter = meter,
	panel = panel,
	slider = slider,
}
