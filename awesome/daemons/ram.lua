
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
        local get_ram_usage = [[ free | grep Mem | awk '{print $4/$2 * 100}' ]]

        awful.spawn.easy_async_with_shell(get_ram_usage, function(stdout)
            local ram_usage = math.floor(tonumber(stdout))
            awesome:emit_signal('ram_warning', stdout)
        end)
    end
})
