local uv = require('luv')
local catnip = require('catnip')
local catmint = require('utils.catmint')
local keymap = require('keymap')

require('desktop')
require('wallpaper')
require('bar')

catnip.subscribe('tick', function()
  uv.run('nowait')
end)

-- -----------------------------------------------------------------------------
-- System
-- -----------------------------------------------------------------------------

keymap({ 'mod1', 'ctrl' }, 'r', catnip.reload)
keymap({ 'mod1', 'ctrl' }, 'q', catnip.quit)

keymap({ 'mod1' }, 'q', function()
  local focused_window = catmint.get_focused_window()
  if focused_window == nil then return end
  focused_window:destroy()
end)

-- -----------------------------------------------------------------------------
-- Spawn
-- -----------------------------------------------------------------------------

keymap({ 'mod1' }, 'space', function()
  os.execute('foot & disown')
end)
