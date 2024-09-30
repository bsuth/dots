local catnip = require('catnip')
local glib = require('ffi.glib')

local function g_main_iteration()
  glib.g_main_context_iteration(nil, false)
end

-- Force prevent JIT compiling, since the LuaJIT interpreter cannot detect that
-- `g_main_context_iteration` may call back into Lua (since it only occasionally
-- calls back into Lua). See http://luajit.org/ext_ffi_semantics.html#callback
-- for details.
jit.off(g_main_iteration)

catnip.subscribe('tick', function()
  g_main_iteration()
end)
