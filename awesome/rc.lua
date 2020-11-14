local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'

-- Autofocus another client when the current one is closed
require('awful.autofocus')

--------------------------------------------------------------------------------
-- GLOBALS
--------------------------------------------------------------------------------

modkey = 'Mod4'
submodkey = 'Mod1'
ROOT = gears.filesystem.get_dir('config')

--------------------------------------------------------------------------------
-- MY MODULES
--------------------------------------------------------------------------------

require 'theme' 
require 'views/meter_notify'
local bindings = require 'bindings' 
local layouts = require 'layouts'

--------------------------------------------------------------------------------
-- LAYOUTS
--------------------------------------------------------------------------------

awful.layout.layouts = {
    awful.layout.suit.max,
}

--------------------------------------------------------------------------------
-- TAGS
--------------------------------------------------------------------------------

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, s, awful.layout.layouts[1])

    s:connect_signal('tag::history::update', function()
        -- restore focus to above client
        for _, c in ipairs(s.selected_tag:clients()) do
            if c.above then
                c:emit_signal('request::activate')
                return
            end
        end
    end)
end)

awful.scratchpad = awful.tag.add('scratchpad', {
	layout = layouts.grid,
	screen = awful.screen.focused(),
})

awful.clientbuffer = awful.tag.add('clientbuffer', {
	layout = layouts.grid,
	screen = awful.screen.focused(),
})

--------------------------------------------------------------------------------
-- RULES
--------------------------------------------------------------------------------

awful.rules.rules = {
    { 
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,

            keys = bindings.clientkeys,
            buttons = bindings.clientbuttons,

            raise = true,
			floating = false,
			maximized = false,

            focus = awful.client.focus.filter,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,
        },
    },
    
    { 
        rule_any = {
            instance = {
                "copyq",  -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
            },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester",  -- xev.
            },
            role = {
                "pop-up",       -- Google Chrome's (detached) Developer Tools.
            }
        },
        properties = {
            floating = true,
        }
    },
}

--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------

-- Signal function to execute when a new client appears.
client.connect_signal('manage', function (c)
    if awesome.startup then
        -- Prevent clients from being unreachable after screen count changes.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
        end
    else
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it as master.
        client.focus.above = false
        awful.client.setslave(c)
        c.above = true
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal('mouse::enter', function(c)
    c:emit_signal('request::activate', 'mouse_enter', { raise = false })
end)
