local awful = require('awful')
local wibox = require('wibox')

local core = require('navbar.core')

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
-- Return
-- -----------------------------------------------------------------------------

return function(navbar)
  local prompt = awful.widget.prompt({
    prompt = '',
    font = core.FONT,
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

  return {
    navbar = navbar,
    prompt = prompt,
    widget = wibox.widget({
      {
        {
          markup = core.markupText('➜ '),
          widget = wibox.widget.textbox,
        },
        prompt,
        layout = wibox.layout.fixed.horizontal,
      },
      widget = wibox.container.place,
    }),
  }
end
