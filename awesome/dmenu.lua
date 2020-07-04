local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local wgrid = require('widgets.grid')

--------------------------------------------------------------------------------
-- APPS
--------------------------------------------------------------------------------

local apps = {
    {
        alias = 'alacritty',
        callback = function()
            awful.spawn('alacritty')
        end,
    },
    {
        alias = 'anki',
        callback = function()
            awful.spawn('anki')
        end,
    },
    {
        alias = 'discord',
        callback = function()
            awful.spawn('discord')
        end,
    },
    {
        alias = 'firefox',
        callback = function()
            awful.spawn('firefox')
        end,
    },
    {
        alias = 'gimp',
        callback = function()
            awful.spawn('gimp')
        end,
    },
    {
        alias = 'inkscape',
        callback = function()
            awful.spawn('inkscape')
        end,
    },
    {
        alias = 'qutebrowser',
        callback = function()
            awful.spawn('qutebrowser')
        end,
    },
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
    forced_num_cols = 3,
    expand = true,
    vertical_expand = false,
    spacing = 10,
    homogeneous = true,
})

for _, app in ipairs(apps) do
    local w = wibox.widget({
        {
            markup = app.alias,
            align  = 'center',
            valign = 'center',
            widget = wibox.widget.textbox,
        },

        forced_height = 100,

        shape = gears.shape.rounded_rect,
        shape_border_width = 5,
        shape_border_color = beautiful.colors.dark_grey,

        filter = app.alias,
        callback = app.callback,
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
    {
        {
            span_ratio = 0.5,
            forced_height = 5,
            thickness = 5,
            color = beautiful.colors.dark_grey,
            widget = wibox.widget.separator,
        },

        bottom = 50,
        layout = wibox.container.margin,
    },
    grid,

    expand = 'outside',
    layout = wibox.layout.fixed.vertical,
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
    bg = '#000000e8',
})

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function apply_filter(unfilter)
    grid:reset()

    for _, w in pairs(app_widgets) do
        if w.filter:sub(1, filter.markup:len()) == filter.markup then
            grid:add(w)
        end
    end

    grid:default_focus()
end

--------------------------------------------------------------------------------
-- KEYGRABBER
--------------------------------------------------------------------------------

local modkey = 'Mod4'

return awful.keygrabber({
    keybindings = {
        {{ modkey }, 'h', function() grid:focus_by_direction('left') end},
        {{ modkey }, 'j', function() grid:focus_by_direction('down') end},
        {{ modkey }, 'k', function() grid:focus_by_direction('up') end},
        {{ modkey }, 'l', function() grid:focus_by_direction('right') end},
        {{ modkey }, 'd', function(self) self:stop() end},
        {{ 'Control' }, 'u', function() filter.markup = ''; apply_filter(true) end},
        {{ 'Control' }, 'bracketleft', function(self) self:stop() end},
        {{ }, 'Return', function(self) grid.focused_widget.callback(); self:stop() end},
    },

    start_callback = function()
        local s = awful.screen.focused()

        popup.screen = s
        popup.minimum_width = s.geometry.width
        popup.minimum_height = s.geometry.height
        popup.visible = true

        content.forced_width = 0.6 * s.geometry.width
        content.forced_height = 0.6 * s.geometry.height

        grid:default_focus()
    end,

    stop_callback = function()
        popup.visible = false
        filter.markup = ''
        apply_filter(true)
    end,

    keypressed_callback = function(self, mods, key)
        if key == 'BackSpace' and #filter.markup > 0 then
            filter.markup = string.sub(filter.markup, 1, -2)
            apply_filter(true)
        elseif #mods == 0 and string.match(key, '^[a-zA-Z ]$') then
            filter.markup = filter.markup .. key
            apply_filter()
        end
    end,
})
