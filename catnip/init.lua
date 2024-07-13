local uv = require('luv')
local catnip = require('catnip')
local glib = require('ffi.glib')
local keybind = require('lib.keybind')
local watch = require('lib.watch')

require('desktop')

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

keybind.release({ 'mod1', 'ctrl' }, 'r', catnip.reload)
keybind.release({ 'mod1', 'ctrl' }, 'q', catnip.quit)

keybind.release({ 'mod1' }, 'q', function()
  if catnip.focused == nil then return end
  catnip.focused:destroy()
end)

-- -----------------------------------------------------------------------------
-- Spawn
-- -----------------------------------------------------------------------------

keybind.release({ 'mod1' }, 'space', function()
  os.execute('foot & disown')
end)

-- -----------------------------------------------------------------------------
-- Test
-- -----------------------------------------------------------------------------

require('models.battery')
require('models.bluetooth')

local watch_test_counter = 88

keybind.release({ 'mod1' }, 'i', function()
  watch_test_counter = watch_test_counter + 1
end)

watch(
  function()
    return watch_test_counter
  end,
  function(new_watch_test_counter)
    print(new_watch_test_counter)
  end
)
