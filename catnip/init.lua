require('utils.stdlib').load()

local catnip = require('catnip')
local keymap = require('keymap')

require('canvas')
require('dump')
require('wallpaper')
require('windows')

keymap({ 'alt' }, 'r', function()
  catnip.reload()
end)

keymap({ 'alt' }, 'q', function()
  catnip.quit()
end)
