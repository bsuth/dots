local ffi = require('ffi')
local glib = require('ffi.glib')
local gio = require('ffi.gio')
local g_variant = require('lib.g_variant')

local M = {}

-- -----------------------------------------------------------------------------
-- Types
-- -----------------------------------------------------------------------------

---@class DBusCallArgs
---@field connection ffi.cdata*
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
---@field connection ffi.cdata*
---@field object_path? string
---@field interface_name? string
---@field signal_name? string
---@field sender_name? string
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
-- API
-- -----------------------------------------------------------------------------

---@param args DBusCallArgs
---@param callback? fun(result: any)
function M.call(args, callback)
  local parameters_g_variant = (args.parameters_type ~= nil and args.parameters ~= nil)
      and g_variant.from_lua(args.parameters_type, args.parameters)
      or nil

  local reply_g_variant_type = args.reply_type ~= nil
      and ffi.gc(glib.g_variant_type_new(args.reply_type), glib.g_variant_type_free)
      or nil

  local g_async_ready_callback = function(_, result, _)
    if callback == nil then
      return
    end

    local reply_g_variant = gio.g_dbus_connection_call_finish(args.connection, result, nil)
    local reply_lua = nil

    if reply_g_variant ~= nil then
      reply_lua = g_variant.to_lua(reply_g_variant)
      glib.g_variant_unref(reply_g_variant)
    end

    callback(reply_lua)
  end

  gio.g_dbus_connection_call(
    args.connection,
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
end

---@param args DBusCallArgs
---@return any
function M.call_sync(args)
  local parameters_g_variant = (args.parameters_type ~= nil and args.parameters ~= nil)
      and g_variant.from_lua(args.parameters_type, args.parameters)
      or nil

  local reply_g_variant_type = args.reply_type ~= nil
      and ffi.gc(glib.g_variant_type_new(args.reply_type), glib.g_variant_type_free)
      or nil

  local reply_g_variant = gio.g_dbus_connection_call_sync(
    args.connection,
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

  local reply_lua = nil

  if reply_g_variant ~= nil then
    reply_lua = g_variant.to_lua(reply_g_variant)
    glib.g_variant_unref(reply_g_variant)
  end

  return reply_lua
end

---@param args DBusSubscriptionArgs
---@param callback fun(signal: DBusSignal)
---@return number
function M.subscribe(args, callback)
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
    args.connection,
    args.sender_name,
    args.interface_name,
    args.signal_name,
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
function M.unsubscribe(connection, subscription_id)
  gio.g_dbus_connection_signal_unsubscribe(connection, subscription_id)
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return M
