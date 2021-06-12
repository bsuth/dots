local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local layout = require('layout')
local wibox = require('wibox')

--
-- TagTabber
--

local config = {
  height = 40,
  margins = { x = 60, y = 20 },
}

local TagTabber = {
  screen = nil,
  tabsWidget = nil,
  wibox = nil,
}

--
-- TagTab
--

local function TagTab(active)
  local theme = beautiful.colors.purple
  local markup = active
      and ('<span foreground="%s">Test</span>'):format(theme)
    or 'test'

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

function TagTabber:refresh()
  local tabChildren = {}

  for _, tag in ipairs(self.screen.tags) do
    table.insert(tabChildren, TagTab(tag == self.screen.selected_tag))
  end

  self.tabsWidget.children = tabChildren
end

function TagTabber:toggle()
  self:refresh()
  self.wibox.visible = not self.wibox.visible
end

--
-- Constructor
--

return setmetatable({}, {
  __call = function(self, screen)
    local newTagTabber = {
      screen = screen,

      tabsWidget = wibox.widget({
        TagTab(true),
        TagTab(),
        TagTab(),
        TagTab(),
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

    newTagTabber.wibox:setup({
      {
        layout.center(newTagTabber.tabsWidget),
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
      newTagTabber:refresh()
    end)

    return setmetatable(newTagTabber, { __index = TagTabber })
  end,
})
