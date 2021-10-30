local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

local core = require('navbar.core')
local models = require('models')

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

  return core.Select({
    active = args.active,
    widget = systemStatWidget,
  })
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

local Statusbar = {}
local StatusbarMT = { __index = Statusbar }

function Statusbar:focus(dir)
  for i, selectable in pairs(self.selectables) do
    if selectable == self.selected then
      local newSelected = self.selectables[i + dir]
      if newSelected then
        self.selected = newSelected
        self:refresh()
      end
      break
    end
  end
end

function Statusbar:refresh()
  local children = {}

  for _, staticWidget in pairs(self.staticWidgets) do
    children[#children + 1] = staticWidget
  end

  for _, selectable in pairs(self.selectables) do
    children[#children + 1] = core.Select({
      active = selectable == self.selected,
      widget = selectable.widget,
    })
  end

  self.widget.children = children
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return function(navbar)
  local newStatusbar = setmetatable({
    navbar = navbar,

    staticWidgets = {
      wibox.widget({
        format = markupText('%a %b %d', beautiful.colors.blue),
        widget = wibox.widget.textclock,
      }),
      wibox.widget({
        format = markupText(' %H:%M', beautiful.colors.purple),
        widget = wibox.widget.textclock,
      }),
      BatteryWidget(),
    },

    widget = wibox.widget({
      layout = wibox.layout.fixed.horizontal,
    }),
  }, StatusbarMT)

  newStatusbar.selectables = {
    {
      widget = SystemStatWidget({
        model = models.volume,
        color = beautiful.colors.green,
        icon = beautiful.assets('volume.svg'),
      }),
      keypressed_callback = function(mod, key)
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
      end,
    },
    {
      widget = SystemStatWidget({
        model = models.brightness,
        color = beautiful.colors.yellow,
        icon = beautiful.assets('brightness.svg'),
      }),
    },
    {
      widget = LocaleWidget(),
    },
    {
      widget = NotificationWidget(),
    },
  }
  newStatusbar.selected = newStatusbar.selectables[1]

  newStatusbar.keygrabber = awful.keygrabber({
    keybindings = {
      {
        {},
        'h',
        function()
          newStatusbar:focus(-1)
        end,
      },
      {
        {},
        'l',
        function()
          newStatusbar:focus(1)
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
      if type(newStatusbar.selected.keypressed_callback) == 'function' then
        newStatusbar.selected.keypressed_callback(mod, key)
      end
    end,
    stop_callback = function()
      navbar:setMode('tabs')
    end,
  })

  return newStatusbar
end
