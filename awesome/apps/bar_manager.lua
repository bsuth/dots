local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local wibox = require 'wibox' 

local volume = require 'singletons/volume'
local brightness = require 'singletons/brightness'
local battery = require 'singletons/battery'

local dashboard = require 'apps/dashboard'

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- State --

local _state = {}

-- Widgets --

local _icon = {}
local _bar = {}
local _popup = {}

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function _volume()
    if dashboard.visible == true then return end

    _icon.image = beautiful.icon('apps/cs-sound.svg')
    _bar.value = volume:get()
    _bar.color = beautiful.colors.green

    _popup.visible = true
    _state.timer:again()
end

local function _brightness()
    if dashboard.visible == true then return end

    _icon.image = beautiful.icon('apps/display-brightness.svg')
    _bar.value = brightness:get()
    _bar.color = beautiful.colors.yellow

    _popup.visible = true
    _state.timer:again()
end

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

gears.table.crush(_state, {
    timer = gears.timer({
        timeout = 1,
        callback = function() _popup.visible = false end,
    })
})

volume:connect_signal('update', _volume)
brightness:connect_signal('update', _brightness)

--------------------------------------------------------------------------------
-- WIDGET: ICON
--------------------------------------------------------------------------------

_icon = wibox.widget({
    forced_width = 30,
    forced_height = 30,
    image = '',
    widget = wibox.widget.imagebox,
})

--------------------------------------------------------------------------------
-- WIDGET: BAR
--------------------------------------------------------------------------------

_bar = wibox.widget({
    value = 0,
    max_value = 100,

    forced_height = 30,
    forced_width  = 200,

    bar_shape = gears.shape.rounded_bar,
    shape = gears.shape.rounded_bar,
    background_color = beautiful.colors.black,

    widget = wibox.widget.progressbar,
})

--------------------------------------------------------------------------------
-- WIDGET: POPUP
--------------------------------------------------------------------------------

_popup = awful.popup({
    widget = {
        {
            {
                {
                    _bar,
                    direction = 'east',
                    widget = wibox.container.rotate,
                },
                widget = wibox.container.place,
            },
            {
                {
                    _icon,
                    margins = 10,
                    widget = wibox.container.margin,
                },
                shape = gears.shape.circle,
                bg = beautiful.colors.black,
                widget = wibox.container.background,
            },
            spacing = 10,
            layout = wibox.layout.fixed.vertical,
        },
        right = 30,
        widget = wibox.container.margin,
    },

    placement = awful.placement.right,
    ontop = true,
    visible = false,
    bg = beautiful.colors.transparent,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return {}
