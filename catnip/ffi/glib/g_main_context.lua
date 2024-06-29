local ffi = require("ffi")

-- https://docs.gtk.org/glib/struct.MainContext.html
-- /usr/include/glib-2.0/glib/gmain.h

ffi.cdef([[
  typedef struct {} GMainContext;

  gboolean g_main_context_iteration(GMainContext* context, gboolean may_block);
]])
