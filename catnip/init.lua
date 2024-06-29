local uv = require('luv')
local catnip = require('catnip')
local key = require('key')
local glib = require('ffi.glib')

require('desktop')

key.release({ 'mod1' }, 'c', function() require('keylog'):toggle() end)

-- -----------------------------------------------------------------------------
-- Main Loop Integrations
-- -----------------------------------------------------------------------------

local function g_main_iteration()
  glib.g_main_context_iteration(nil, false)
end

-- Force prevent JIT compiling, since the LuaJIT interpreter cannot detect that
-- `g_main_context_iteration` may call back into Lua (since it only occasionally
-- calls back into Lua). See http://luajit.org/ext_ffi_semantics.html#callback
-- for details.
jit.off(g_main_iteration)

catnip.subscribe('tick', function()
  uv.run('nowait')
  g_main_iteration()
end)

-- -----------------------------------------------------------------------------
-- System
-- -----------------------------------------------------------------------------

key.release({ 'mod1', 'ctrl' }, 'r', catnip.reload)
key.release({ 'mod1', 'ctrl' }, 'q', catnip.quit)

key.release({ 'mod1' }, 'q', function()
  if catnip.focused == nil then return end
  catnip.focused:destroy()
end)

-- -----------------------------------------------------------------------------
-- Spawn
-- -----------------------------------------------------------------------------

key.release({ 'mod1' }, 'space', function()
  os.execute('foot & disown')
end)

-- -----------------------------------------------------------------------------
-- Test
-- -----------------------------------------------------------------------------
