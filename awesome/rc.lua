local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

require('theme')
local keys = require('keys')
local mouse = require('mouse')
local layouts = require('layouts')
local tagger = require('tagger')
local db = require('dashboard')

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- require('awful.hotkeys_popup.keys')
require('awful.autofocus')

--------------------------------------------------------------------------------
-- ERROR HANDLING
--------------------------------------------------------------------------------

if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = 'Startup Error',
        text = awesome.startup_errors
     })
end

do
    local in_error = false

    awesome.connect_signal('debug::error', function (err)
        -- Prevent infinite loop
        if not in_error then
            in_error = true

            naughty.notify({
                 preset = naughty.config.presets.critical,
                 title = 'Awesome Error',
                 text = tostring(err)
             })

            in_error = false
        end
    end)
end

--------------------------------------------------------------------------------
-- SETTINGS
--------------------------------------------------------------------------------

awful.layout.layouts = {
    awful.layout.suit.tile,
    layouts.music,
    layouts.dual,
}

root.keys(keys.global)

--------------------------------------------------------------------------------
-- SCREEN SETUP
--------------------------------------------------------------------------------

awful.screen.connect_for_each_screen(function(s)
    tagger:new(s, {
        { '1', '2', '3' },
        { '4', '5', '6' },
        { '7', '8', '9' },
    })
end)

--------------------------------------------------------------------------------
-- UNIVERSAL TAGS
--------------------------------------------------------------------------------

local universal_tags = {
	'music',
}

for _, tag_name in ipairs(universal_tags) do
	awful.tag.add(tag_name, {
		layout = layouts.music,
		screen = awful.screen.focused(),
	})
end

--------------------------------------------------------------------------------
-- RULES
--------------------------------------------------------------------------------

-- Rules to apply to new clients (through the 'manage' signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { 
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = keys.client,
            buttons = mouse.client,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    { 
        rule_any = {
            instance = {
                'copyq',  -- Includes session name in class.
            },
            class = {
                'Arandr',
                'Gpick',
                'Kruler',
                'MessageWin',  -- kalarm.
                'Sxiv',
                'Wpa_gui',
                'pinentry',
                'veromix',
                'xtightvncviewer',
            },
            name = {
                'Event Tester',  -- xev.
            },
            role = {
                'AlarmWindow',  -- Thunderbird's calendar.
                -- 'pop-up',       -- e.g. Google Chrome's (detached) Developer Tools.
            }
        }, 
        properties = { floating = true }
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
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal('mouse::enter', function(c)
    c:emit_signal('request::activate', 'mouse_enter', { raise = false })
end)

-- Focus changes border color
client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)
