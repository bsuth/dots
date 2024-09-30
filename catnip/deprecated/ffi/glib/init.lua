local ffi = require("ffi")

require('ffi.gobject')
require('ffi.glib.g_types')
require('ffi.glib.g_enums')
require('ffi.glib.g_error')
require('ffi.glib.g_variant_type')
require('ffi.glib.g_variant')
require('ffi.glib.g_variant_builder')
require('ffi.glib.g_main_context')

return ffi.load("libglib-2.0.so");
