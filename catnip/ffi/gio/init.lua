local ffi = require("ffi")

require('ffi.gio.gio_types')
require('ffi.gio.gio_enums')
require('ffi.gio.g_dbus_connection')

return ffi.load("libgio-2.0.so")
