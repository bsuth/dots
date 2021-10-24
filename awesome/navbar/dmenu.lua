local awful = require('awful')
local wibox = require('wibox')

-- -----------------------------------------------------------------------------
-- Commands
-- -----------------------------------------------------------------------------

local DMENU_COMMANDS = {
  flameshot = function()
    awful.spawn('flameshot gui')
  end,
  gpick = function()
    awful.spawn.with_shell('gpick -s -o | tr -d "\n" | xclip -sel c')
  end,
  inkscape = function()
    awful.spawn('inkscape')
  end,
  reboot = function()
    awful.spawn('reboot')
  end,
  simplescreenrecorder = function()
    awful.spawn('simplescreenrecorder')
  end,
  sleep = function()
    awful.spawn('systemctl suspend')
  end,
  term = function()
    awful.spawn('st -e nvim -c ":Dirvish"')
  end,
  poweroff = function()
    awful.spawn('poweroff')
  end,
  vivaldi = function()
    awful.spawn('vivaldi-stable')
  end,
}

local DMENU_COMMAND_KEYS = {}
for key, _ in pairs(DMENU_COMMANDS) do
  DMENU_COMMAND_KEYS[#DMENU_COMMAND_KEYS + 1] = key
end

-- -----------------------------------------------------------------------------
-- Dmenu
-- -----------------------------------------------------------------------------

local Dmenu = setmetatable({}, {
  __call = function(self, navbar)
    local prompt = awful.widget.prompt({
      prompt = '',
      font = 'Fredoka One 14',
      completion_callback = function(currentCmd, cursorPos, nComp)
        return awful.completion.generic(
          currentCmd,
          cursorPos,
          nComp,
          DMENU_COMMAND_KEYS
        )
      end,
      exe_callback = function(cmd)
        if type(DMENU_COMMANDS[cmd]) == 'function' then
          DMENU_COMMANDS[cmd]()
        end
      end,
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
