local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')

local core = require('navbar.core')
local tags = require('tags')

-- -----------------------------------------------------------------------------
-- Tab
-- -----------------------------------------------------------------------------

local function Tab(args)
  return core.Select({
    active = args.active,
    widget = args.widget or wibox.widget({
      markup = core.markupText(
        args.name or 'Tab',
        args.active and beautiful.colors.white or beautiful.colors.dark_grey
      ),
      halign = 'center',
      valign = 'center',
      font = core.FONT,
      forced_height = core.HEIGHT,
      widget = wibox.widget.textbox,
    }),
  })
end

-- -----------------------------------------------------------------------------
-- Tabs
-- -----------------------------------------------------------------------------

local Tabs = {}
local TabsMT = { __index = Tabs }

function Tabs:newTab()
  awful.tag.add(tostring(#self.screen.tags), {
    layout = awful.layout.layouts[1],
    screen = self.screen,
  }):view_only()
end

function Tabs:closeTab()
  if #self.screen.tags > 1 then
    self.screen.selected_tag:delete()
    tags:emit_signal('request::backup', self.screen)
  end
end

function Tabs:renameTab()
  self.prompt:run()
  self:refresh({ renameTag = self.screen.selected_tag })
end

function Tabs:shiftTab(relidx)
  local currentTag = self.screen.selected_tag

  local limit = relidx > 0 and #self.screen.tags or 0
  for i = currentTag.index + relidx, limit, relidx do
    local swapTag = self.screen.tags[i]
    if swapTag and not swapTag.name:match('^_.*') then
      currentTag:swap(swapTag)
      self:refresh()
      tags:emit_signal('request::backup', self.screen)
      break
    end
  end
end

function Tabs:focusTab(relidx)
  local newTagIndex = self.screen.selected_tag.index
  local numTags = #self.screen.tags

  for i = 1, numTags do -- limit iterations
    if relidx > 0 then
      newTagIndex = newTagIndex < numTags and newTagIndex + 1 or 1
    else
      newTagIndex = newTagIndex > 1 and newTagIndex - 1 or numTags
    end

    local newTag = self.screen.tags[newTagIndex]
    if not newTag.name:match('^_.*') then
      newTag:view_only()
      break
    end
  end
end

function Tabs:refresh(args)
  local children = {}

  for _, tag in pairs(self.screen.tags) do
    if not tag.name:match('^_') then
      local isRename = args and args.renameTag == tag

      children[#children + 1] = Tab({
        name = tag.name,
        active = tag == self.screen.selected_tag,
        widget = isRename and self.prompt,
      })
    end
  end

  self.tabsWidget.children = children
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return function(navbar, screen)
  local newTabs = setmetatable({
    navbar = navbar,
    screen = screen or awful.screen.focused(),

    prompt = awful.widget.prompt({
      prompt = '',
      font = core.FONT,
      exe_callback = function(name)
        screen.selected_tag.name = name
        tags:emit_signal('request::backup', screen)
      end,
    }),

    tabsWidget = wibox.widget({
      layout = wibox.layout.fixed.horizontal,
    }),
  }, TabsMT)

  newTabs.widget = wibox.widget({
    newTabs.tabsWidget,
    layout = wibox.container.place,
  })

  newTabs.prompt.done_callback = function(name)
    newTabs:refresh()
  end

  screen:connect_signal('tag::history::update', function()
    newTabs:refresh()
  end)

  return newTabs
end
