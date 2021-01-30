local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local wibox = require 'wibox' 

local volume_model = require 'models/volume'
local brightness_model = require 'models/brightness'
local battery_model = require 'models/battery'
local ram_model = require 'models/ram'
local cpu_model = require 'models/cpu'

local dashboard = require 'dashboard'

--------------------------------------------------------------------------------
-- DECLARATIONS
--------------------------------------------------------------------------------

-- State --

local state = {}

-- Widgets --

local icon_widget = {}
local bar_widget = {}

-- Other --

local popup = {}

--------------------------------------------------------------------------------
-- LOCAL FUNCTIONS
--------------------------------------------------------------------------------

local function show_battery_warning()
    icon_widget.image = battery_model.icon
    bar_widget.value = battery_model.percent
    bar_widget.color = beautiful.colors.red
end

local function show_ram_warning()
    icon_widget.image = beautiful.icon('ram')
    bar_widget.value = ram_model.percent
    bar_widget.color = beautiful.colors.purple
end

local function show_cpu_warning()
    icon_widget.image = beautiful.icon('cpu')
    bar_widget.value = cpu_model.percent
    bar_widget.color = beautiful.colors.blue
end

local function notify(callback)
    if dashboard.is_active() then
		local urgent = gears.table.hasitem({
			show_ram_warning,
			show_cpu_warning,
			show_battery_warning
		}, callback) ~= nil

		if not urgent then return end
	end

    (callback)()

    popup.screen = awful.screen.focused()
    popup.visible = true
    state.timer:again()
end

--------------------------------------------------------------------------------
-- INIT STATE
--------------------------------------------------------------------------------

gears.table.crush(state, {
    battery_warning = false,
    ram_warning = false,
    cpu_warning = false,
    timer = gears.timer({
        timeout = 1,
        callback = function()
            if state.ram_warning then
                show_ram_warning()
            elseif state.cpu_warning then
                show_cpu_warning()
            elseif state.battery_warning then
                show_battery_warning()
            else
                popup.visible = false
            end
        end,
    })
})

--------------------------------------------------------------------------------
-- WIDGET: ICON
--------------------------------------------------------------------------------

icon_widget = wibox.widget({
    forced_width = 30,
    forced_height = 30,
    image = '',
    widget = wibox.widget.imagebox,
})

--------------------------------------------------------------------------------
-- WIDGET: BAR
--------------------------------------------------------------------------------

bar_widget = wibox.widget({
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
-- POPUP
--------------------------------------------------------------------------------

popup = awful.popup({
    widget = {
        {
            {
                {
                    bar_widget,
                    direction = 'east',
                    widget = wibox.container.rotate,
                },
                widget = wibox.container.place,
            },
            {
                {
                    icon_widget,
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
-- SIGNALS
--------------------------------------------------------------------------------

volume_model:connect_signal('update', function()
	notify(function()
		icon_widget.image = volume_model.icon
		bar_widget.value = volume_model.percent
		bar_widget.color = beautiful.colors.green
	end)
end)

brightness_model:connect_signal('update', function()
	notify(function()
		icon_widget.image = beautiful.icon('brightness')
		bar_widget.value = brightness_model.percent
		bar_widget.color = beautiful.colors.yellow
	end)
end)

battery_model:connect_signal('warning', function()
    state.battery_warning = true
	notify(show_battery_warning)
end)

battery_model:connect_signal('clear_warning', function()
    state.battery_warning = false
    state.timer:again()
end)

ram_model:connect_signal('warning', function()
    state.ram_warning = true
	notify(show_ram_warning)
end)

ram_model:connect_signal('clear_warning', function()
    state.ram_warning = false
    state.timer:again()
end)

cpu_model:connect_signal('warning', function()
    -- state.cpu_warning = true
	-- notify(show_cpu_warning)
end)

cpu_model:connect_signal('clear_warning', function()
    state.cpu_warning = false
    state.timer:again()
end)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return {}
