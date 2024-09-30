local dbus = require('lib.dbus')
local system_bus = require('models.system_bus')
local Device = require('models.bluetooth.device')

---@class BluetoothAdapter
---@field object_path string
---@field powered boolean
---@field discovering boolean
---@field devices table<string, BluetoothDevice>
---@field subscriptions number[]
local Adapter = {}
local AdapterMT = { __index = Adapter }

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

---@param adapter BluetoothAdapter
---@param managed_object table<string, table<string, any>>
---@return boolean
local function is_adapter_device(adapter, managed_object)
  return ( -- ignore devices that lack a name / class
    managed_object['org.bluez.Device1'] ~= nil and
    managed_object['org.bluez.Device1'].Name ~= nil and
    managed_object['org.bluez.Device1'].Class ~= nil and
    managed_object['org.bluez.Device1'].Adapter == adapter.object_path
  )
end

-- -----------------------------------------------------------------------------
-- Methods
-- -----------------------------------------------------------------------------

---@param object_path string
---@param device_managed_object table<string, table<string, any>>
function Adapter:add_device(object_path, device_managed_object)
  self.devices[object_path] = Device(object_path, device_managed_object)
end

---@param object_path string
function Adapter:remove_device(object_path)
  local device = self.devices[object_path]

  if device == nil then
    return
  end

  device:destroy()
  self.devices[object_path] = nil
end

function Adapter:power()
  dbus.call({
    connection = system_bus,
    bus_name = 'org.bluez',
    object_path = self.object_path,
    interface_name = 'org.freedesktop.DBus.Properties',
    method_name = 'Set',
    parameters_type = '(ssv)',
    parameters = { 'org.bluez.Adapter1', 'Powered', true },
  })
end

function Adapter:unpower()
  dbus.call({
    connection = system_bus,
    bus_name = 'org.bluez',
    object_path = self.object_path,
    interface_name = 'org.freedesktop.DBus.Properties',
    method_name = 'Set',
    parameters_type = '(ssv)',
    parameters = { 'org.bluez.Adapter1', 'Powered', false },
  })
end

function Adapter:discover()
  dbus.call({
    connection = system_bus,
    bus_name = 'org.bluez',
    object_path = self.object_path,
    interface_name = 'org.bluez.Adapter1',
    method_name = 'StartDiscovery',
  })
end

function Adapter:undiscover()
  dbus.call({
    connection = system_bus,
    bus_name = 'org.bluez',
    object_path = self.object_path,
    interface_name = 'org.bluez.Adapter1',
    method_name = 'StopDiscovery',
  })
end

function Adapter:destroy()
  for _, device in pairs(self.devices) do
    device:destroy()
  end

  for _, subscription in ipairs(self.subscriptions) do
    dbus.unsubscribe(system_bus, subscription)
  end
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

---@param object_path string
---@param adapter_managed_object table
---@return BluetoothAdapter
return function(object_path, adapter_managed_object)
  local adapter = setmetatable({
    object_path = object_path,
    powered = adapter_managed_object.Powered,
    discovering = adapter_managed_object.Discovering,
    devices = {},
    subscriptions = {},
  }, AdapterMT)

  dbus.call({
    connection = system_bus,
    bus_name = 'org.bluez',
    object_path = '/',
    interface_name = 'org.freedesktop.DBus.ObjectManager',
    method_name = 'GetManagedObjects',
  }, function(response)
    for managed_object_path, managed_object in pairs(response[1]) do
      if is_adapter_device(adapter, managed_object) then
        adapter:add_device(managed_object_path, managed_object['org.bluez.Device1'])
      end
    end
  end)

  table.insert(adapter.subscriptions, dbus.subscribe({
    connection = system_bus,
    object_path = object_path,
    interface_name = 'org.freedesktop.DBus.Properties',
    signal_name = 'PropertiesChanged',
  }, function(response)
    local properties = response[1]

    if properties.Powered ~= nil then
      adapter.powered = properties.Powered
    end

    if properties.Discovering ~= nil then
      adapter.discovering = properties.Discovering
    end
  end))

  table.insert(adapter.subscriptions, dbus.subscribe({
    connection = system_bus,
    object_path = '/',
    interface_name = 'org.freedesktop.DBus.ObjectManager',
    signal_name = 'InterfacesAdded',
  }, function(response)
    if is_adapter_device(adapter, response[2]) then
      adapter:add_device(response[1], response[2]['org.bluez.Device1'])
    end
  end))

  table.insert(adapter.subscriptions, dbus.subscribe({
    connection = system_bus,
    object_path = '/',
    interface_name = 'org.freedesktop.DBus.ObjectManager',
    signal_name = 'InterfacesRemoved',
  }, function(response)
    adapter:remove_device(response[1])
  end))

  return adapter
end
