local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- Widgets --

local tbd_widget = {}

--------------------------------------------------------------------------------
-- WIDGET: TODO
--------------------------------------------------------------------------------

tbd_widget = wibox.widget({
    {
        markup = 'TBD',
        widget = wibox.widget.textbox,
    },
    margins = 100,
    widget = wibox.container.margin,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return {
    icon = beautiful.icon(''),
    keygrabber = {},
    widget = tbd_widget,
}
