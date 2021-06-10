local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

-- -----------------------------------------------------------------------------
-- CONSTANTS / CONFIG
-- -----------------------------------------------------------------------------

local config = {}
lskdjf

-- -----------------------------------------------------------------------------
-- TAGLIST
-- -----------------------------------------------------------------------------

return {
  attach = function(s)
    s.taglist = wibox({
      screen = s,
      x = s.geometry.x + s.geometry.width / 2 - svg.width / 2,
      y = s.geometry.y + s.geometry.height - svg.height - config.compass_size / 2 - config.border_width,
      width = svg.width,
      height = svg.height + config.compass_size / 2 + 2 * config.border_width,
      visible = false,
      ontop = true,
      type = 'dock',
      bg = beautiful.colors.transparent,
    })

    -- Do not group this into one call. We need to assign s.taglist and
    -- :setup returns void
    s.taglist:setup({
      {
        top = config.compass_size / 2,
        widget = wibox.container.margin,
      },
      {
        {
          {
            image = beautiful.svg('taglist/solarsystem'),
            widget = wibox.widget.imagebox,
          },
          shape = gears.shape.rectangle,
          shape_border_width = config.border_width,
          shape_border_color = beautiful.colors.white,
          widget = wibox.container.background,
        },
        {
          {
            {
              forced_width = config.compass_size,
              forced_height = config.compass_size,
              image = beautiful.svg('taglist/compass'),
              widget = wibox.widget.imagebox,
            },
            top = -1 + config.border_width - config.compass_size / 2,
            widget = wibox.container.margin,
          },
          valign = 'top',
          widget = wibox.container.place,
        },
        layout = wibox.layout.stack,
      },
      layout = wibox.layout.fixed.vertical,
    })
  end,
}
