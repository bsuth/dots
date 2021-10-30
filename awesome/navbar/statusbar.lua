local awful = require('awful')
local beautiful = require('beautiful')
local models = require('models')
local wibox = require('wibox')

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

local function markupText(text, color)
  return ('<span color="%s" font_family="%s" size="small">%s</span>'):format(
    color or beautiful.colors.white,
    'Hack Regular',
    tostring(text)
  )
end

-- -----------------------------------------------------------------------------
-- BatteryWidget
-- -----------------------------------------------------------------------------

local function BatteryWidget()
  local iconWidget = wibox.widget({
    image = models.battery.discharging and beautiful.assets(
      'battery-discharging.svg'
    ) or beautiful.assets('battery-charging.svg'),
    widget = wibox.widget.imagebox,
  })

  models.battery:connect_signal('update', function()
    iconWidget.image = models.battery.discharging
        and beautiful.assets('battery-discharging.svg')
      or beautiful.assets('battery-charging.svg')
  end)

  return wibox.widget({
    iconWidget,
    {
      markup = markupText(
        math.ceil(models.battery.percent) .. '%',
        beautiful.colors.red
      ),
      widget = wibox.widget.textbox,
    },
    layout = wibox.layout.fixed.horizontal,
  })
end

-- -----------------------------------------------------------------------------
-- SystemStatWidgets (Volume + Brightness)
-- -----------------------------------------------------------------------------

local function SystemStatWidget(args)
  local textWidget = wibox.widget({
    markup = markupText(math.ceil(args.model.percent) .. '%', args.color),
    widget = wibox.widget.textbox,
  })

  args.model:connect_signal('update', function()
    textWidget.markup = markupText(
      math.ceil(args.model.percent) .. '%',
      args.color
    )
  end)

  local systemStatWidget = wibox.widget({
    {
      image = args.icon,
      widget = wibox.widget.imagebox,
    },
    textWidget,
    layout = wibox.layout.fixed.horizontal,
  })

  systemStatWidget:connect_signal(
    'button::press',
    function(self, lx, ly, button, mods)
      if button == 4 then
        args.model:set(args.model.percent + 5)
      elseif button == 5 then
        args.model:set(args.model.percent - 5)
      end
    end
  )

  return systemStatWidget
end

-- -----------------------------------------------------------------------------
-- LocaleWidget
-- -----------------------------------------------------------------------------

local function getLocaleIcon()
  local locale = models.locale.list[models.locale.index]

  if locale == 'mozc' then
    return beautiful.assets('ja_JP.svg')
  else
    return beautiful.assets('en_US.svg')
  end
end

local function LocaleWidget()
  local localeWidget = wibox.widget({
    image = getLocaleIcon(),
    widget = wibox.widget.imagebox,
  })

  models.locale:connect_signal('update', function()
    localeWidget.image = getLocaleIcon()
  end)

  return localeWidget
end

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

local function NotificationWidget()
  local notificationWidget = wibox.widget({
    forced_width = 50,
    forced_height = 50,
    image = getNotificationIcon(),
    widget = wibox.widget.imagebox,
  })

  models.notifications:connect_signal('update', function()
    notificationWidget.image = getNotificationIcon()
  end)

  return notificationWidget
end

-- -----------------------------------------------------------------------------
-- Statusbar
-- -----------------------------------------------------------------------------

local Statusbar = setmetatable({}, {
  __call = function(self, navbar)
    return setmetatable({
      navbar = navbar,
      widget = wibox.widget({
        {
          format = markupText('%a %b %d', beautiful.colors.blue),
          widget = wibox.widget.textclock,
        },
        {
          format = markupText(' %H:%M', beautiful.colors.purple),
          widget = wibox.widget.textclock,
        },

        BatteryWidget(),
        SystemStatWidget({
          model = models.volume,
          color = beautiful.colors.green,
          icon = beautiful.assets('volume.svg'),
        }),
        SystemStatWidget({
          model = models.brightness,
          color = beautiful.colors.yellow,
          icon = beautiful.assets('brightness.svg'),
        }),

        LocaleWidget(),
        NotificationWidget(),

        layout = wibox.layout.fixed.horizontal,
      }),
    }, {
      __index = self,
    })
  end,
})

function Statusbar:toggle()
  if self.widget.visible then
    self.navbar:setMode('tabs')
  else
    self.navbar:setMode('statusbar')
  end
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return Statusbar
