local beautiful = require('beautiful')
local gears = require('gears')
local layout = require('layout')
local wibox = require('wibox')
local widgets = require('widgets')

--
-- Helpers
--

function set_source_hex(cr, hex)
  local rgb = beautiful.hex2rgb(hex)
  cr:set_source_rgb(rgb[1], rgb[2], rgb[3])
end

--
-- Button
--

function button(config)
  local force_press = false

  local _button = wibox.widget({
    {
      forced_width = config.size or 32,
      forced_height = (config.size or 32) + 8,
      layout = wibox.layout.manual,
    },

    shape = function(cr, width, height)
      local pressed = force_press or config.is_pressed and config.is_pressed()

      local R = width / 2
      local r = R - 4
      local bottom = height - R
      local top = pressed and bottom - 4 or bottom - 8

      set_source_hex(cr, beautiful.colors.black)
      cr:arc(R, bottom, R, 0, 2 * math.pi)
      cr:fill()

      set_source_hex(cr, beautiful.colors.void)
      cr:arc(R, bottom, r, 0, 2 * math.pi)
      cr:rectangle(4, top, width - 8, bottom - top)
      cr:fill()

      set_source_hex(cr, config.color or beautiful.colors.dark_grey)
      cr:arc(R, top, r, 0, 2 * math.pi)
      cr:fill()
    end,

    widget = wibox.container.background,
  })

  local safety_check_timer = gears.timer({
    timeout = 0.25,
    single_shot = true,
    callback = function()
      config.safety_check = true
    end,
  })

  _button:connect_signal('mouse::enter', function()
    mouse.current_wibox.cursor = 'hand1'
  end)

  _button:connect_signal('mouse::leave', function()
    mouse.current_wibox.cursor = 'arrow'
  end)

  _button:connect_signal('button::press', function(_, _, _, button)
    if button == 1 then
      if config.safety_check then
        config.safety_check = false
        safety_check_timer:again()
      elseif config.onpress then
        config.onpress()
      end

      force_press = true
      _button:emit_signal('widget::redraw_needed')
    end
  end)

  _button:connect_signal('button::release', function(_, _, _, button)
    if button == 1 then
      force_press = false
      _button:emit_signal('widget::redraw_needed')
    end
  end)

  if config.hook ~= nil then
    (config.hook)(_button)
  end
  return _button
end

--
-- Launcher
--

function launcher(config)
  local _button = wibox.widget({
    layout.center({
      forced_width = 48,
      forced_height = 48,

      image = config.icon,
      widget = wibox.widget.imagebox,
    }),

    forced_width = 64,
    forced_height = 64,
    point = { x = 0, y = 0 },

    bg = beautiful.colors.black,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })

  local _launcher = wibox.widget({
    {
      {
        margins = 32,
        widget = wibox.container.margin,
      },

      point = { x = 0, y = 4 },

      bg = beautiful.colors.void,
      shape = gears.shape.rounded_rect,
      widget = wibox.container.background,
    },
    _button,
    forced_width = 64,
    forced_height = 64 + 4,
    layout = wibox.layout.manual,
  })

  _launcher:connect_signal('mouse::enter', function()
    mouse.current_wibox.cursor = 'hand1'
  end)

  _launcher:connect_signal('mouse::leave', function()
    mouse.current_wibox.cursor = 'arrow'
    _launcher:move_widget(_button, { x = 0, y = 0 })
  end)

  _launcher:connect_signal('button::press', function(_, _, _, button)
    if button == 1 then
      _launcher:move_widget(_button, { x = 0, y = 4 })
    end
  end)

  _launcher:connect_signal('button::release', function(_, _, _, button)
    if button == 1 then
      _launcher:move_widget(_button, { x = 0, y = 0 })
      config.onpress()
    end
  end)

  return _launcher
end

--
-- Meter
--

function meter(config)
  local needle = wibox.widget({
    rotatee = wibox.widget({
      image = beautiful.svg('components/meter/needle'),
      widget = wibox.widget.imagebox,
    }),

    theta = (1 - config.model.percent / 100) * -math.pi,
    widget = widgets.rotator,
  })

  local icon = wibox.widget({
    image = config.icon,
    widget = wibox.widget.imagebox,
  })

  config.model:connect_signal('update', function()
    needle.theta = (1 - config.model.percent / 100)
      * -math.pi, needle:emit_signal('widget::layout_changed')

    if config.onupdate then
      local updated_config = (config.onupdate)(icon)
      if not updated_config then
        return
      end

      if updated_config.icon then
        icon.image = updated_config.icon
        icon:emit_signal('widget::redraw_needed')
      end
    end
  end)

  return wibox.widget({
    {
      image = beautiful.svg('components/meter/body'),
      widget = wibox.widget.imagebox,
    },
    needle,
    icon,
    {
      image = beautiful.svg('components/meter/decoration-' .. config.color),
      widget = wibox.widget.imagebox,
    },

    forced_width = 64,
    forced_height = 64,

    layout = wibox.layout.stack,
  })
end

--
-- Panel
--

function panel(widget, config)
  config = config or {}
  local border_width = 8
  local nail_offset = border_width + 8
  local nail_size = 4

  return wibox.widget({
    {
      layout.center(widget),
      top = border_width + (config.ypad or 16),
      bottom = border_width + (config.ypad or 16),
      left = border_width + (config.xpad or 32),
      right = border_width + (config.xpad or 32),
      widget = wibox.container.margin,
    },

    shape = function(cr, width, height)
      set_source_hex(cr, config.bg or beautiful.colors.blacker)
      cr:rectangle(0, 0, width, height)
      cr:fill()

      set_source_hex(cr, config.border_color or beautiful.colors.void)
      cr:set_line_width(border_width)
      cr:rectangle(0, 0, width, height)
      cr:stroke()

      set_source_hex(cr, config.nail_color or beautiful.colors.white)

      cr:arc(nail_offset, nail_offset, nail_size, 0, 2 * math.pi)
      cr:fill()

      cr:arc(nail_offset, height - nail_offset, nail_size, 0, 2 * math.pi)
      cr:fill()

      cr:arc(width - nail_offset, nail_offset, nail_size, 0, 2 * math.pi)
      cr:fill()

      cr:arc(
        width - nail_offset,
        height - nail_offset,
        nail_size,
        0,
        2 * math.pi
      )
      cr:fill()
    end,

    widget = wibox.container.background,
  })
end

--
-- Slider
--

function slider(config)
  local _slider = wibox.widget({
    bar_shape = gears.shape.rounded_rect,
    bar_height = config.width / 3,
    bar_color = beautiful.colors.void,

    handle_width = config.height / 7,
    handle_color = config.color,
    handle_border_width = 2,
    handle_border_color = beautiful.colors.void,

    value = config.model.percent,
    widget = wibox.widget.slider,
  })

  _slider:connect_signal('property::value', function(val)
    config.model:set(_slider.value)
  end)

  config.model:connect_signal('update', function()
    _slider.value = config.model.percent
  end)

  return wibox.widget({
    _slider,

    forced_width = config.width,
    forced_height = config.height,

    direction = 'east',
    widget = wibox.container.rotate,
  })
end

--
-- Switch
--

function switch(config)
  local _switch = wibox.widget({
    {
      image = beautiful.svg('components/switch'),
      widget = wibox.widget.imagebox,
    },

    forced_width = 64,
    forced_height = 64,

    direction = config.model.active and 'south' or 'north',
    widget = wibox.container.rotate,
  })

  _switch:connect_signal('mouse::enter', function()
    mouse.current_wibox.cursor = 'hand1'
  end)

  _switch:connect_signal('mouse::leave', function()
    mouse.current_wibox.cursor = 'arrow'
  end)

  _switch:connect_signal('button::press', function(_, _, _, button)
    if button == 1 then
      config.model:toggle()
    end
  end)

  config.model:connect_signal('update', function()
    _switch.direction = config.model.active and 'south' or 'north'
    _switch:emit_signal('widget::redraw_needed')
  end)

  return _switch
end

--
-- Export
--

return {
  button = button,
  launcher = launcher,
  meter = meter,
  mount = mount,
  panel = panel,
  slider = slider,
  switch = switch,
}
