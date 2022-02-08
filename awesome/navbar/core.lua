local beautiful = require('beautiful')
local wibox = require('wibox')

local core = {}

-- -----------------------------------------------------------------------------
-- Constants
-- -----------------------------------------------------------------------------

core.HEIGHT = 50
core.FONT_FAMILY = 'Kalam'
core.FONT = core.FONT_FAMILY .. ' 14'

-- -----------------------------------------------------------------------------
-- markupText
-- -----------------------------------------------------------------------------

function core.markupText(text, color)
  return (
    '<span color="%s" font_family="%s" weight="bold" size="medium">%s</span>'
  ):format(color or beautiful.colors.void, core.FONT_FAMILY, tostring(text))
end

-- -----------------------------------------------------------------------------
-- Select
-- -----------------------------------------------------------------------------

function core.Select(args)
  return wibox.widget({
    {
      shape = function(cr, width, height)
        local size = 6
        local rgb

        if not args.active then
          return
        elseif args.disabled then
          rgb = beautiful.hex2rgb(beautiful.colors.dark_grey)
        else
          rgb = beautiful.hex2rgb(beautiful.colors.void)
        end

        cr:set_source_rgb(rgb[1], rgb[2], rgb[3])

        cr:move_to(0, 0)
        cr:line_to(size, 0)
        cr:line_to(0, size)

        cr:move_to(width, 0)
        cr:line_to(width - size, 0)
        cr:line_to(width, size)

        cr:move_to(0, height)
        cr:line_to(0, height - size)
        cr:line_to(size, height)

        cr:move_to(width, height)
        cr:line_to(width - size, height)
        cr:line_to(width, height - size)

        cr:paint()
      end,
      widget = wibox.container.background,
    },
    {
      args.widget,
      forced_height = core.HEIGHT,
      left = 16,
      right = 16,
      widget = wibox.container.margin,
    },
    layout = wibox.layout.stack,
  })
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return core
