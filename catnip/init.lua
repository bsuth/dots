local uv = require('luv')
local catnip = require('catnip')
local catmint = require('utils.catmint')
local key = require('key')

require('desktop')

key.release({ 'mod1' }, 'c', function() require('keylog'):toggle() end)

catnip.subscribe('tick', function()
  uv.run('nowait')
end)

-- -----------------------------------------------------------------------------
-- System
-- -----------------------------------------------------------------------------

key.release({ 'mod1', 'ctrl' }, 'r', catnip.reload)
key.release({ 'mod1', 'ctrl' }, 'q', catnip.quit)

key.release({ 'mod1' }, 'q', function()
  local focused_window = catmint.get_focused_window()
  if focused_window == nil then return end
  focused_window:destroy()
end)

-- -----------------------------------------------------------------------------
-- Spawn
-- -----------------------------------------------------------------------------

key.release({ 'mod1' }, 'space', function()
  os.execute('foot & disown')
end)
