local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')
local layouts = require('layouts')

local TAGBAR_HEIGHT = 48
local TAGBAR_FONT = 'Quicksand Regular 14'

-- -----------------------------------------------------------------------------
-- Components
-- -----------------------------------------------------------------------------

local function Tab(opts)
  return wibox.widget({
    {
      opts.widget or {
        text = opts.name,
        halign = 'center',
        valign = 'center',
        font = TAGBAR_FONT,
        widget = wibox.widget.textbox,
      },
      widget = wibox.container.place,
    },
    fg = opts.isBackgroundTab and '#888888' or beautiful.white,
    bg = opts.active and beautiful.lightGray or beautiful.darkGray,
    widget = wibox.container.background,
  })
end

-- -----------------------------------------------------------------------------
-- Tagbar
-- -----------------------------------------------------------------------------

local Tagbar = {}

function Tagbar:newTab()
  awful.tag.add(tostring(#self.screen.tags), {
    layout = self.screen.geometry.width > self.screen.geometry.height and layouts[1] or layouts[2],
    screen = self.screen,
  }):view_only()
end

function Tagbar:closeTab()
  local numVisibleTags = 0

  for _, tag in ipairs(self.screen.tags) do
    if not tag.name:match('^_') then
      numVisibleTags = numVisibleTags + 1
    end
  end

  if numVisibleTags > 1 then
    self.screen.selected_tag:delete()
  end
end

function Tagbar:toggleBackgroundTab()
  local tag = self.screen.selected_tag
  tag.isInTagbarBackground = not tag.isInTagbarBackground
  self:refresh()
end

function Tagbar:renameTab()
  self.renamePrompt:run()
  self:refresh({ renameTag = self.screen.selected_tag })
end

function Tagbar:shiftTab(relidx)
  local currentTag = self.screen.selected_tag

  local limit = relidx > 0 and #self.screen.tags or 0
  for i = currentTag.index + relidx, limit, relidx do
    local swapTag = self.screen.tags[i]
    if swapTag and not swapTag.name:match('^_.*') then
      currentTag:swap(swapTag)
      self:refresh()
      break
    end
  end
end

function Tagbar:focusTab(relidx, iterateBackgroundTags)
  local newTagIndex = self.screen.selected_tag.index
  local numTags = #self.screen.tags

  for i = 1, numTags do -- limit iterations
    if relidx > 0 then
      newTagIndex = newTagIndex < numTags and newTagIndex + 1 or 1
    else
      newTagIndex = newTagIndex > 1 and newTagIndex - 1 or numTags
    end

    local newTag = self.screen.tags[newTagIndex]

    if iterateBackgroundTags or not newTag.isInTagbarBackground then
      -- Do not match private tags (ex. client buffer)
      if not newTag.name:match('^_.*') then
        newTag:view_only()
        break
      end
    end
  end
end

function Tagbar:refresh(opts)
  local children = {}

  for _, tag in pairs(self.screen.tags) do
    if not tag.name:match('^_') then
      local isRename = opts and opts.renameTag == tag
      children[#children + 1] = Tab({
        name = tag.name,
        active = tag == self.screen.selected_tag,
        isBackgroundTab = tag.isInTagbarBackground,
        widget = isRename and self.renamePrompt,
      })
    end
  end

  self.tabListWidget.children = children
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return function(screen)
  local tagbar = {
    screen = screen,
    tabListWidget = wibox.widget({
      forced_width = screen.geometry.width,
      layout  = wibox.layout.flex.horizontal,
    }),
    renamePrompt = awful.widget.prompt({
      prompt = '',
      font = TAGBAR_FONT,
      fg = beautiful.white,
      exe_callback = function(name)
        screen.selected_tag.name = name
      end,
    }),
    wibar = awful.wibar({
      screen = screen,
      position = 'top',
      bg = beautiful.darkGray,
      height = TAGBAR_HEIGHT,
      type = 'dock', -- remove box shadows
    }),
  }

  tagbar.wibar.widget = tagbar.tabListWidget

  tagbar.renamePrompt.done_callback = function(name)
    tagbar:refresh()
  end

  screen:connect_signal('tag::history::update', function()
    tagbar:refresh()
  end)

  return setmetatable(tagbar, { __index = Tagbar })
end
