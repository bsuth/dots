local dbus = require('lib.dbus')
local system_bus = require('models.system_bus')

---@class BluetoothDevice
---@field object_path string
---@field name string
---@field address string
---@field adapter string
---@field connected boolean
---@field paired boolean
---@field trusted boolean
---@field subscriptions number[]
local Device = {}
local DeviceMT = { __index = Device }

-- -----------------------------------------------------------------------------
-- Methods
-- -----------------------------------------------------------------------------

function Device:connect()
  -- TODO: loading + reset on error
  dbus.call({
    connection = system_bus,
    bus_name = 'org.bluez',
    object_path = self.object_path,
    interface_name = 'org.bluez.Device1',
    method_name = 'Connect',
  })
end

function Device:disconnect()
  -- TODO: loading + reset on error
  dbus.call({
    connection = system_bus,
    bus_name = 'org.bluez',
    object_path = self.object_path,
    interface_name = 'org.bluez.Device1',
    method_name = 'Disconnect',
  })
end

function Device:pair()
  -- TODO: loading + reset on error
  dbus.call({
    connection = system_bus,
    bus_name = 'org.bluez',
    object_path = self.object_path,
    interface_name = 'org.bluez.Device1',
    method_name = 'Pair',
  })
end

function Device:unpair()
  -- TODO: loading + reset on error
  dbus.call({
    connection = system_bus,
    bus_name = 'org.bluez',
    object_path = self.adapter,
    interface_name = 'org.bluez.Adapter1',
    method_name = 'RemoveDevice',
    parameters_type = '(o)',
    parameters = { self.object_path },
  })
end

function Device:destroy()
  for _, subscription in ipairs(self.subscriptions) do
    dbus.unsubscribe(system_bus, subscription)
  end
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

---@param object_path string
---@param device_managed_object table
---@return BluetoothDevice
return function(object_path, device_managed_object)
  local device = setmetatable({
    object_path = object_path,
    name = device_managed_object.Name,
    address = device_managed_object.Address,
    adapter = device_managed_object.Adapter,
    connected = device_managed_object.Connected,
    paired = device_managed_object.Paired,
    trusted = device_managed_object.Trusted,
    subscriptions = {},
  }, DeviceMT)

  table.insert(device.subscriptions, dbus.subscribe({
    connection = system_bus,
    object_path = object_path,
    interface_name = 'org.freedesktop.DBus.Properties',
    signal_name = 'PropertiesChanged',
  }, function(response)
    local properties = response[1]

    if properties.Connected ~= nil then
      device.connected = properties.Connected
    end

    if properties.Paired ~= nil then
      device.paired = properties.Paired
    end

    if properties.Trusted ~= nil then
      device.trusted = properties.Trusted
    end
  end))

  return device
end
