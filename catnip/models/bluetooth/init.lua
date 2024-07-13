local dbus = require('lib.dbus')
local system_bus = require('models.system_bus')
local Adapter = require('models.bluetooth.adapter')

-- -----------------------------------------------------------------------------
-- Model
-- -----------------------------------------------------------------------------

---@class Bluetooth (BlueZ)
---@field adapter? BluetoothAdapter
local bluetooth = {
  adapter = nil,
}

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

---@param object_path string
---@param adapter_managed_object table
function bluetooth:connect(object_path, adapter_managed_object)
  if bluetooth.adapter ~= nil then
    bluetooth.adapter:destroy()
  end

  bluetooth.adapter = Adapter(object_path, adapter_managed_object)
end

function bluetooth:disconnect()
  if bluetooth.adapter ~= nil then
    bluetooth.adapter:destroy()
  end

  bluetooth.adapter = nil
end

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

dbus.call({
  connection = system_bus,
  bus_name = 'org.bluez',
  object_path = '/',
  interface_name = 'org.freedesktop.DBus.ObjectManager',
  method_name = 'GetManagedObjects',
}, function(response)
  for object_path, managed_object in pairs(response[1]) do
    if managed_object['org.bluez.Adapter1'] ~= nil then
      bluetooth:connect(object_path, managed_object['org.bluez.Adapter1'])
    end
  end
end)

dbus.subscribe({
  connection = system_bus,
  object_path = '/',
  interface_name = 'org.freedesktop.DBus.ObjectManager',
  signal_name = 'InterfacesAdded',
}, function(response)
  if bluetooth.adapter ~= nil then
    return
  end

  if response[2]['org.bluez.Adapter1'] ~= nil then
    bluetooth:connect(response[1], response[2]['org.bluez.Adapter1'])
  end
end)

dbus.subscribe({
  connection = system_bus,
  object_path = '/',
  interface_name = 'org.freedesktop.DBus.ObjectManager',
  signal_name = 'InterfacesRemoved',
}, function(response)
  if bluetooth.adapter == nil or bluetooth.adapter.object_path ~= response[1] then
    return
  end

  for _, removed_interface in ipairs(response[2]) do
    if removed_interface == 'org.bluez.Adapter1' then
      bluetooth:disconnect()
    end
  end
end)

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return bluetooth
