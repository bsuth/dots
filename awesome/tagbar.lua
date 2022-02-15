local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local tagState = require('tagState')
local wibox = require('wibox')

local TAGBAR_HEIGHT = 50
local TAGBAR_FONT = 'Kalam Bold 14'

-- -----------------------------------------------------------------------------
-- Components
-- -----------------------------------------------------------------------------

local function Tab(opts)
  return wibox.widget({
    {
      bgimage = function(_, cr, width, height)
        if not opts.active then
          return
        end

        local size = 6
        local rgb = beautiful.hex2rgb(beautiful.void)

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
    },
    {
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
      left = 16,
      right = 16,
      forced_height = TAGBAR_HEIGHT,
      widget = wibox.container.margin,
    },
    layout = wibox.layout.stack,
  })
end

-- -----------------------------------------------------------------------------
-- Tagbar
-- -----------------------------------------------------------------------------

local Tagbar = {}

function Tagbar:newTab()
  awful.tag.add(tostring(#self.screen.tags), {
    layout = awful.layout.layouts[1],
    screen = self.screen,
  }):view_only()
end

function Tagbar:closeTab()
  if #self.screen.tags > 1 then
    self.screen.selected_tag:delete()
    tagState:emit_signal('request::backup', self.screen)
  end
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
      tagState:emit_signal('request::backup', self.screen)
      break
    end
  end
end

function Tagbar:focusTab(relidx)
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

function Tagbar:refresh(opts)
  local children = {}

  for _, tag in pairs(self.screen.tags) do
    if not tag.name:match('^_') then
      local isRename = opts and opts.renameTag == tag
      children[#children + 1] = Tab({
        name = tag.name,
        active = tag == self.screen.selected_tag,
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
      layout = wibox.layout.fixed.horizontal,
    }),
    renamePrompt = awful.widget.prompt({
      prompt = '',
      font = TAGBAR_FONT,
      exe_callback = function(name)
        screen.selected_tag.name = name
        tagState:emit_signal('request::backup', screen)
        print('exec')
      end,
    }),
    wibar = awful.wibar({
      screen = screen,
      position = 'top',

      width = screen.geometry.width - 4 * beautiful.useless_gap,
      height = TAGBAR_HEIGHT,

      bg = beautiful.transparent,
      type = 'dock', -- remove box shadows
    }),
  }

  tagbar.renamePrompt.done_callback = function(name)
    tagbar:refresh()
  end

  tagbar.wibar:setup({
    {
      {
        {
          tagbar.tabListWidget,
          layout = wibox.container.place,
        },
        margins = 8,
        widget = wibox.container.margin,
      },
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 2)
      end,
      shape_border_width = 4,
      shape_border_color = beautiful.void,
      bg = beautiful.pale,
      widget = wibox.container.background,
    },
    top = 2 * beautiful.useless_gap,
    widget = wibox.container.margin,
  })

  screen:connect_signal('tag::history::update', function()
    tagbar:refresh()
  end)

  return setmetatable(tagbar, { __index = Tagbar })
end
