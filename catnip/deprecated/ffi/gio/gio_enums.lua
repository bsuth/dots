local ffi = require("ffi")

-- https://docs.gtk.org/gio/enum.BusType.html
-- /usr/include/glib-2.0/gio/gioenums.h

ffi.cdef([[
  typedef enum {
    G_BUS_TYPE_STARTER = -1,
    G_BUS_TYPE_NONE = 0,
    G_BUS_TYPE_SYSTEM  = 1,
    G_BUS_TYPE_SESSION = 2
  } GBusType;
]])

-- https://docs.gtk.org/gio/flags.DBusCallFlags.html
-- /usr/include/glib-2.0/gio/gioenums.h

ffi.cdef([[
  typedef enum {
    G_DBUS_CALL_FLAGS_NONE = 0,
    G_DBUS_CALL_FLAGS_NO_AUTO_START = (1<<0),
    G_DBUS_CALL_FLAGS_ALLOW_INTERACTIVE_AUTHORIZATION = (1<<1)
  } GDBusCallFlags;
]])

-- https://docs.gtk.org/gio/flags.DBusSignalFlags.html
-- /usr/include/glib-2.0/gio/gioenums.h

ffi.cdef([[
  typedef enum {
    G_DBUS_SIGNAL_FLAGS_NONE = 0,
    G_DBUS_SIGNAL_FLAGS_NO_MATCH_RULE = (1<<0),
    G_DBUS_SIGNAL_FLAGS_MATCH_ARG0_NAMESPACE = (1<<1),
    G_DBUS_SIGNAL_FLAGS_MATCH_ARG0_PATH = (1<<2)
  } GDBusSignalFlags;
]])
