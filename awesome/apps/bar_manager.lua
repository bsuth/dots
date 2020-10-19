local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local wibox = require 'wibox' 

local volume = require 'singletons/volume'
local brightness = require 'singletons/brightness'
local battery = require 'singletons/battery'
local ram = require 'singletons/ram'

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

local function _notify(callback)
    if dashboard.is_active() then return end

    (callback)()

    _popup.screen = awful.screen.focused()
    _popup.visible = true
    _state.timer:again()
end

local function _volume()
    _icon.image = beautiful.icon('apps/cs-sound.svg')
    _bar.value = volume:get()
    _bar.color = beautiful.colors.green
end

local function _brightness()
    _icon.image = beautiful.icon('apps/display-brightness.svg')
    _bar.value = brightness:get()
    _bar.color = beautiful.colors.yellow
end

local function _battery_warning_low()
    _state.low_battery = true
    _icon.image = beautiful.icon('devices/battery.svg')
    _bar.value = battery:get()
    _bar.color = beautiful.colors.red
end

local function _ram_warning_high()
    _state.high_ram = true
    _icon.image = beautiful.icon('devices/cpu.svg')
    _bar.value = ram:get()
    _bar.color = beautiful.colors.purple
end

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

gears.table.crush(_state, {
    low_battery = false,
    high_ram = false,
    timer = gears.timer({
        timeout = 1,
        callback = function()
            if _state.high_ram then
                _ram_warning_high()
            elseif _state.low_battery then
                _battery_warning_low()
            else
                _popup.visible = false
            end
        end,
    })
})

volume:connect_signal('update', function() _notify(_volume) end)
brightness:connect_signal('update', function() _notify(_brightness) end)

battery:connect_signal('warning_low', function() _notify(_battery_warning_low) end)
battery:connect_signal('no_warning', function()
    _state.low_battery = false
    _popup.visible = false
end)

ram:connect_signal('warning_high', function() _notify(_ram_warning_high) end)
ram:connect_signal('no_warning', function()
    _state.high_ram = false
    _popup.visible = false
end)

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
