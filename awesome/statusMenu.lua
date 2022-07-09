local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local models = require('models')
local wibox = require('wibox')

-- =============================================================================
-- State / Config
-- =============================================================================

local STATUS_ITEM_SIZE = 32
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

      local bg = beautiful.hex2rgb(beautiful.lightGray)
      cr:set_source_rgb(bg[1], bg[2], bg[3])
      gears.shape.arc(cr, m, m, DIAL_BORDER_WIDTH, 0, 2 * math.pi)
      cr:fill()

      if opts.model.percent and opts.model.percent > 0 then
        local fg = beautiful.hex2rgb(opts.color)
        cr:set_source_rgb(fg[1], fg[2], fg[3])

        -- 98 is close enough so round (plus, battery percent never reaches
        -- 100% on some computers)
        if opts.model.percent < 98 then
          -- If (thetaEnd - thetaStart) is too small, then cairo will shift
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

          local thetaEnd = 3 * math.pi / 2
          local thetaStart = thetaEnd
            - (opts.model.percent / 100) * (2 * math.pi)

          gears.shape.arc(
            cr,
            m,
            m,
            DIAL_BORDER_WIDTH,
            thetaStart,
            thetaEnd,
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
    dialWidget:emit_signal('widget::redraw_needed')
  end)

  return dialWidget
end

local function StatusItemWidget(opts)
  local textWidget = wibox.widget({
    text = tostring(opts.model.percent) .. '%',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
  })

  local statusItemWidget = wibox.widget({
    {
      {
        {
          opts.widget,
          widget = wibox.container.place,
        },
        textWidget,
        spacing = 16,
        layout = wibox.layout.fixed.vertical,
      },
      margins = 16,
      widget = wibox.container.margin,
    },
    fg = opts.color,
    bg = beautiful.darkGray,
    widget = wibox.container.background,
  })

  opts.model:connect_signal('update', function()
    textWidget.text = tostring(opts.model.percent) .. '%'
  end)

  statusItemWidget:connect_signal('request::select', function()
    statusItemWidget.bg = beautiful.lightGray
  end)

  statusItemWidget:connect_signal('request::unselect', function()
    statusItemWidget.bg = beautiful.darkGray
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
  forced_width = STATUS_ITEM_SIZE,
  forced_height = STATUS_ITEM_SIZE,
  widget = wibox.widget.imagebox,
})

models.battery:connect_signal('update', function()
  batteryIconWidget.image = getBatteryIcon()
end)

local batteryWidget = StatusItemWidget({
  model = models.battery,
  color = beautiful.red,
  widget = batteryIconWidget,
})

-- -----------------------------------------------------------------------------
-- VolumeWidget
-- -----------------------------------------------------------------------------

local function getVolumeIcon()
  return models.volume.active and beautiful.assets('volume.svg')
    or beautiful.assets('volume-muted.svg')
end

local volumeIconWidget = wibox.widget({
  image = getVolumeIcon(),
  forced_width = STATUS_ITEM_SIZE,
  forced_height = STATUS_ITEM_SIZE,
  widget = wibox.widget.imagebox,
})

models.volume:connect_signal('update', function()
  volumeIconWidget.image = getVolumeIcon()
end)

local volumeWidget = StatusItemWidget({
  model = models.volume,
  color = beautiful.green,
  widget = volumeIconWidget,
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
  model = models.brightness,
  color = beautiful.yellow,
  widget = {
    image = beautiful.assets('brightness.svg'),
    forced_width = STATUS_ITEM_SIZE,
    forced_height = STATUS_ITEM_SIZE,
    widget = wibox.widget.imagebox,
  },
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

local notificationWidget = wibox.widget({
  image = getNotificationIcon(),
  forced_width = 64,
  forced_height = 64,
  widget = wibox.widget.imagebox,
})

models.notifications:connect_signal('update', function()
  notificationWidget.image = getNotificationIcon()
end)

-- -----------------------------------------------------------------------------
-- Popup
-- -----------------------------------------------------------------------------

local statusRowWidget = wibox.widget({
  brightnessWidget,
  volumeWidget,
  batteryWidget,
  spacing = 24,
  layout = wibox.layout.flex.horizontal,
})

local popup = awful.popup({
  widget = {
    {
      {
        {
          {
            {
              {
                format = ('<span color="%s">%s</span>'):format(
                  beautiful.magenta,
                  '%H:%M'
                ),
                font = 'Quicksand Regular 50',
                forced_height = 50, -- match line height to font size
                widget = wibox.widget.textclock,
              },
              {
                format = ('<span color="%s">%s</span>'):format(
                  beautiful.blue,
                  '%a %b %d'
                ),
                font = 'Quicksand Regular 20',
                forced_height = 20, -- match line height to font size
                widget = wibox.widget.textclock,
              },
              spacing = 16,
              -- Force width to prevent resizing on time change
              forced_width = 200,
              layout = wibox.layout.fixed.vertical,
            },
            {
              notificationWidget,
              widget = wibox.container.place,
            },
            spacing = 32,
            layout = wibox.layout.fixed.horizontal,
          },
          statusRowWidget,
          spacing = 32,
          layout = wibox.layout.fixed.vertical,
        },
        margins = 32,
        widget = wibox.container.margin,
      },
      shape_border_width = 1,
      shape_border_color = beautiful.cyan,
      bg = beautiful.darkGray,
      widget = wibox.container.background,
    },
    margins = 16,
    widget = wibox.container.margin,
  },
  placement = awful.placement.bottom_right,
  bg = beautiful.transparent,
  visible = false,
  ontop = true,
  type = 'dock',
})

-- =============================================================================
-- Keygrabber
-- =============================================================================

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
      {},
      'm',
      function()
        models.notifications:toggle()
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
    popup.visible = false
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
    popup.visible = true
    keygrabber:start()
  end
end
