local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

--
-- Navbar
--

local navbar = {
  height = 50,
  screen = nil,
  wibar = nil,
  tabsWidget = nil,
  dmenuWidget = nil,
}

--
-- TabWidget
--

local function TabWidget(name, active, prompt)
  local activeColor = beautiful.colors.white
  local inactiveColor = beautiful.colors.dark_grey

  name = name or 'Tab'
  local markup = ('<span foreground="%s">%s</span>'):format(
    active and activeColor or inactiveColor,
    name
  )

  return wibox.widget({
    {
      prompt or {
        markup = markup,
        halign = 'center',
        valign = 'center',
        font = 'Fredoka One 14',
        forced_height = navbar.height,
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

function navbar:newTag()
  awful.tag.add(tostring(#self.screen.tags), {
    layout = awful.layout.layouts[1],
    screen = self.screen,
  }):view_only()
end

function navbar:closeTag()
  if #self.screen.tags > 1 then
    self.screen.selected_tag:delete()
  end
end

function navbar:focusTag(relidx)
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

function navbar:nextTag()
  self:focusTag(1)
end

function navbar:prevTag()
  self:focusTag(-1)
end

function navbar:refresh(opts)
  opts = opts or {}

  if opts.mode == 'dmenu' then
    self.prompt.exe_callback = awful.spawn

    self.dmenuWidget.children = {
      wibox.widget({
        markup = '➜ ',
        font = 'Fredoka One 14',
        align  = 'center',
        valign = 'center',
        widget = wibox.widget.textbox,
      }),
      self.prompt,
    }

    self.tabsWidget.visible = false
    self.dmenuWidget.visible = true
    self.prompt:run()
  else
    local tabChildren = {}
    for _, tag in ipairs(self.screen.tags) do
      if not tag.name:match('^_') then
        table.insert(
          tabChildren,
          TabWidget(
            tag.name,
            tag == self.screen.selected_tag,
            tag == opts.renameTag and self.prompt.widget
          )
        )
      end
    end
    self.tabsWidget.children = tabChildren

    self.prompt.exe_callback = function(name)
      self.screen.selected_tag.name = name
    end

    self.dmenuWidget.visible = false
    self.tabsWidget.visible = true 
  end
end

function navbar:renameTag()
  self.prompt:run()
  self:refresh({ renameTag = self.screen.selected_tag })
end

--
-- Functions
--

function navbar.new(screen)
  local newnavbar = {
    screen = screen,
    wibar = awful.wibar({
      screen = screen,
      position = 'top',

      width = screen.geometry.width - 4 * beautiful.useless_gap,
      height = navbar.height,

      bg = beautiful.colors.transparent,
      type = 'dock', -- remove box shadows
    }),
    tabsWidget = wibox.widget({
      layout = wibox.layout.fixed.horizontal,
    }),
    dmenuWidget = wibox.widget({
      visible = false,
      layout = wibox.layout.fixed.horizontal,
    }),
  }

  newnavbar.prompt = awful.widget.prompt({
    prompt = '',
    font = 'Fredoka One 14',
    done_callback = function()
      newnavbar:refresh()
    end,
  })

  newnavbar.wibar:setup({
    {
      {
        {
          {
            newnavbar.dmenuWidget,
            newnavbar.tabsWidget,
            layout = wibox.layout.stack
          },
          halign = 'center',
          valign = 'center',
          widget = wibox.container.place,
        },
        margins = 10,
        widget = wibox.container.margin,
      },

      shape = gears.shape.rectangle,
      shape_border_width = 2,
      shape_border_color = beautiful.colors.dark_grey,

      bg = beautiful.colors.black,
      widget = wibox.container.background,
    },
    top = 10,
    widget = wibox.container.margin,
  })

  screen:connect_signal('tag::history::update', function()
    newnavbar:refresh()
  end)

  return setmetatable(newnavbar, { __index = navbar })
end

--
-- Return
--

return navbar
