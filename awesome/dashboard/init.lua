local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

local volume = require 'models/volume'
local brightness = require 'models/brightness'

local tab_bluetooth = require 'dashboard/tab_bluetooth'
local tab_home = require 'dashboard/tab_home'
local tab_dmenu = require 'dashboard/tab_dmenu'
local tab_notifications = require 'dashboard/tab_notifications'
local tab_printer = require 'dashboard/tab_printer'
local tab_todo = require 'dashboard/tab_todo'
local tab_weather = require 'dashboard/tab_weather'
local tab_wifi = require 'dashboard/tab_wifi'

local popup = require 'dashboard/popup'

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- State --

local state = {}

-- Widgets --

local tabs_left_widget = {}
local tabs_right_widget = {}
local tab_content_widget = {}

-- Other --

local api = {}

--------------------------------------------------------------------------------
-- LOCAL FUNCTIONS
--------------------------------------------------------------------------------

local function focus(tab, skip_keygrabber)
    for _, _tab in ipairs(state.tabs) do
        _tab.button.shape_border_color = beautiful.colors.blacker
    end

    state.keygrabber:stop()
    state.keygrabber = awful.keygrabber({
        keybindings = gears.table.join(
            tab.keygrabber.keybindings or {},
            state.core_keybindings
        ),

        start_callback = tab.keygrabber.start_callback,
        stop_callback = tab.keygrabber.stop_callback,
        keypressed_callback = tab.keygrabber.keypressed_callback,
    })

    state.keygrabber:connect_signal('close_dashboard', api.stop)

    if not skip_keygrabber then
        state.keygrabber:start()
    end

    tab.button.shape_border_color = beautiful.colors.white
    tab_content_widget:set(1, tab.widget)
    state.focused_tab = tab
end

local function register(tab)
    tab.button = wibox.widget({
        {
            {
                {
                    forced_width = 70,
                    forced_height = 70,
                    image = tab.icon,
                    widget = wibox.widget.imagebox,
                },
                widget = wibox.container.place,
            },
            margins = 10,
            widget = wibox.container.margin,
        },
        shape = gears.shape.circle,
        bg = beautiful.colors.black,
		shape_border_width = 8,
		shape_border_color = beautiful.colors.transparent,
        widget = wibox.container.background,
    })

    tab.button:connect_signal('button::press', function(_, _, _, button, _, _)
        if button == 1 then focus(tab) end
    end)

    popup:register_hover(tab.button)
    table.insert(state.tabs, tab)

    return wibox.widget({
        tab.button,
        widget = wibox.container.background,
    })
end

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function api.start()
    state.keygrabber:start()
    popup:start()
end

function api.stop()
    state.keygrabber:stop()
    popup:stop()
end

function api.is_active()
    return popup.visible
end

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

gears.table.crush(state, {
    focused_tab = tab_home,
    tabs = {},
    keygrabber = awful.keygrabber(),
    core_keybindings = {
        {{ modkey }, ' ', function() api.stop() end},
        {{ 'Control' }, 'bracketleft', function() api.stop() end},
        {{ }, 'Escape', function() api.stop() end},

        {{ }, 'XF86AudioLowerVolume', function() volume:shift(-5) end},
        {{ }, 'XF86AudioRaiseVolume', function() volume:shift(5) end},
        {{ }, 'XF86AudioMute', function() volume:toggle() end},

        {{ }, 'XF86MonBrightnessDown', function() brightness:shift(-8) end},
        {{ }, 'XF86MonBrightnessUp', function() brightness:shift(8) end},

        {{ modkey }, 'f', function() focus(tab_home) end},
        {{ modkey }, 'd', function() focus(tab_dmenu) end},
        {{ modkey }, 's', function() focus(tab_todo) end},
        {{ modkey }, 'a', function() focus(tab_weather) end},
        {{ modkey }, 'j', function() focus(tab_notifications) end},
        {{ modkey }, 'k', function() focus(tab_bluetooth) end},
        {{ modkey }, 'l', function() focus(tab_wifi) end},
        {{ modkey }, ';', function() focus(tab_printer) end},
    },
})

--------------------------------------------------------------------------------
-- WIDGET: TABS LEFT
--------------------------------------------------------------------------------

tabs_left_widget = wibox.widget({
    register(tab_home),
    register(tab_dmenu),
    register(tab_todo),
    register(tab_weather),
    spacing = 50,
    layout = wibox.layout.flex.vertical,
})

--------------------------------------------------------------------------------
-- WIDGET: TABS RIGHT
--------------------------------------------------------------------------------

tabs_right_widget = wibox.widget({
    register(tab_notifications),
    register(tab_bluetooth),
    register(tab_wifi),
    register(tab_printer),
    spacing = 50,
    layout = wibox.layout.flex.vertical,
})

--------------------------------------------------------------------------------
-- WIDGET: TAB CONTENT
--------------------------------------------------------------------------------

tab_content_widget = wibox.widget({
    tab_home.widget,
    top_only = true,
    layout = wibox.layout.stack,
})

--------------------------------------------------------------------------------
-- POPUP
--------------------------------------------------------------------------------

popup:init(wibox.widget({
	{
		tabs_left_widget,
		right = 50,
        widget = wibox.container.margin,
	},
    {
        tab_content_widget,
        widget = wibox.container.place,
    },
	{
		tabs_right_widget,
		left = 50,
        widget = wibox.container.margin,
	},
    layout = wibox.layout.align.horizontal,
}))

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

focus(tab_home, true)
return api
