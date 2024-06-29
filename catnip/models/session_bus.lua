local ffi = require('ffi')
local gobject = require('ffi.gobject')
local gio = require('ffi.gio')

return ffi.gc(gio.g_bus_get_sync(gio.G_BUS_TYPE_SESSION, nil, nil), function(session_bus)
  gobject.g_object_unref(ffi.cast('GObject*', session_bus))
end)
