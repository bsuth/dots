local awful = require 'awful'
local wibox = require 'wibox' 

local popup = require 'dashboard/popup'
local datetime_dials = require 'dashboard/datetime_dials'
local tabs = require 'dashboard/tabs'

--------------------------------------------------------------------------------
-- POPUP
--------------------------------------------------------------------------------

popup:set(wibox.widget({
    {
        datetime_dials,
        tabs,
        spacing = 200,
        layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
}))

return popup
