local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local layout = require('layout')
local prompt = require('prompt')
local wibox = require('wibox')

--
-- TagTabs
--

local config = {
  height = 40,
  margins = { x = 60, y = 20 },
}

local TagTabs = {
  screen = nil,
  tabsWidget = nil,
  wibox = nil,
}

--
-- TabWidget
--

local function TabWidget(name, active)
  local theme = beautiful.colors.green
  name = name or 'Tab'
  local markup = active
      and ('<span foreground="%s">%s</span>'):format(theme, name)
    or name

  return wibox.widget({
    {
      {
        markup = markup,
        halign = 'center',
        valign = 'center',
        forced_height = config.height,
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
      local rgb = beautiful.hex2rgb(theme)
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

function TagTabs:toggle()
  self:refresh()
  self.wibox.visible = not self.wibox.visible
end

--
-- Constructor
--

return setmetatable({}, {
  __call = function(self, screen)
    local newTagTabs = {
      screen = screen,

      tabsWidget = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
      }),

      wibox = wibox({
        screen = screen,
        ontop = true,
        visible = false,

        x = screen.geometry.x + config.margins.x,
        y = screen.geometry.y + config.margins.y,
        width = screen.geometry.width - 2 * config.margins.x,
        height = config.height,

        bg = beautiful.colors.transparent,
        type = 'dock', -- remove box shadows
      }),
    }

    newTagTabs.wibox:setup({
      {
        layout.center(newTagTabs.tabsWidget),
        margins = 10,
        widget = wibox.container.margin,
      },

      shape_border_width = 2,
      shape_border_color = beautiful.colors.white,
      bg = beautiful.colors.blacker,
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 50)
      end,

      widget = wibox.container.background,
    })

    screen:connect_signal('tag::history::update', function()
      newTagTabs:refresh()
    end)

    return setmetatable(newTagTabs, { __index = TagTabs })
  end,
})
