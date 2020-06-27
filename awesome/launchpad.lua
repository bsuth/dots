local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

local wgrid = require('widgets.grid')

--------------------------------------------------------------------------------
-- APPS
--------------------------------------------------------------------------------

local apps = {
    inkscape = function()
        awful.spawn('inkscape')
    end,
    firefox = function()
        awful.spawn('firefox')
    end,
    qutebrowser = function()
        awful.spawn('qutebrowser')
    end,
    alacritty= function()
        awful.spawn('alacritty')
    end,
    discord = function()
        awful.spawn('discord')
    end,
    gimp = function()
        awful.spawn('gimp')
    end,
}

local app_widgets = {}

--------------------------------------------------------------------------------
-- FILTER
--------------------------------------------------------------------------------

local filter = wibox.widget({
    markup = '',
    forced_height = 100,
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
})

--------------------------------------------------------------------------------
-- GRID
--------------------------------------------------------------------------------

local grid = wgrid.grid({
    forced_num_cols = 5,

    spacing = 10,
    homogeneous = true,
    
    shape = gears.shape.rounded_rect,
    shape_border_width = 5,
    shape_border_color = beautiful.colors.dark_grey,
})

for cmd, callback in pairs(apps) do
    local w = wibox.widget({
        {
            markup = cmd,
            align  = 'center',
            valign = 'center',
            widget = wibox.widget.textbox,
        },

        forced_width = 100,
        forced_height = 100,

        shape = gears.shape.rounded_rect,
        shape_border_width = 5,
        shape_border_color = beautiful.colors.dark_grey,

        filter = cmd,
        callback = callback,
        widget = wibox.container.background,
    })

    grid:add(w)
    table.insert(app_widgets, w)
end

--------------------------------------------------------------------------------
-- CONTENT (FILTER + GRID WRAPPER)
--------------------------------------------------------------------------------

local content = wibox.widget({
    filter,
    grid,
    layout = wibox.layout.align.vertical,
})

--------------------------------------------------------------------------------
-- POPUP (MAIN WRAPPER)
--------------------------------------------------------------------------------

local popup = awful.popup({
    widget = {
        content,
        valign = 'center',
        halign = 'center',
        widget = wibox.container.place,
    },

    ontop = true,
    visible = false,
    bg = '#000000cc',
})

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function apply_filter(unfilter)
    grid:reset()

    for _, w in pairs(app_widgets) do
        if string.find(w.filter, filter.markup) then
            grid:add(w)
        end
    end

    grid:default_focus()
end

--------------------------------------------------------------------------------
-- LAUNCHPAD (KEYGRABBER)
--------------------------------------------------------------------------------

local modkey = 'Mod4'

return awful.keygrabber({
    keybindings = {
        {{ modkey }, 'h', function() grid:focus_by_direction('left') end},
        {{ modkey }, 'j', function() grid:focus_by_direction('down') end},
        {{ modkey }, 'k', function() grid:focus_by_direction('up') end},
        {{ modkey }, 'l', function() grid:focus_by_direction('right') end},
        {{ }, 'Return', function(self) grid.focused_widget.callback(); self:stop() end},
    },

    start_callback = function()
        local s = awful.screen.focused()

        popup.screen = s
        popup.minimum_width = s.geometry.width
        popup.minimum_height = s.geometry.height
        popup.visible = true

        content.forced_width = 0.8 * s.geometry.width
        content.forced_height = 0.8 * s.geometry.height

        grid:default_focus()
    end,

    stop_callback = function()
        popup.visible = false
        filter.markup = ''
        apply_filter(true)
    end,

    keypressed_callback = function(self, mods, key)
        if key == 'bracketleft' and #mods then
            for _, mod in ipairs(mods) do
                if mod ~= 'Control' then
                    goto process_key
                end
            end

            self:stop()
            return
        end

        ::process_key::

        if key == 'BackSpace' and #filter.markup > 0 then
            filter.markup = string.sub(filter.markup, 1, -2)
            apply_filter(true)
        elseif #mods == 0 and string.match(key, '^[a-zA-Z ]$') then
            filter.markup = filter.markup .. key
            apply_filter()
        end
    end,
})
