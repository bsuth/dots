local dbus = require('lib.dbus')
local system_bus = require('models.system_bus')
local upower = require('ffi.upower')

-- -----------------------------------------------------------------------------
-- Model
-- -----------------------------------------------------------------------------

---@class Battery
---@field percent number
---@field state 'charging' | 'discharging' | 'unknown'
local battery = {
  percent = -1,
  state = 'unknown',
}

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

local function update_state(state)
  local is_charging = (
    state == upower.UP_DEVICE_STATE_PENDING_CHARGE or
    state == upower.UP_DEVICE_STATE_CHARGING or
    state == upower.UP_DEVICE_STATE_FULLY_CHARGED
  )

  local is_discharging = (
    state == upower.UP_DEVICE_STATE_PENDING_DISCHARGE or
    state == upower.UP_DEVICE_STATE_DISCHARGING
  )

  if is_charging then
    battery.state = 'charging'
  elseif is_discharging then
    battery.state = 'discharging'
  else
    battery.state = 'unknown'
  end
end

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

dbus.call({
  connection = system_bus,
  bus_name = 'org.freedesktop.UPower',
  object_path = '/org/freedesktop/UPower/devices/DisplayDevice',
  interface_name = 'org.freedesktop.DBus.Properties',
  method_name = 'Get',
  parameters_type = '(ss)',
  parameters = { 'org.freedesktop.UPower.Device', 'Percentage' },
}, function(response)
  battery.percent = response[1]
end)

dbus.call({
  connection = system_bus,
  bus_name = 'org.freedesktop.UPower',
  object_path = '/org/freedesktop/UPower/devices/DisplayDevice',
  interface_name = 'org.freedesktop.DBus.Properties',
  method_name = 'Get',
  parameters_type = '(ss)',
  parameters = { 'org.freedesktop.UPower.Device', 'State' },
}, function(response)
  update_state(response[1])
end)

dbus.subscribe({
  connection = system_bus,
  object_path = '/org/freedesktop/UPower/devices/DisplayDevice',
  interface_name = 'org.freedesktop.DBus.Properties',
  signal_name = 'PropertiesChanged',
}, function(signal)
  local properties = signal.parameters[2]

  if properties.Percent ~= nil then
    battery.percent = properties.Percent
  end

  if properties.State ~= nil then
    update_state(properties.State)
  end
end)

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return battery
