local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local wibox = require 'wibox' 

local volume_model = require 'models/volume'
local brightness_model = require 'models/brightness'
local battery_model = require 'models/battery'
local ram_model = require 'models/ram'

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
-- LOCAL FUNCTIONS
--------------------------------------------------------------------------------

local function _notify(callback)
    if dashboard.is_active() then return end

    (callback)()

    _popup.screen = awful.screen.focused()
    _popup.visible = true
    _state.timer:again()
end

local function _volume()
    _icon.image = beautiful.icon('volume')
    _bar.value = volume_model.percent
    _bar.color = beautiful.colors.green
end

local function _brightness()
    _icon.image = beautiful.icon('brightness')
    _bar.value = brightness_model.percent
    _bar.color = beautiful.colors.yellow
end

local function _battery_warning_low()
    _state.low_battery = true
    _icon.image = battery_model.icon
    _bar.value = battery_model.percent
    _bar.color = beautiful.colors.red
end

local function _ram_warning_high()
    _state.high_ram = true
    _icon.image = beautiful.icon('TODO') -- TODO
    _bar.value = ram_model.percent
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

volume_model:connect_signal('update', function()
	_notify(_volume)
end)

brightness_model:connect_signal('update', function()
	_notify(_brightness)
end)

battery_model:connect_signal('warning', function()
	_notify(_battery_warning_low)
end)
battery_model:connect_signal('clear_warning', function()
    _state.low_battery = false
    _popup.visible = false
end)

ram_model:connect_signal('warning', function()
	_notify(_ram_warning_high)
end)
ram_model:connect_signal('clear_warning', function()
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
