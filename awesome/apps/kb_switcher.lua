local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local wibox = require 'wibox' 

local kb_layout_model = require 'models/kb_layout'

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- Widgets --

local kb_widget = {}

-- Other --

local popup = {}
local keygrabber = {}

--------------------------------------------------------------------------------
-- WIDGET: KB
--------------------------------------------------------------------------------

kb_widget = wibox.widget({
    forced_width = 100,
    forced_height = 100,
    markup = '',
    widget = wibox.widget.textbox,
})

--------------------------------------------------------------------------------
-- POPUP
--------------------------------------------------------------------------------

popup = awful.popup({
    widget = {
        {
            kb_widget,
            margins = 10,
            widget = wibox.container.margin,
        },
        shape = gears.shape.circle,
        shape_border_color = beautiful.colors.purple,
        shape_border_width = 5,
        bg = beautiful.colors.black,
        widget = wibox.container.background,
    },
    ontop = true,
    visible = false,
    placement = awful.placement.centered,
    bg = beautiful.colors.transparent,
})

--------------------------------------------------------------------------------
-- KEYGRABBER
--------------------------------------------------------------------------------

keygrabber = awful.keygrabber({
    keybindings = {
        {{ 'Mod4', 'Control' }, 'space', function() kb_layout_model:next() end},
    },

    stop_key = 'Control',
    stop_event = 'release',

    start_callback = function()
		kb_layout_model:next()
        popup.screen = awful.screen.focused()
        popup.visible = true
    end,

    stop_callback = function()
        popup.visible = false
    end,
})

--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------

kb_layout_model:connect_signal('update', function()
    kb_widget.markup = kb_layout_model.layout_name
end)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return keygrabber
