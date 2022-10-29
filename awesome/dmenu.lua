local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local cjson = require('cjson')

-- -----------------------------------------------------------------------------
-- State / Config
-- -----------------------------------------------------------------------------

local DMENU_WIDTH = 400
local DMENU_PAGE_SIZE = 5

local dmenuConfig = {}
local dmenuCommands = {}
local filteredCommands = {}
local itemIndexOffset = 1
local selectedItemIndex = 1
local promptValue = ''

-- -----------------------------------------------------------------------------
-- Components
-- -----------------------------------------------------------------------------

local function DmenuItemWidget(widget, selected)
  return wibox.widget({
    {
      widget,
      margins = 16,
      widget = wibox.container.margin,
    },
    fg = beautiful.white,
    bg = selected and beautiful.lightGray or beautiful.darkGray,
    forced_width = DMENU_WIDTH,
    widget = wibox.container.background,
  })
end

-- -----------------------------------------------------------------------------
-- Widgets
-- -----------------------------------------------------------------------------

local dmenuItemList = wibox.widget({
  layout = wibox.layout.fixed.vertical,
})

dmenuItemList:connect_signal('request::rerender', function()
  dmenuItemList.children = {}

  local itemIndexLimit = math.min(
    #filteredCommands,
    itemIndexOffset + DMENU_PAGE_SIZE - 1
  )

  for i = itemIndexOffset, itemIndexLimit do
    local command = filteredCommands[i]
    local markup = command

    if #promptValue > 0 then
      local matchStart, matchEnd = command:find(promptValue)
      markup = table.concat({
        command:sub(1, matchStart - 1),
        ('<span color="%s">%s</span>'):format(beautiful.cyan, promptValue),
        command:sub(matchEnd + 1),
      })
    end

    dmenuItemList.children[#dmenuItemList.children + 1] = DmenuItemWidget({
      markup = markup,
      widget = wibox.widget.textbox,
    }, i == selectedItemIndex)
  end
end)

local prompt = awful.widget.prompt({
  prompt = '',
  fg = beautiful.white,
  changed_callback = function(newPromptValue)
    -- Need to explicitly check if the prompt _actually_ changed, since
    -- changed_callback also fires on just modifier keypresses.
    if newPromptValue ~= promptValue then
      filteredCommands = {}

      for i, command in ipairs(dmenuCommands) do
        if command:find(newPromptValue) then
          table.insert(filteredCommands, command)
        end
      end

      itemIndexOffset = math.max(1, #filteredCommands - DMENU_PAGE_SIZE + 1)
      selectedItemIndex = #filteredCommands
      promptValue = newPromptValue
      dmenuItemList:emit_signal('request::rerender')
    end
  end,
  exe_callback = function(command)
    local command = filteredCommands[selectedItemIndex]
    if dmenuConfig[command] and dmenuConfig[command].exec then
      if dmenuConfig[command].with_shell then
        awful.spawn.with_shell(dmenuConfig[command].exec)
      else
        awful.spawn(dmenuConfig[command].exec)
      end
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
      {
        dmenuItemList,
        DmenuItemWidget({
          {
            markup = '➜ ',
            widget = wibox.widget.textbox,
          },
          prompt,
          layout = wibox.layout.fixed.horizontal,
        }),
        layout = wibox.layout.fixed.vertical,
      },
      shape_border_width = 1,
      shape_border_color = beautiful.cyan,
      bg = beautiful.darkGray,
      widget = wibox.container.background,
    },
    margins = 16,
    widget = wibox.container.margin,
  },
  placement = awful.placement.bottom_right,
  bg = beautiful.transparent,
  visible = false,
  ontop = true,
  type = 'dock',
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
    dmenuConfig = {}
    dmenuCommands = {}

    local dmenuConfigFile = io.open(os.getenv('DOTS') .. '/awesome/dmenu.json')
    if dmenuConfigFile then
      dmenuConfig = cjson.decode(dmenuConfigFile:read('*a'))
      dmenuCommands = {}

      for key, _ in pairs(dmenuConfig) do
        table.insert(dmenuCommands, key)
      end

      dmenuConfigFile:close()
    end

    filteredCommands = dmenuCommands
    itemIndexOffset = math.max(1, #filteredCommands - DMENU_PAGE_SIZE + 1)
    selectedItemIndex = #filteredCommands
    promptValue = ''
    dmenuItemList:emit_signal('request::rerender')

    popup.screen = awful.screen.focused()
    prompt:run()
    popup.visible = true
  end
end
