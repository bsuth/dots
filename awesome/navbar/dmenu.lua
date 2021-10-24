local awful = require('awful')
local wibox = require('wibox')

-- -----------------------------------------------------------------------------
-- Dmenu
-- -----------------------------------------------------------------------------

local Dmenu = setmetatable({}, {
  __call = function(self, navbar)
    local prompt = awful.widget.prompt({
      prompt = '',
      font = 'Fredoka One 14',
      exe_callback = awful.spawn,
      done_callback = function()
        navbar:setMode('tabs')
      end,
    })

    return setmetatable({
      navbar = navbar,
      prompt = prompt,
      widget = wibox.widget({
        {
          markup = '➜ ',
          font = 'Fredoka One 14',
          align = 'center',
          valign = 'center',
          widget = wibox.widget.textbox,
        },
        prompt,
        layout = wibox.layout.fixed.horizontal,
      }),
    }, {
      __index = self,
    })
  end,
})

function Dmenu:run()
  self.prompt:run()
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return Dmenu
