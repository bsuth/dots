local keymap = require('keymap')

require('windows.buffer')
require('windows.manage')
require('windows.tile')

keymap({ 'ctrl' }, 'a', function()
  os.execute("foot & disown")
end)
