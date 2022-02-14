local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local models = require('models')
local wibox = require('wibox')

-- =============================================================================
-- State / Config
-- =============================================================================

local STATUS_ITEM_SIZE = 100
local DIAL_BORDER_WIDTH = 6

local selectedItemIndex = 1

-- =============================================================================
-- Components
-- =============================================================================

local function DialWidget(opts)
  local dialWidget = wibox.widget({
    {
      {
        opts.widget,
        widget = wibox.container.place,
      },
      margins = 16,
      widget = wibox.container.margin,
    },
    bgimage = function(_, cr, width, height)
      local m = math.min(width, height)

      local bg = beautiful.hex2rgb(beautiful.void)
      cr:set_source_rgb(bg[1], bg[2], bg[3])
      gears.shape.arc(cr, m, m, DIAL_BORDER_WIDTH, 0, 2 * math.pi)
      cr:fill()

      if opts.model.percent and opts.model.percent > 0 then
        local fg = beautiful.hex2rgb(opts.color)
        cr:set_source_rgb(fg[1], fg[2], fg[3])

        -- 98 is close enough so round (plus, battery percent never reaches
        -- 100% on some computers)
        if opts.model.percent < 98 then
          -- If (theta_end - theta_start) is too small, then cairo will shift
          -- theta_end slightly in an attempt to draw something over nothing.
          -- This causes a sort of "jump" when the percent gets to low, so to
          -- avoid this, we always draw a small circle centered at theta_end
          -- to mimic the rounded end, and just draw a rounded start for the
          -- actual arc.
          cr:arc(
            m / 2,
            DIAL_BORDER_WIDTH / 2,
            DIAL_BORDER_WIDTH / 2,
            0,
            2 * math.pi
          )

          local theta_end = 3 * math.pi / 2
          local theta_start = theta_end
            - (opts.model.percent / 100) * (2 * math.pi)

          gears.shape.arc(
            cr,
            m,
            m,
            DIAL_BORDER_WIDTH,
            theta_start,
            theta_end,
            true,
            false
          )
        else
          gears.shape.arc(cr, m, m, DIAL_BORDER_WIDTH, 0, 2 * math.pi)
        end
      end

      cr:fill()
    end,
    widget = wibox.container.background,
  })

  opts.model:connect_signal('update', function()
    dialWidget:emit_signal('request::redraw_needed')
  end)

  return dialWidget
end

local function StatusItemWidget(opts)
  local statusItemWidget = wibox.widget({
    {
      {
        opts.widget,
        widget = wibox.container.place,
      },
      margins = 16,
      widget = wibox.container.margin,
    },
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 2)
    end,
    shape_border_width = 4,
    shape_border_color = beautiful.void,
    fg = beautiful.pale,
    bg = '#2A2520',
    forced_width = STATUS_ITEM_SIZE,
    forced_height = STATUS_ITEM_SIZE,
    widget = wibox.container.background,
  })

  statusItemWidget:connect_signal('request::select', function()
    if opts.keypressed_callback ~= nil then
      statusItemWidget.shape_border_color = beautiful.pale
    else
      statusItemWidget.shape_border_color = beautiful.darkGrey
    end
  end)

  statusItemWidget:connect_signal('request::unselect', function()
    statusItemWidget.shape_border_color = beautiful.void
  end)

  statusItemWidget.keypressed_callback = opts.keypressed_callback
  return statusItemWidget
end

-- =============================================================================
-- Widgets
-- =============================================================================

-- -----------------------------------------------------------------------------
-- BatteryWidget
-- -----------------------------------------------------------------------------

local function getBatteryIcon()
  return models.battery.discharging
      and beautiful.assets('battery-discharging.svg')
    or beautiful.assets('battery-charging.svg')
end

local batteryIconWidget = wibox.widget({
  image = getBatteryIcon(),
  widget = wibox.widget.imagebox,
})

models.battery:connect_signal('update', function()
  batteryIconWidget.image = getBatteryIcon()
end)

local batteryWidget = StatusItemWidget({
  widget = DialWidget({
    model = models.battery,
    color = beautiful.red,
    widget = batteryIconWidget,
  }),
})

-- -----------------------------------------------------------------------------
-- VolumeWidget
-- -----------------------------------------------------------------------------

local function getVolumeIcon()
  -- TODO: muted icon
  return models.volume.active and beautiful.assets('volume.svg')
    or beautiful.assets('volume.svg')
end

local volumeIconWidget = wibox.widget({
  image = getVolumeIcon(),
  widget = wibox.widget.imagebox,
})

models.volume:connect_signal('update', function()
  volumeIconWidget.image = getVolumeIcon()
end)

local volumeWidget = StatusItemWidget({
  widget = DialWidget({
    model = models.volume,
    color = beautiful.green,
    widget = volumeIconWidget,
  }),
  keypressed_callback = function(mod, key)
    if #mod == 0 then
      if key == 'j' then
        models.volume:set(models.volume.percent - 5)
      elseif key == 'k' then
        models.volume:set(models.volume.percent + 5)
      elseif key == 'd' then
        models.volume:set(models.volume.percent - 15)
      elseif key == 'u' then
        models.volume:set(models.volume.percent + 15)
      elseif key == ' ' then
        models.volume:toggle()
      end
    end
  end,
})

-- -----------------------------------------------------------------------------
-- BrightnessWidget
-- -----------------------------------------------------------------------------

local brightnessWidget = StatusItemWidget({
  widget = DialWidget({
    model = models.brightness,
    color = beautiful.yellow,
    widget = {
      image = beautiful.assets('brightness.svg'),
      widget = wibox.widget.imagebox,
    },
  }),
  keypressed_callback = function(mod, key)
    if #mod == 0 then
      if key == 'j' then
        models.brightness:set(models.brightness.percent - 5)
      elseif key == 'k' then
        models.brightness:set(models.brightness.percent + 5)
      elseif key == 'd' then
        models.brightness:set(models.brightness.percent - 15)
      elseif key == 'u' then
        models.brightness:set(models.brightness.percent + 15)
      end
    end
  end,
})

-- -----------------------------------------------------------------------------
-- NotificationWidget
-- -----------------------------------------------------------------------------

local function getNotificationIcon()
  if models.notifications.active then
    return beautiful.assets('notifications-active.svg')
  else
    return beautiful.assets('notifications-inactive.svg')
  end
end

local notificationIconWidget = wibox.widget({
  image = getNotificationIcon(),
  widget = wibox.widget.imagebox,
})

models.notifications:connect_signal('update', function()
  notificationIconWidget.image = getNotificationIcon()
end)

local notificationWidget = StatusItemWidget({
  widget = notificationIconWidget,
  keypressed_callback = function(mod, key)
    if #mod == 0 then
      if key == ' ' then
        models.notifications:toggle()
      end
    end
  end,
})

-- -----------------------------------------------------------------------------
-- Popup
-- -----------------------------------------------------------------------------

local statusRowWidget = wibox.widget({
  batteryWidget,
  volumeWidget,
  brightnessWidget,
  notificationWidget,
  spacing = 16,
  layout = wibox.layout.fixed.horizontal,
})

local popup = awful.popup({
  widget = {
    {
      {
        {
          {
            format = ('<span color="%s">%s</span>'):format(
              beautiful.blue,
              '%a %b %d'
            ),
            font = 'Kalam Bold 30',
            align = 'center',
            widget = wibox.widget.textclock,
          },
          {
            format = ('<span color="%s">%s</span>'):format(
              beautiful.magenta,
              '%H:%M'
            ),
            font = 'Kalam Bold 20',
            align = 'center',
            widget = wibox.widget.textclock,
          },
          layout = wibox.layout.fixed.vertical,
        },
        widget = wibox.container.place,
      },
      statusRowWidget,
      spacing = 16,
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  },
  bg = beautiful.dimmed,
  visible = false,
  ontop = true,
})

local function focusStatus(dir)
  local newSelectedItemIndex = math.min(
    #statusRowWidget.children,
    math.max(1, selectedItemIndex + dir)
  )

  statusRowWidget.children[selectedItemIndex]:emit_signal('request::unselect')
  statusRowWidget.children[newSelectedItemIndex]:emit_signal('request::select')
  selectedItemIndex = newSelectedItemIndex
end

local keygrabber = awful.keygrabber({
  keybindings = {
    {
      {},
      'h',
      function()
        focusStatus(-1)
      end,
    },
    {
      {},
      'l',
      function()
        focusStatus(1)
      end,
    },
    {
      { 'Mod4' },
      ';',
      function(self)
        self:stop()
      end,
    },
  },
  keypressed_callback = function(self, mod, key)
    local selectedWidget = statusRowWidget.children[selectedItemIndex]
    if type(selectedWidget.keypressed_callback) == 'function' then
      selectedWidget.keypressed_callback(mod, key)
    end
  end,
  stop_callback = function()
    popup.visible = true
  end,
})

-- =============================================================================
-- Return
-- =============================================================================

focusStatus(0)

return function()
  if popup.visible == true then
    popup.visible = false
  else
    popup.screen = awful.screen.focused()
    popup.minimum_width = popup.screen.geometry.width
    popup.minimum_height = popup.screen.geometry.height
    popup.maximum_width = popup.screen.geometry.width
    popup.maximum_height = popup.screen.geometry.height
    popup.visible = true
    keygrabber:start()
  end
end
