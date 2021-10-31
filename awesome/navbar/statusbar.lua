local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

local core = require('navbar.core')
local models = require('models')

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
    {
      iconWidget,
      right = 8,
      widget = wibox.container.margin,
    },
    {
      markup = core.markupText(
        math.ceil(models.battery.percent) .. '%',
        beautiful.colors.red
      ),
      widget = wibox.widget.textbox,
    },
    layout = wibox.layout.fixed.horizontal,
  })
end

-- -----------------------------------------------------------------------------
-- VolumeWidget
-- -----------------------------------------------------------------------------

local function getVolumeIcon()
  -- TODO: muted icon
  return models.volume.active and beautiful.assets('volume.svg')
    or beautiful.assets('volume.svg')
end

local function getVolumeText()
  return core.markupText(
    math.ceil(models.volume.percent) .. '%',
    beautiful.colors.green
  )
end

local function VolumeWidget()
  local iconWidget = wibox.widget({
    image = getVolumeIcon(),
    widget = wibox.widget.imagebox,
  })

  local textWidget = wibox.widget({
    markup = getVolumeText(),
    widget = wibox.widget.textbox,
  })

  models.volume:connect_signal('update', function()
    iconWidget.image = getVolumeIcon()
    textWidget.markup = getVolumeText()
  end)

  return wibox.widget({
    {
      iconWidget,
      right = 8,
      widget = wibox.container.margin,
    },
    textWidget,
    layout = wibox.layout.fixed.horizontal,
  })
end

-- -----------------------------------------------------------------------------
-- BrightnessWidget
-- -----------------------------------------------------------------------------

local function getBrightnessText()
  return core.markupText(
    math.ceil(models.brightness.percent) .. '%',
    beautiful.colors.yellow
  )
end

local function BrightnessWidget()
  local textWidget = wibox.widget({
    markup = getBrightnessText(),
    widget = wibox.widget.textbox,
  })

  models.brightness:connect_signal('update', function()
    textWidget.markup = getBrightnessText()
  end)

  return wibox.widget({
    {
      wibox.widget({
        image = beautiful.assets('brightness.svg'),
        widget = wibox.widget.imagebox,
      }),
      right = 8,
      widget = wibox.container.margin,
    },
    textWidget,
    layout = wibox.layout.fixed.horizontal,
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
  for key, component in pairs(self.components) do
    if component.index == self.selectedComponent.index + dir then
      self.selectedComponent = component
      self:refresh()
      break
    end
  end
end

function Statusbar:renderComponent(component)
  return core.Select({
    active = component == self.selectedComponent,
    disabled = component.disabled,
    widget = component.widget,
  })
end

function Statusbar:refresh()
  self.leftWidget.children = {
    self:renderComponent(self.components.datetime),
  }

  self.middleWidget.children = {
    self:renderComponent(self.components.battery),
    self:renderComponent(self.components.volume),
    self:renderComponent(self.components.brightness),
  }

  self.rightWidget.children = {
    self:renderComponent(self.components.locale),
    self:renderComponent(self.components.notification),
  }
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return function(navbar)
  local newStatusbar = setmetatable({
    navbar = navbar,

    leftWidget = wibox.widget({
      spacing = 16,
      layout = wibox.layout.fixed.horizontal,
    }),

    middleWidget = wibox.widget({
      spacing = 16,
      layout = wibox.layout.fixed.horizontal,
    }),

    rightWidget = wibox.widget({
      spacing = 16,
      layout = wibox.layout.fixed.horizontal,
    }),

    components = {
      datetime = {
        index = 1,
        disabled = true,
        widget = wibox.widget({
          {
            format = core.markupText('%a %b %d', beautiful.colors.blue),
            widget = wibox.widget.textclock,
          },
          {
            format = core.markupText(' %H:%M', beautiful.colors.purple),
            widget = wibox.widget.textclock,
          },
          layout = wibox.layout.fixed.horizontal,
        }),
      },

      battery = {
        index = 2,
        disabled = true,
        widget = BatteryWidget(),
      },

      volume = {
        index = 3,
        widget = VolumeWidget(),
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

      brightness = {
        index = 4,
        widget = BrightnessWidget(),
        keypressed_callback = function(mod, key)
          if key == 'j' then
            models.brightness:set(models.brightness.percent - 5)
          elseif key == 'k' then
            models.brightness:set(models.brightness.percent + 5)
          elseif key == 'd' then
            models.brightness:set(models.brightness.percent - 15)
          elseif key == 'u' then
            models.brightness:set(models.brightness.percent + 15)
          end
        end,
      },

      locale = {
        index = 5,
        widget = LocaleWidget(),
        keypressed_callback = function(mod, key)
          if key == ' ' then
            models.locale:cycle()
          end
        end,
      },

      notification = {
        index = 6,
        widget = NotificationWidget(),
        keypressed_callback = function(mod, key)
          if key == ' ' then
            models.notifications:toggle()
          end
        end,
      },
    },
  }, StatusbarMT)

  newStatusbar.widget = wibox.widget({
    newStatusbar.leftWidget,
    {
      newStatusbar.middleWidget,
      layout = wibox.container.place,
    },
    newStatusbar.rightWidget,

    layout = wibox.layout.align.horizontal,
  })

  local function focusPrev()
    newStatusbar:focus(-1)
  end

  local function focusNext()
    newStatusbar:focus(1)
  end

  local function stop(self)
    self:stop()
  end

  newStatusbar.keygrabber = awful.keygrabber({
    keybindings = {
      { {}, 'h', focusPrev },
      { {}, 'l', focusNext },
      { { 'Mod4' }, ';', stop },
    },
    keypressed_callback = function(self, mod, key)
      local selectedComponent = newStatusbar.selectedComponent
      if type(selectedComponent.keypressed_callback) == 'function' then
        selectedComponent.keypressed_callback(mod, key)
      end
    end,
    stop_callback = function()
      navbar:setMode('tabs')
    end,
  })

  newStatusbar.selectedComponent = newStatusbar.components.volume
  return newStatusbar
end
