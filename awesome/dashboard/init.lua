local awful = require 'awful'
local wibox = require 'wibox' 

local popup = require 'dashboard/popup'
local datetime_sliders = require 'dashboard/datetime_sliders'
local notifications = require 'dashboard/notifications'
local tabs = require 'dashboard/tabs'

--------------------------------------------------------------------------------
-- GRID
--------------------------------------------------------------------------------

local grid = wibox.widget({
    forced_num_rows = 14,
    forced_num_cols = 2,
    spacing = 20,
    expand = true,
    homogeneous = true,
    layout = wibox.layout.grid,
})

grid:add_widget_at(datetime_sliders, 2, 1, 6, 1)
grid:add_widget_at(notifications, 8, 1, 6, 1)
grid:add_widget_at(tabs, 3, 2, 10, 1)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

popup:set(grid)
return popup
