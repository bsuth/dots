--------------------------------------------------------------------------------
-- GLOBALS
--------------------------------------------------------------------------------

modkey = 'Mod4'
submodkey = 'Mod1'

--------------------------------------------------------------------------------
-- MODULES
--------------------------------------------------------------------------------

local awful = require 'awful' 
local beautiful = require 'beautiful' 
local naughty = require 'naughty' 

require 'theme' 
require 'views/meter_notify'
local bindings = require 'bindings' 
local layouts = require 'layouts'

-- Autofocus another client when the current one is closed
require('awful.autofocus')

--------------------------------------------------------------------------------
-- SETTINGS
--------------------------------------------------------------------------------

awful.layout.layouts = {
	awful.layout.suit.floating,
}

--------------------------------------------------------------------------------
-- SCRATCHPAD
--------------------------------------------------------------------------------

local scratchpad = awful.tag.add('scratchpad', {
	layout = layouts.grid,
	screen = awful.screen.focused(),
})

--------------------------------------------------------------------------------
-- RULES
--------------------------------------------------------------------------------

awful.rules.rules = {
    -- All clients will match this rule.
    { 
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,

            keys = bindings.clientkeys,
            buttons = bindings.clientbuttons,

            raise = true,
			floating = true,
			maximized = false,

			x = 100,
			y = 75,
			width = 1400,
			height = 750,

            focus = awful.client.focus.filter,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,

			callback = function(c)
				if awful.screen.focused().selected_tag == scratchpad then
					c.floating = false
				end
			end,
        },
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
