local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

-- -----------------------------------------------------------------------------
-- State / Config
-- -----------------------------------------------------------------------------

local DMENU_WIDTH = 400
local DMENU_SPACING = 8
local DMENU_PAGE_SIZE = 5

local filteredCommands = {}
local itemIndexOffset = 1
local selectedItemIndex = 1

-- -----------------------------------------------------------------------------
-- Commands
-- -----------------------------------------------------------------------------

local DMENU_CONFIG = {
  flameshot = function()
    awful.spawn('flameshot gui')
  end,
  gpick = function()
    awful.spawn.with_shell('gpick -s -o | tr -d "\n" | xclip -sel c')
  end,
  inkscape = function()
    awful.spawn('inkscape')
  end,
  discord = function()
    awful.spawn('discord')
  end,
  reboot = function()
    awful.spawn('/sbin/reboot')
  end,
  simplescreenrecorder = function()
    awful.spawn('simplescreenrecorder')
  end,
  sleep = function()
    awful.spawn('systemctl suspend')
  end,
  poweroff = function()
    awful.spawn('/sbin/poweroff')
  end,
  vivaldi = function()
    awful.spawn('vivaldi-stable')
  end,
}

local DMENU_COMMANDS = {}
for key, _ in pairs(DMENU_CONFIG) do
  DMENU_COMMANDS[#DMENU_COMMANDS + 1] = key
end

-- -----------------------------------------------------------------------------
-- Components
-- -----------------------------------------------------------------------------

local function DmenuItemWidget(widget, selected)
  return wibox.widget({
    {
      widget,
      top = 8,
      bottom = 8,
      left = 16,
      right = 16,
      widget = wibox.container.margin,
    },
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 2)
    end,
    shape_border_width = 4,
    shape_border_color = beautiful.void,
    fg = selected and beautiful.pale or beautiful.void,
    bg = selected and '#2A2520' or beautiful.pale,
    forced_width = DMENU_WIDTH,
    widget = wibox.container.background,
  })
end

-- -----------------------------------------------------------------------------
-- Widgets
-- -----------------------------------------------------------------------------

local dmenuItemList = wibox.widget({
  spacing = DMENU_SPACING,
  layout = wibox.layout.fixed.vertical,
})

dmenuItemList:connect_signal('request::rerender', function()
  dmenuItemList.children = {}

  local itemIndexLimit = math.min(
    #filteredCommands,
    itemIndexOffset + DMENU_PAGE_SIZE - 1
  )

  for i = itemIndexOffset, itemIndexLimit do
    dmenuItemList.children[#dmenuItemList.children + 1] = DmenuItemWidget({
      markup = filteredCommands[i],
      widget = wibox.widget.textbox,
    }, i == selectedItemIndex)
  end
end)

local prompt = awful.widget.prompt({
  prompt = '',
  changed_callback = function(promptValue)
    filteredCommands = {}

    for i, command in ipairs(DMENU_COMMANDS) do
      if command:find(promptValue) then
        filteredCommands[#filteredCommands + 1] = command
      end
    end

    itemIndexOffset = 1
    selectedItemIndex = 1
    dmenuItemList:emit_signal('request::rerender')
  end,
  exe_callback = function(command)
    local command = filteredCommands[selectedItemIndex]
    if type(DMENU_CONFIG[command]) == 'function' then
      DMENU_CONFIG[command]()
    end
  end,
  hooks = {
    {
      {},
      'Tab',
      function()
        -- Disable tab completion
        return true, false
      end,
    },
    {
      { 'Control' },
      'n',
      function(command)
        selectedItemIndex = math.min(#filteredCommands, selectedItemIndex + 1)
        itemIndexOffset = math.max(
          itemIndexOffset,
          selectedItemIndex - DMENU_PAGE_SIZE + 1
        )
        dmenuItemList:emit_signal('request::rerender')
        return true, false
      end,
    },
    {
      { 'Control' },
      'p',
      function(command)
        selectedItemIndex = math.max(1, selectedItemIndex - 1)
        itemIndexOffset = math.min(itemIndexOffset, selectedItemIndex)
        dmenuItemList:emit_signal('request::rerender')
        return true, false
      end,
    },
  },
})

local popup = awful.popup({
  widget = {
    {
      DmenuItemWidget({
        {
          markup = '➜ ',
          widget = wibox.widget.textbox,
        },
        prompt,
        layout = wibox.layout.fixed.horizontal,
      }),
      dmenuItemList,
      spacing = DMENU_SPACING,
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  },
  bg = beautiful.dimmed,
  visible = false,
  ontop = true,
})

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

prompt.done_callback = function()
  popup.visible = false
end

return function()
  if popup.visible == true then
    popup.visible = false
  else
    filteredCommands = DMENU_COMMANDS
    itemIndexOffset = 1
    selectedItemIndex = 1
    dmenuItemList:emit_signal('request::rerender')

    popup.screen = awful.screen.focused()
    popup.minimum_width = popup.screen.geometry.width
    popup.minimum_height = popup.screen.geometry.height
    popup.maximum_width = popup.screen.geometry.width
    popup.maximum_height = popup.screen.geometry.height

    prompt:run()
    popup.visible = true
  end
end
