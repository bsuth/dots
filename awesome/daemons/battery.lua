
---------------------------------------
-- IMPORTS
---------------------------------------
local awful = require('awful')
local gears = require('gears')
local naughty = require('naughty')
local utils = require('utils')


---------------------------------------
-- MAIN
---------------------------------------

gears.timer({
    timeout = 60, --seconds
    call_now = true,
    autostart = true,

    callback = function()
        local get_bat_files_cmd = [[ find /sys/class/power_supply/ -name BAT* ]]

        awful.spawn.easy_async_with_shell(get_bat_files_cmd, function(stdout)
            local energy_now = 0
            local energy_full = 0

            for battery in stdout:lines() do
                energy_now = energy_now + tonumber(utils.file_read(battery .. '/energy_now'))
                energy_full = energy_full + tonumber(utils.file_read(battery .. '/energy_full'))
            end

            local battery_percent = math.ceil(100 * energy_now / energy_full)

            if battery_percent < 100 then
                awesome:emit_signal('battery_warning', battery_percent)
            end
        end)
    end
})
