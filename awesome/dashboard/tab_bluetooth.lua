local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- Widgets --

local _FIXME = {}

--------------------------------------------------------------------------------
-- WIDGET: TODO
--------------------------------------------------------------------------------

_FIXME = wibox.widget({
    {
        markup = 'TODO',
        widget = wibox.widget.textbox,
    },
    margins = 100,
    widget = wibox.container.margin,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return {
    icon = beautiful.icon('todo'),
    keygrabber = {},
    widget = wibox.widget({
        _FIXME,
        shape = gears.shape.rounded_rect,
        bg = beautiful.colors.black,
        widget = wibox.container.background,
    }),
}
