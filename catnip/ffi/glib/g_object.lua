local ffi = require("ffi")

-- https://docs.gtk.org/gobject/class.Object.html
-- /usr/include/glib-2.0/gobject/gobject.h

ffi.cdef([[
typedef struct {} GObject;

void g_object_unref(GObject* object);
]])
