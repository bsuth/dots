local awful = require 'awful'
local wibox = require 'wibox' 

local datetime_sliders = require 'dashboard/datetime_sliders'
local notifications = require 'dashboard/notifications'
local tabs = require 'dashboard/tabs'

--------------------------------------------------------------------------------
-- GRID
--------------------------------------------------------------------------------

local grid = wibox.widget({
    forced_num_rows = 12,
    forced_num_cols = 2,
    spacing = 20,
    expand = true,
    homogeneous = true,
    layout = wibox.layout.grid,
})

grid:add_widget_at(datetime_sliders, 1, 1, 5, 1)
grid:add_widget_at(notifications, 6, 1, 7, 1)
grid:add_widget_at(tabs, 3, 2, 8, 1)

--------------------------------------------------------------------------------
-- POPUP
--------------------------------------------------------------------------------

local popup = awful.popup({
    widget = {
        grid,
        left = 50,
        right = 50,
        top = 50,
        bottom = 50,
        widget = wibox.container.margin,
    },
    ontop = true,
    visible = false,
    bg = '#000000cc',
})

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function popup:toggle()
    if not self.visible then
        self.screen = awful.screen.focused()
        self.widget.forced_width = self.screen.geometry.width
        self.widget.forced_height = self.screen.geometry.height
        self.visible = true
    else
        self.visible = false
    end
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return popup
