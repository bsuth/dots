local uv = require('luv')
local catnip = require('catnip')
local key = require('key')
local glib = require('ffi.glib')
local dbus = require('lib.dbus')

require('desktop')

key.release({ 'mod1' }, 'c', function() require('keylog'):toggle() end)

catnip.subscribe('tick', function()
  uv.run('nowait')

  -- TODO: For some reason, `g_main_context_iteration` must be wrapped as the
  -- return of a newly created IIFE, otherwise LuaJIT throws with
  -- `PANIC: unprotected error in call to Lua API (bad callback)`.
  --
  -- Possibly helpful: http://luajit.org/ext_ffi_semantics.html#callback
  -- Need to prevent something from being JIT compiled?
  local iterate = function() return glib.g_main_context_iteration(nil, false) end
  iterate()
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

dbus.system:subscribe({}, function(signal)
  print(require('inspect')(signal))
end)
