local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

local core = require('navbar.core')
local Dmenu = require('navbar.dmenu')
local Statusbar = require('navbar.statusbar')
local Tabs = require('navbar.tabs')

-- -----------------------------------------------------------------------------
-- Navbar
-- -----------------------------------------------------------------------------

local Navbar = {}
local NavbarMT = { __index = Navbar }

function Navbar:setMode(newMode)
  self.dmenu.widget.visible = false
  self.statusbar.widget.visible = false
  self.tabs.widget.visible = false

  if newMode == 'dmenu' then
    self.dmenu.widget.visible = true
    self.dmenu.prompt:run()
  elseif newMode == 'statusbar' then
    self.statusbar:refresh()
    self.statusbar.widget.visible = true
    self.statusbar.keygrabber:start()
  elseif newMode == 'tabs' then
    self.tabs.widget.visible = true
  end
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return function(screen)
  local newNavbar = setmetatable({
    screen = screen,
    wibar = awful.wibar({
      screen = screen,
      position = 'top',

      width = screen.geometry.width - 4 * beautiful.useless_gap,
      height = core.HEIGHT,

      bg = beautiful.transparent,
      type = 'dock', -- remove box shadows
    }),
  }, NavbarMT)

  newNavbar.dmenu = Dmenu(newNavbar)
  newNavbar.statusbar = Statusbar(newNavbar)
  newNavbar.tabs = Tabs(newNavbar, screen)
  newNavbar:setMode('tabs')

  newNavbar.wibar:setup({
    {
      {
        {
          newNavbar.dmenu.widget,
          newNavbar.statusbar.widget,
          newNavbar.tabs.widget,
          layout = wibox.layout.stack,
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

  return newNavbar
end
