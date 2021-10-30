local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

local Dmenu = require('navbar.dmenu')
local Statusbar = require('navbar.statusbar')
local Tabs = require('navbar.tabs')

-- -----------------------------------------------------------------------------
-- Constants
-- -----------------------------------------------------------------------------

local NAVBAR_HEIGHT = 50

-- -----------------------------------------------------------------------------
-- Navbar
-- -----------------------------------------------------------------------------

local Navbar = setmetatable({}, {
  __call = function(self, screen)
    local newNavbar = setmetatable({
      screen = screen,
      wibar = awful.wibar({
        screen = screen,
        position = 'top',

        width = screen.geometry.width - 4 * beautiful.useless_gap,
        height = NAVBAR_HEIGHT,

        bg = beautiful.colors.transparent,
        type = 'dock', -- remove box shadows
      }),
    }, {
      __index = self,
    })

    newNavbar.dmenu = Dmenu(newNavbar)
    newNavbar.statusbar = Statusbar(newNavbar)
    newNavbar.tabs = Tabs(newNavbar, screen)
    newNavbar:setMode('tabs')

    newNavbar.wibar:setup({
      {
        {
          {
            {
              newNavbar.dmenu.widget,
              newNavbar.statusbar.widget,
              newNavbar.tabs.widget,
              layout = wibox.layout.stack,
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

    return newNavbar
  end,
})

function Navbar:setMode(newMode)
  self.dmenu.widget.visible = false
  self.statusbar.widget.visible = false
  self.tabs.widget.visible = false

  if newMode == 'dmenu' then
    self.dmenu.widget.visible = true
    self.dmenu.prompt:run()
  elseif newMode == 'statusbar' then
    self.statusbar.widget.visible = true
    self.statusbar.keygrabber:start()
  elseif newMode == 'tabs' then
    self.tabs.widget.visible = true
  end
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return Navbar
