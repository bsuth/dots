local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local hkeys = require('helpers.keys')
local volume = require('dashboard.volume')
local brightness = require('dashboard.brightness')

---------------------------------------
-- DASHBOARD
---------------------------------------

local db = awful.popup({
    widget = {
        forced_num_rows = 20,
        forced_num_cols= 20,
        spacing = 10,
        expand = true,
        homogeneous = true,
        layout = wibox.layout.grid,
    },

    placement = awful.placement.centered,
    ontop = true,
    visible = false,
    bg = '#000000cc',
})

db.widget:add_widget_at(volume, 7, 19, 8, 1)
db.widget:add_widget_at(brightness, 7, 18, 8, 1)

---------------------------------------
-- DASHBOARD API
---------------------------------------

function db:focus(w)
    if self.focused_widget then
        self.focused_widget.shape_border_color = beautiful.colors.dark_grey
    end

    w.shape_border_color = beautiful.colors.green
    self.focused_widget = w
end

function db:show()
    self.screen = awful.screen.focused()
    self.widget.forced_width = self.screen.geometry.width
    self.widget.forced_height = self.screen.geometry.height
    self.visible = true
end

function db:hide()
    self.visible = false
end

function db:focus_by_direction(dir)
    local rows, cols = self.widget:get_dimension()
    local wpos = self.widget:get_widget_position(self.focused_widget)
    local wnew, start, limit, inc, getw

    if (dir == 'left') then
        start = wpos.col - 1
        inc = -1
        limit = 0
        getw = function(i) return self.widget:get_widgets_at(wpos.row, i) end
    elseif (dir == 'right') then
        start = wpos.col + 1
        inc = 1
        limit = cols
        getw = function(i) return self.widget:get_widgets_at(wpos.row, i) end
    elseif (dir == 'up') then
        start = wpos.row - 1
        inc = -1
        limit = 0
        getw = function(i) return self.widget:get_widgets_at(i, wpos.col) end
    elseif (dir == 'down') then
        start = wpos.row + 1
        inc = 1
        limit = rows
        getw = function(i) return self.widget:get_widgets_at(i, wpos.col) end
    else
        return
    end

    for i = start, limit, inc do
        wnew = getw(i)
        if wnew ~= nil then
            self:focus(wnew[1])
            return
        end
    end
end

---------------------------------------
-- DASHBOARD KEYGRABBER
---------------------------------------

local modkey = 'Mod4'

db.kg = awful.keygrabber({
    keybindings = {
        {{ modkey }, 'h', function() db:focus_by_direction('left') end},
        {{ modkey }, 'j', function() db:focus_by_direction('down') end},
        {{ modkey }, 'k', function() db:focus_by_direction('up') end},
        {{ modkey }, 'l', function() db:focus_by_direction('right') end},
    },

    -- Note that it is using the key name and not the modifier name.
    stop_key = { modkey, '[' },
    start_callback = function() db:show() end,
    stop_callback = function() db:hide() end,
    keypressed_callback = function(self, mods, k)
        if db.focused_widget.keys then
            hkeys.keypress(db.focused_widget.keys, mods, k)
        end
    end,
})

---------------------------------------
-- RETURN
---------------------------------------

-- Default focus
db:focus(volume)

return db
