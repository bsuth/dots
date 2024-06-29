local ffi = require('ffi')
local glib = require('ffi.glib')
local gio = require('ffi.gio')
local g_variant = require('lib.g_variant')

---@class DBusCallArgs
---@field bus_name string
---@field object_path string
---@field interface_name string
---@field method_name string
---@field parameters_type? string
---@field parameters? table
---@field reply_type? string
---@field flags? number
---@field timeout? number

---@class DBusSubscriptionArgs
---@field sender? string
---@field member? string
---@field object_path? string
---@field interface_name? string
---@field arg0? string
---@field flags? number
---@field timeout? number

---@class DBusSignal
---@field sender_name string
---@field object_path string
---@field interface_name string
---@field signal_name string
---@field parameters any

-- -----------------------------------------------------------------------------
-- DBus
-- -----------------------------------------------------------------------------

local DBus = {}
local DBusMT = { __index = DBus }

---@param args DBusCallArgs
---@return fun(callback: fun(result: any))
function DBus:call(args)
  local callback ---@type fun(result: any) | nil

  local parameters_g_variant = (args.parameters_type ~= nil and args.parameters ~= nil)
      and g_variant.from_lua(args.parameters_type, args.parameters)
      or nil

  local reply_g_variant_type = args.reply_type ~= nil
      and ffi.gc(glib.g_variant_type_new(args.reply_type), glib.g_variant_type_free)
      or nil

  local g_async_ready_callback = function(_, result, _)
    if callback ~= nil then
      local variant = gio.g_dbus_connection_call_finish(self.connection, result, nil)
      local lua_variant = nil

      if variant ~= nil then
        lua_variant = g_variant.to_lua(variant)
        glib.g_variant_unref(variant)
      end

      callback(lua_variant)
    end
  end

  gio.g_dbus_connection_call(
    self.connection,
    args.bus_name,
    args.object_path,
    args.interface_name,
    args.method_name,
    parameters_g_variant,
    reply_g_variant_type,
    args.flags or gio.G_DBUS_CALL_FLAGS_NONE,
    args.timeout or -1,
    nil,
    g_async_ready_callback,
    nil
  )

  return function(new_callback)
    callback = new_callback
  end
end

---@param args DBusCallArgs
---@return any
function DBus:call_sync(args)
  local parameters_g_variant = (args.parameters_type ~= nil and args.parameters ~= nil)
      and g_variant.from_lua(args.parameters_type, args.parameters)
      or nil

  local reply_g_variant_type = args.reply_type ~= nil
      and ffi.gc(glib.g_variant_type_new(args.reply_type), glib.g_variant_type_free)
      or nil

  local variant = gio.g_dbus_connection_call_sync(
    self.connection,
    args.bus_name,
    args.object_path,
    args.interface_name,
    args.method_name,
    parameters_g_variant,
    reply_g_variant_type,
    args.flags or gio.G_DBUS_CALL_FLAGS_NONE, -- TODO: transform?
    args.timeout or -1,
    nil,
    nil
  )

  local lua_variant = nil

  if variant ~= nil then
    lua_variant = g_variant.to_lua(variant)
    glib.g_variant_unref(variant)
  end

  return lua_variant
end

---@param args DBusSubscriptionArgs
---@param callback fun(signal: DBusSignal)
---@return number
function DBus:subscribe(args, callback)
  local g_dbus_signal_callback = function(_, sender_name, object_path, interface_name, signal_name, parameters, _)
    local signal = {
      sender_name = ffi.string(sender_name),
      object_path = ffi.string(object_path),
      interface_name = ffi.string(interface_name),
      signal_name = ffi.string(signal_name),
      parameters = nil,
    }

    if parameters ~= nil then
      signal.parameters = g_variant.to_lua(parameters)
    end

    callback(signal)
  end

  return gio.g_dbus_connection_signal_subscribe(
    self.connection,
    args.sender,
    args.interface_name,
    args.member,
    args.object_path,
    args.arg0,
    args.flags or gio.G_DBUS_SIGNAL_FLAGS_NONE, -- TODO: transform?
    g_dbus_signal_callback,
    nil,
    nil
  )
end

---@param connection ffi.cdata*
---@param subscription_id number
function DBus:unsubscribe(connection, subscription_id)
  gio.g_dbus_connection_signal_unsubscribe(connection, subscription_id)
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

local system_bus = setmetatable({
  connection = gio.g_bus_get_sync(gio.G_BUS_TYPE_SYSTEM, nil, nil)
}, DBusMT)

local session_bus = setmetatable({
  connection = gio.g_bus_get_sync(gio.G_BUS_TYPE_SESSION, nil, nil)
}, DBusMT)

return {
  system = system_bus,
  session = session_bus,
}
