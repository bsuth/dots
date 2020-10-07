local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- Constants --

local _LAYOUTS = { 'fcitx-keyboard-us', 'mozc' }

-- State --

local _state = {}

-- Widgets --

local _kb = {}
local _popup = {}

-- Other --

local keygrabber = {}

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

function _next()
    local layout = _state.layout == #_LAYOUTS and 1 or (_state.layout + 1)

    awful.spawn.easy_async_with_shell(([[
        fcitx-remote -s %s
    ]]):format(_LAYOUTS[layout]), function(_, _, _, exit_code)
        if exit_code == 0 then
            _state.layout = layout
            _kb.markup = _LAYOUTS[_state.layout]
        end
    end)
end

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

gears.table.crush(_state, {
    layout = 1,
})

--------------------------------------------------------------------------------
-- WIDGET: KB
--------------------------------------------------------------------------------

_kb = wibox.widget({
    forced_width = 100,
    forced_height = 100,
    markup = '',
    widget = wibox.widget.textbox,
})

--------------------------------------------------------------------------------
-- WIDGET: POPUP
--------------------------------------------------------------------------------

_popup = awful.popup({
    widget = {
        {
            _kb,
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
        {{ 'Control' }, 'space', function() _next() end},
    },

    stop_key = 'Control',
    stop_event = 'release',

    start_callback = function()
        _next()
        _popup.screen = awful.screen.focused()
        _popup.visible = true
    end,

    stop_callback = function()
        _popup.visible = false
    end,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return keygrabber
