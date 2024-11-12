local catnip = require('catnip')

require('window_manager')
require('widget')

-- -----------------------------------------------------------------------------
-- Main Loop
-- -----------------------------------------------------------------------------

-- catnip.on('tick', function()
--   require('luv').run('nowait')
-- end)

-- -----------------------------------------------------------------------------
-- System
-- -----------------------------------------------------------------------------

catnip.bind({ 'mod1' }, 'space', function()
  os.execute('foot & disown')
end)

catnip.bind({ 'mod1' }, 'q', function()
  if catnip.focused ~= nil then
    catnip.focused:destroy()
  end
end)
