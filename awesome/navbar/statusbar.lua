local awful = require('awful')
local wibox = require('wibox')

-- -----------------------------------------------------------------------------
-- Statusbar
-- -----------------------------------------------------------------------------

local Statusbar = setmetatable({}, {
  __call = function(self, navbar)
    return setmetatable({
      navbar = navbar,
      widget = wibox.widget({
        {
          markup = 'Hello world',
          font = 'Fredoka One 14',
          align = 'center',
          valign = 'center',
          widget = wibox.widget.textbox,
        },
        layout = wibox.layout.fixed.horizontal,
      }),
    }, {
      __index = self,
    })
  end,
})

function Statusbar:toggle()
  if self.widget.visible then
    self.navbar:setMode('tabs')
  else
    self.navbar:setMode('statusbar')
  end
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return Statusbar
