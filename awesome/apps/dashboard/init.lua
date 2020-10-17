local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

local tab_bluetooth = require 'apps/dashboard/tab_bluetooth'
local tab_datetime = require 'apps/dashboard/tab_datetime'
local tab_dmenu = require 'apps/dashboard/tab_dmenu'
local tab_notifications = require 'apps/dashboard/tab_notifications'
local tab_printer = require 'apps/dashboard/tab_printer'
local tab_todo = require 'apps/dashboard/tab_todo'
local tab_weather = require 'apps/dashboard/tab_weather'
local tab_wifi = require 'apps/dashboard/tab_wifi'

local popup = require 'apps/dashboard/popup'

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- State --

local _state = {}

-- Widgets --

local _tabs_left = {}
local _tabs_right = {}
local _tab_content = {}

-- Other --

local modkey = 'Mod4'
local api = {}

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function _set_focused_tab(tab, skip_keygrabber)
    for _, _tab in ipairs(_state.tabs) do
        _tab.button.shape_border_color = beautiful.colors.transparent
    end

    _state.keygrabber:stop()
    _state.keygrabber = awful.keygrabber({
        keybindings = gears.table.join(
            tab.keygrabber.keybindings or {},
            _state.core_keybindings
        ),

        start_callback = tab.keygrabber.start_callback,
        stop_callback = tab.keygrabber.stop_callback,
        keypressed_callback = tab.keygrabber.keypressed_callback,
    })

    if not skip_keygrabber then
        _state.keygrabber:start()
    end

    tab.button.shape_border_color = beautiful.colors.cyan
    _tab_content:set(1, tab.widget)
    _state.focused_tab = tab
end

local function _register_tab(tab)
    tab.button = wibox.widget({
        {
            {
                {
                    forced_width = 50,
                    forced_height = 50,
                    image = beautiful.icon('apps/cs-date-time.svg'), -- TODO
                    widget = wibox.widget.imagebox,
                },
                widget = wibox.container.place,
            },
            margins = 10,
            widget = wibox.container.margin,
        },
        shape = gears.shape.circle,
        bg = beautiful.colors.black,
		shape_border_width = 5,
		shape_border_color = beautiful.colors.transparent,
        widget = wibox.container.background,
    })

    tab.button:connect_signal('button::press', function(_, _, _, button, _, _)
        if button == 1 then _set_focused_tab(tab) end
    end)

    popup:register_hover(tab.button)
    table.insert(_state.tabs, tab)

    return wibox.widget({
        tab.button,
        widget = wibox.container.place,
    })
end

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function api.start()
    _state.keygrabber:start()
    popup:start()
end

function api.stop()
    _state.keygrabber:stop()
    popup:stop()
end

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

gears.table.crush(_state, {
    focused_tab = tab_datetime,
    tabs = {},
    keygrabber = awful.keygrabber(),
    core_keybindings = {
        {{ modkey }, ' ', function() api.stop() end},
        {{ 'Control' }, 'bracketleft', function() api.stop() end},
        {{ }, 'Escape', function() api.stop() end},
    },
})

--------------------------------------------------------------------------------
-- WIDGET: TABS LEFT
--------------------------------------------------------------------------------

_tabs_left = wibox.widget({
    _register_tab(tab_datetime),
    _register_tab(tab_todo),
    _register_tab(tab_dmenu),
    _register_tab(tab_weather),
    spacing = 50,
    layout = wibox.layout.flex.vertical,
})

--------------------------------------------------------------------------------
-- WIDGET: TABS RIGHT
--------------------------------------------------------------------------------

_tabs_right = wibox.widget({
    _register_tab(tab_notifications),
    _register_tab(tab_bluetooth),
    _register_tab(tab_wifi),
    _register_tab(tab_printer),
    spacing = 50,
    layout = wibox.layout.flex.vertical,
})

--------------------------------------------------------------------------------
-- WIDGET: TAB CONTENT
--------------------------------------------------------------------------------

_tab_content = wibox.widget({
    tab_datetime.widget,
    top_only = true,
    layout = wibox.layout.stack,
})

--------------------------------------------------------------------------------
-- POPUP
--------------------------------------------------------------------------------

popup:init(wibox.widget({
    {
        _tabs_left,
        top = 100,
        bottom = 100,
        left = 50,
        right = 100, 
        widget = wibox.container.margin,
    },
    {
        {
            _tab_content,
            margins = 50,
            widget = wibox.container.margin,
        },
        widget = wibox.container.place,
    },
    {
        _tabs_right,
        top = 100,
        bottom = 100,
        left = 100, 
        right = 50,
        widget = wibox.container.margin,
    },
    layout = wibox.layout.align.horizontal,
}))

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

_set_focused_tab(tab_datetime, true)
return api
