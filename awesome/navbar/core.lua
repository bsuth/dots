local beautiful = require('beautiful')
local wibox = require('wibox')

local core = {}

-- -----------------------------------------------------------------------------
-- Constants
-- -----------------------------------------------------------------------------

core.HEIGHT = 50
core.FONT = 'Fredoka One 14'

-- -----------------------------------------------------------------------------
-- markupText
-- -----------------------------------------------------------------------------

function core.markupText(text, color)
  return ('<span color="%s" font_family="%s" size="small">%s</span>'):format(
    color or beautiful.colors.white,
    'Hack Regular',
    tostring(text)
  )
end

-- -----------------------------------------------------------------------------
-- Select
-- -----------------------------------------------------------------------------

function core.Select(args)
  return wibox.widget({
    {
      args.widget,
      forced_height = core.HEIGHT,
      left = 20,
      right = 20,
      widget = wibox.container.margin,
    },
    shape = function(cr, width, height)
      if not args.active then
        return
      end

      local size = 6
      local rgb = beautiful.hex2rgb(beautiful.colors.white)
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
-- Return
-- -----------------------------------------------------------------------------

return core
