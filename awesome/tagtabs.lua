local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local layout = require('layout')
local wibox = require('wibox')

--
-- Constants / Config
--

local config = {
  height = 40,
  border_bottom_width = 4,
}

--
-- Tagtab
--

local function tagtab()
  return wibox.widget({
    {
      text = 'Test',
      halign = 'center',
      valign = 'center',
      forced_height = config.height - config.border_bottom_width,
      widget = wibox.widget.textbox,
    },
    left = 8,
    right = 8,
    widget = wibox.container.margin,
  })
end

--
-- Tagtabs
--

return {
  attach = function(s)
    s.tagtabs = wibox({
      screen = s,
      visible = false,
      ontop = true,
      type = 'dock',

      x = s.geometry.x,
      y = s.geometry.y,
      width = s.geometry.width,
      height = config.height,

      bg = beautiful.colors.black,
    })

    s.tagtabs:setup({
      {
        tagtab(),
        tagtab(),
        tagtab(),
        tagtab(),
        layout = wibox.layout.fixed.horizontal,
      },
      {
        {
          top = config.border_bottom_width,
          widget = wibox.container.margin,
        },
        bg = beautiful.colors.white,
        widget = wibox.container.background,
      },
      layout = wibox.layout.fixed.vertical,
    })
  end,
}
