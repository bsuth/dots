-- Standard awesome library
local gears = require('gears')
local awful = require('awful')
require('awful.autofocus')

-- Widget and layout library
local wibox = require('wibox')

-- Keybindings
local keys = require('keys')

-- Mouse Bindings
local mouse = require('mouse')

-- Theme handling library
local beautiful = require('beautiful')

-- Notification library
local naughty = require('naughty')
local hotkeys_popup = require('awful.hotkeys_popup').widget

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require('awful.hotkeys_popup.keys')

-- Tag Manager
local tagger = require('widgets.tagger')


---------------------------------------
-- ERROR HANDLING
---------------------------------------

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


---------------------------------------
-- SETTINGS
---------------------------------------

config = os.getenv('DOTS') .. '/awesome'

terminal = 'alacritty'
editor = os.getenv('EDITOR') or 'nvim'
editor_cmd = terminal .. ' -e ' .. editor

awful.layout.layouts = {
    awful.layout.suit.floating
}

root.keys(keys.global)


---------------------------------------
-- THEME
---------------------------------------

beautiful.init(config .. '/theme.lua')

local function set_wallpaper(screen)
    if beautiful.wallpaper then
        gears.wallpaper.maximized(beautiful.wallpaper, screen, true)
    end
end

-- Re-set wallpaper when screen geometry changes (e.g. resolution change)
screen.connect_signal('property::geometry', set_wallpaper)


---------------------------------------
-- SCREENS
---------------------------------------

mykeyboardlayout = awful.widget.keyboardlayout()
mytextclock = wibox.widget.textclock()

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    s.tagger = tagger:new(s)
end)

---------------------------------------
-- RULES
---------------------------------------

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
                'pop-up',       -- e.g. Google Chrome's (detached) Developer Tools.
            }
        }, 
        properties = { floating = true }
    },
}


---------------------------------------
-- SIGNALS
---------------------------------------

-- Signal function to execute when a new client appears.
client.connect_signal('manage', function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
        not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Focus follows mouse.
client.connect_signal('mouse::enter', function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- Focus changes border color
client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)
