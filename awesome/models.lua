local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local notify = require('notify')

-- -----------------------------------------------------------------------------
-- Battery
-- -----------------------------------------------------------------------------

local upower = require('lgi').require('UPowerGlib')
local device = upower.Client():get_display_device()

local battery = gears.table.crush(gears.object(), {
  percent = 0,
  discharging = true,
  sentLowWarning = false,

  update = function(self)
    self.percent = device.percentage
    self.discharging = gears.table.hasitem({
      upower.DeviceState.PENDING_DISCHARGE,
      upower.DeviceState.DISCHARGING,
    }, device.state) ~= nil

    if self.percent < 15 then
      if not self.sentLowWarning then
        notify('Low Battery', true)
        self.sentLowWarning = true
      end
    elseif self.sentLowWarning then
      self.sentLowWarning = false
    end

    self:emit_signal('update')
  end,
})

battery:update()
device.on_notify = function()
  battery:update()
end

-- -----------------------------------------------------------------------------
-- Bluetooth
-- -----------------------------------------------------------------------------

local bluetooth = gears.table.crush(gears.object(), {
  active = false,

  -- `rfkill block` is SLOW. So to prevent lags in UI, pre-emit the update
  -- and hope nothing goes wrong. We use a queue to change the state to
  -- guarantee our commands are applied sequentially.
  queue = {},
  running = false,

  empty_queue = function(self)
    self.running = true
    local action = table.remove(self.queue, 1)

    awful.spawn.easy_async_with_shell(
      '/sbin/rfkill ' .. action .. ' bluetooth',
      function()
        if #self.queue > 0 then
          self:empty_queue()
        else
          self.running = false
        end
      end
    )
  end,

  toggle = function(self)
    self.active = not self.active
    self:emit_signal('update')

    table.insert(self.queue, self.active and 'unblock' or 'block')
    if not self.running then
      self:empty_queue()
    end
  end,
})

awful.spawn.easy_async_with_shell(
  [[ /sbin/rfkill list bluetooth | grep 'blocked: yes' | wc -l ]],
  function(stdout, _, _, _)
    bluetooth.active = tonumber(stdout) == 0
    bluetooth:emit_signal('update')
  end
)

-- -----------------------------------------------------------------------------
-- Brightness
-- -----------------------------------------------------------------------------

local brightness = gears.table.crush(gears.object(), {
  percent = 0,

  set = function(self, percent)
    self.percent = math.min(math.max(0, percent), 100)
    awful.spawn.easy_async_with_shell(
      ('brightnessctl set %s%%'):format(self.percent),
      function()
        self:emit_signal('update')
      end
    )
  end,
})

awful.spawn.easy_async_with_shell(
  [[ echo $(( 100 * $(brightnessctl get) / $(brightnessctl max) )) ]],
  function(stdout, _, _, _)
    brightness.percent = tonumber(stdout)
    brightness:emit_signal('update')
  end
)

-- -----------------------------------------------------------------------------
-- Disk
-- -----------------------------------------------------------------------------

local disk = gears.table.crush(gears.object(), {
  percent = 0,

  update = function(self)
    awful.spawn.easy_async_with_shell(
      [[ df --output='pcent' / | tail -n 1 | sed 's/%//' ]],
      function(stdout)
        self.percent = tonumber(stdout)
        self:emit_signal('update')
      end
    )
  end,
})

gears.timer({
  timeout = 60,
  call_now = true,
  autostart = true,
  callback = function()
    disk:update()
  end,
})

-- -----------------------------------------------------------------------------
-- Locale
-- -----------------------------------------------------------------------------

local locale = gears.table.crush(gears.object(), {
  index = 1,
  list = {
    'keyboard-us',
    'mozc',
  },

  set = function(self, newindex)
    self.index = newindex
    awful.spawn.easy_async_with_shell(
      'fcitx5-remote -s ' .. self.list[self.index],
      function()
        self:emit_signal('update')
      end
    )
  end,

  cycle = function(self)
    self:set(self.index == #self.list and 1 or self.index + 1)
  end,
})

-- -----------------------------------------------------------------------------
-- Notifications
-- -----------------------------------------------------------------------------

local notifications = gears.table.crush(gears.object(), {
  -- Use custom active property instead of naughty's suspended state, since
  -- suspended state will save and queue all notifications during suspension,
  -- which we don't want
  active = true,

  toggle = function(self)
    self.active = not self.active
    self:emit_signal('update')
  end,
})

naughty.config.notify_callback = function(notification)
  -- notification.urgent is a custom property attached by notify.lua.
  if not notification.urgent and not notifications.active then
    return nil
  end

  beautiful.styleNotification(notification)
  return notification
end

-- -----------------------------------------------------------------------------
-- Ram
-- -----------------------------------------------------------------------------

local ram = gears.table.crush(gears.object(), {
  percent = 0,

  update = function(self)
    awful.spawn.easy_async_with_shell(
      [[ free | grep Mem | awk '{print $3/$2 * 100}' ]],
      function(stdout)
        self.percent = tonumber(stdout)
        self:emit_signal('update')
      end
    )
  end,
})

gears.timer({
  timeout = 5,
  call_now = true,
  autostart = true,
  callback = function()
    ram:update()
  end,
})

-- -----------------------------------------------------------------------------
-- Volume
-- -----------------------------------------------------------------------------

local volume = gears.table.crush(gears.object(), {
  percent = 0,
  active = false,

  set = function(self, percent)
    self.percent = math.min(math.max(0, percent), 100)
    awful.spawn.easy_async_with_shell(
      ('amixer sset Master %d%%'):format(self.percent),
      function()
        self:emit_signal('update')
      end
    )
  end,

  toggle = function(self)
    awful.spawn.easy_async_with_shell('amixer sset Master toggle', function()
      self.active = not self.active
      self:emit_signal('update')
    end)
  end,
})

awful.spawn.easy_async_with_shell(
  [[ amixer sget Master | tail -n 1 | sed -E 's/.*\[([0-9]+)%\].*/\1/' ]],
  function(stdout, _, _, _)
    volume.percent = tonumber(stdout)
    volume:emit_signal('update')
  end
)

awful.spawn.easy_async_with_shell(
  [[ amixer sget Master | tail -n 1 | sed -E 's/.*\[(off|on)\].*/\1/' ]],
  function(stdout, _, _, _)
    volume.active = string.find(stdout, 'on')
    volume:emit_signal('update')
  end
)

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return {
  battery = battery,
  bluetooth = bluetooth,
  brightness = brightness,
  disk = disk,
  locale = locale,
  notifications = notifications,
  ram = ram,
  volume = volume,
}
