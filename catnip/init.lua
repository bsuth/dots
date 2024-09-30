local catnip = require('catnip')
local uv = require('luv')

require('desktop')
require('widget')

-- -----------------------------------------------------------------------------
-- Main Loop
-- -----------------------------------------------------------------------------

catnip.on('tick', function()
  uv.run('nowait')
end)

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
