local awful = require 'awful' 
local gears = require 'gears'

--------------------------------------------------------------------------------
-- BATTERY
--------------------------------------------------------------------------------

local battery = gears.object()
gears.table.crush(battery, { value = 0 }, true)

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function battery:get()
    return self.value
end

function battery:update()
    awful.spawn.easy_async_with_shell([[
        ls /sys/class/power_supply/BAT*/energy_now | while read line; do
            (( energy_now += $(cat $line) ))
        done

        ls /sys/class/power_supply/BAT*/energy_full | while read line; do
            (( energy_full += $(cat $line) ))
        done

        echo $(( 100 * $energy_now / $energy_full ))
    ]], function(stdout)
        self.value = tonumber(stdout)
        self:emit_signal('update', self.value)
    end)
end

--------------------------------------------------------------------------------
-- DAEMONS
--------------------------------------------------------------------------------

gears.timer({
    timeout = 60,
    autostart = true,
    callback = function() battery:update() end,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

battery:update()
return battery
