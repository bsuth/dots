local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local layout = require('layout')
local prompt = require('prompt')
local wibox = require('wibox')

--
-- TagTabs
--

local TagTabs = {
  height = 40,
  screen = nil,
  backupFileName = '',
  tabsWidget = nil,
  wibar = nil,
}

--
-- TabWidget
--

local function TabWidget(name, active)
  local activeColor = beautiful.colors.white
  local inactiveColor = beautiful.colors.dark_grey

  name = name or 'Tab'
  local markup = ('<span foreground="%s">%s</span>'):format(
    active and activeColor or inactiveColor,
    name
  )

  return wibox.widget({
    {
      {
        markup = markup,
        halign = 'center',
        valign = 'center',
        forced_height = TagTabs.height,
        widget = wibox.widget.textbox,
      },
      left = 20,
      right = 20,
      widget = wibox.container.margin,
    },

    shape = function(cr, width, height)
      if not active then
        return
      end

      local size = 6
      local rgb = beautiful.hex2rgb(activeColor)
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

--
-- Methods
--

function TagTabs:new()
  awful.tag.add(tostring(#self.screen.tags), {
    layout = awful.layout.layouts[1],
    screen = self.screen,
  }):view_only()
end

function TagTabs:close()
  if #self.screen.tags > 1 then
    self.screen.selected_tag:delete()
  end
end

function TagTabs:focus(relidx)
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

function TagTabs:next()
  self:focus(1)
end

function TagTabs:prev()
  self:focus(-1)
end

function TagTabs:refresh()
  local tabChildren = {}

  for _, tag in ipairs(self.screen.tags) do
    if not tag.name:match('^_') then
      table.insert(
        tabChildren,
        TabWidget(tag.name, tag == self.screen.selected_tag)
      )
    end
  end

  self.tabsWidget.children = tabChildren
end

function TagTabs:rename()
  prompt.normal_mode(function(newName)
    self.screen.selected_tag.name = newName
    self:refresh()
  end)
end

--
-- Constructor
--

return setmetatable({}, {
  __call = function(self, screen)
    local newTagTabs = {
      screen = screen,
      backupFileName = '/tmp/tagtabs' .. tostring(screen.index),

      tabsWidget = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
      }),

      wibar = awful.wibar({
        screen = screen,
        position = 'top',

        width = screen.geometry.width - 4 * beautiful.useless_gap,
        height = TagTabs.height,

        bg = beautiful.colors.transparent,
        type = 'dock', -- remove box shadows
      }),
    }

    newTagTabs.wibar:setup({
      {
        layout.center(newTagTabs.tabsWidget),
        margins = 10,
        widget = wibox.container.margin,
      },

      shape = gears.shape.rectangle,
      shape_border_width = 2,
      shape_border_color = beautiful.colors.dark_grey,

      bg = beautiful.colors.black,
      widget = wibox.container.background,
    })

    screen:connect_signal('tag::history::update', function()
      newTagTabs:refresh()
    end)

    return setmetatable(newTagTabs, { __index = TagTabs })
  end,
})
