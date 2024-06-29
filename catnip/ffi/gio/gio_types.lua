local ffi = require("ffi")

-- https://docs.gtk.org/gio/index.html#classes
-- /usr/include/glib-2.0/gio/giotypes.h

ffi.cdef([[
typedef struct {} GAsyncResult;
typedef struct {} GCancellable;
]])

-- https://docs.gtk.org/gio/index.html#callbacks
-- /usr/include/glib-2.0/gio/giotypes.h

ffi.cdef([[
typedef void (*GAsyncReadyCallback) (GObject *source_object, GAsyncResult *res, gpointer data);
]])
