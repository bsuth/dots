local uv = require('luv')
local catnip = require('catnip')
local keymap = require('keymap')

require('canvas')
require('dump')
require('wallpaper')
require('bar')

keymap({ 'mod1', 'ctrl' }, 'r', catnip.reload)
keymap({ 'mod1', 'ctrl' }, 'q', catnip.quit)

-- -----------------------------------------------------------------------------
-- LibUV
-- -----------------------------------------------------------------------------

catnip.subscribe('tick', function()
  uv.run('nowait')
end)
