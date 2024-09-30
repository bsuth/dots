local ffi = require("ffi")

-- https://docs.gtk.org/glib/struct.Error.html
-- /usr/include/glib-2.0/glib/gerror.h

ffi.cdef([[
typedef struct {} GError;
]])
