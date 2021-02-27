local beautiful = require 'beautiful'
local gears = require 'gears'
local layout = require 'layout'
local wibox = require 'wibox'
local widgets = require 'widgets'

-- -----------------------------------------------------------------------------
-- HELPERS
-- -----------------------------------------------------------------------------

function set_source_hex(cr, hex)
	local rgb = beautiful.hex2rgb(hex)
	cr:set_source_rgb(rgb[1], rgb[2], rgb[3])
end

-- -----------------------------------------------------------------------------
-- BIG BUTTON
-- -----------------------------------------------------------------------------

function big_button(config)
	local safety_check = false
	local safety_check_timer = gears.timer {
		timeout = 0.25,
		single_shot = true,
		callback = function()
			safety_check = false
		end,
	}

	local _button = wibox.widget {
		{
			layout.center {
				forced_width = 32,
				forced_height= 32,
				image = config.icon,
				widget = wibox.widget.imagebox,
			},
			top = 16,
			bottom = 16 + 6,
			left = 16,
			right = 16,
			widget = wibox.container.margin,
		},

		shape = function(cr, width, height)
			local R = width / 2
			local r = R - 4

			set_source_hex(cr, beautiful.colors.black)
			cr:arc(R, height - R, R, 0, 2 * math.pi)
			cr:fill()

			set_source_hex(cr, beautiful.colors.void)
			cr:arc(R, height - R, r, 0, 2 * math.pi)
			cr:rectangle(4, height - R - 6, 2 * r, 6)
			cr:fill()

			set_source_hex(cr, config.color)
			cr:arc(R, height - R - 6, r, 0, 2 * math.pi)
			cr:fill()
		end,

		widget = wibox.container.background,
	}

	if config.onpress ~= nil then
		_button:connect_signal('button::press', function(_, _, _, button)
			if button == 1 then
				if not safety_check then
					safety_check = true
					safety_check_timer:again()
				else
					(config.onpress)()
				end
			end
		end)

		_button:connect_signal('mouse::enter', function()
			mouse.current_wibox.cursor = 'hand1'
		end)

		_button:connect_signal('mouse::leave', function()
			mouse.current_wibox.cursor = 'arrow'
		end)
	end

	return _button
end

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

			set_source_hex(cr, beautiful.colors.black)
			cr:arc(R, bottom, R, 0, 2 * math.pi)
			cr:fill()

			set_source_hex(cr, beautiful.colors.void)
			cr:arc(R, bottom, r, 0, 2 * math.pi)
			cr:rectangle(4, top, width - 8, bottom - top)
			cr:fill()

			set_source_hex(cr, beautiful.colors.dark_grey)
			cr:arc(R, top, r, 0, 2 * math.pi)
			cr:fill()
		end,

		widget = wibox.container.background,
	}

	if config.hook ~= nil then
		(config.hook)(_button)
	end

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
-- MOUNT
-- -----------------------------------------------------------------------------

function mount(widget)
	local tab_thickness = 8

	return wibox.widget {
		{
			layout.center(widget),
			margins = tab_thickness + 8,
			widget = wibox.container.margin,
		},

		shape = function(cr, width, height)
			set_source_hex(cr, '#282828')

			cr:rectangle(tab_thickness, tab_thickness, width - 2 * tab_thickness, height - 2 * tab_thickness)
			cr:fill()

			cr:rectangle(width / 3, 0, width / 3, tab_thickness)
			cr:fill()

			cr:rectangle(width / 3, height - tab_thickness, width / 3, tab_thickness)
			cr:fill()

			cr:rectangle(0, height / 3, tab_thickness, height / 3)
			cr:fill()

			cr:rectangle(width - tab_thickness, height / 3, tab_thickness, height / 3)
			cr:fill()
		end,

		widget = wibox.container.background,
	}
end

-- -----------------------------------------------------------------------------
-- PANEL
-- -----------------------------------------------------------------------------

function panel(widget, padding_x, padding_y)
	local border_width = 8
	local nail_offset = border_width + 8
	local nail_size = 4

	return wibox.widget {
		{
			layout.center(widget),
			top = border_width + (padding_y or 16),
			bottom = border_width + (padding_y or 16),
			left = border_width + (padding_x or 32),
			right = border_width + (padding_x or 32),
			widget = wibox.container.margin,
		},

		shape = function(cr, width, height)
			set_source_hex(cr, beautiful.colors.blacker)
			cr:rectangle(0, 0, width, height)
			cr:fill()

			set_source_hex(cr, beautiful.colors.black)
			cr:set_line_width(border_width)
			cr:rectangle(0, 0, width, height)
			cr:stroke()

			set_source_hex(cr, beautiful.colors.white)

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
	big_button = big_button,
	button = button,
	meter = meter,
	mount = mount,
	panel = panel,
	slider = slider,
}
