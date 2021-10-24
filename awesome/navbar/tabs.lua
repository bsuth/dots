local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')

-- -----------------------------------------------------------------------------
-- Constants
-- -----------------------------------------------------------------------------

local TAB_HEIGHT = 50
local ACTIVE_TAB_COLOR = beautiful.colors.white
local INACTIVE_TAB_COLOR = beautiful.colors.dark_grey

-- -----------------------------------------------------------------------------
-- Tab
-- -----------------------------------------------------------------------------

local function Tab(opts)
  return wibox.widget({
    {
      opts.content or {
        markup = ('<span foreground="%s">%s</span>'):format(
          opts.active and ACTIVE_TAB_COLOR or INACTIVE_TAB_COLOR,
          opts.name or 'Tab'
        ),
        halign = 'center',
        valign = 'center',
        font = 'Fredoka One 14',
        forced_height = TAB_HEIGHT,
        widget = wibox.widget.textbox,
      },
      left = 20,
      right = 20,
      widget = wibox.container.margin,
    },

    shape = function(cr, width, height)
      if not opts.active then
        return
      end

      local size = 6
      local rgb = beautiful.hex2rgb(ACTIVE_TAB_COLOR)
      cr:set_source_rgb(rgb[1], rgb[2], rgb[3])

      cr:move_to(0, 0)
      cr:line_to(size, 0)
      cr:line_to(0, size)
      cr:fill()

      cr:move_to(width, 0)
      cr:line_to(width - size, 0)
      cr:line_to(width, size)
      cr:fill()

      cr:move_to(0, height)
      cr:line_to(0, height - size)
      cr:line_to(size, height)
      cr:fill()

      cr:move_to(width, height)
      cr:line_to(width - size, height)
      cr:line_to(width, height - size)
      cr:fill()
    end,

    widget = wibox.container.background,
  })
end

-- -----------------------------------------------------------------------------
-- Tabs
-- -----------------------------------------------------------------------------

local Tabs = setmetatable({}, {
  __call = function(self, navbar, screen)
    local newTabs = setmetatable({
      navbar = navbar,
      screen = screen or awful.screen.focused(),
      prompt = awful.widget.prompt({
        prompt = '',
        font = 'Fredoka One 14',
        exe_callback = function(name)
          screen.selected_tag.name = name
        end,
      }),
      widget = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
      }),
    }, {
      __index = self,
    })

    newTabs.prompt.done_callback = function(name)
      newTabs:refresh()
    end

    screen:connect_signal('tag::history::update', function()
      newTabs:refresh()
    end)

    return newTabs
  end,
})

function Tabs:newTab()
  awful.tag.add(tostring(#self.screen.tags), {
    layout = awful.layout.layouts[1],
    screen = self.screen,
  }):view_only()
end

function Tabs:closeTab()
  if #self.screen.tags > 1 then
    self.screen.selected_tag:delete()
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

function Tabs:refresh(opts)
  local children = {}

  for _, tag in pairs(self.screen.tags) do
    if not tag.name:match('^_') then
      local isRename = opts and opts.renameTag == tag

      children[#children + 1] = Tab({
        name = tag.name,
        active = tag == self.screen.selected_tag,
        content = isRename and self.prompt,
      })
    end
  end

  self.widget.children = children
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return Tabs
