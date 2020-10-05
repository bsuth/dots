local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears'

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------

local battery = gears.object()

local _private = {
    value = 0,
    status_icon = '',
}

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function battery:get(param)
    return param and _private[param] or _private.value
end

function battery:update()
    awful.spawn.easy_async_with_shell([[
        ls /sys/class/power_supply/BAT*/status | while read line; do
            if [ "$(cat $line)" = "Discharging" ]; then
                echo 'devices/battery.svg'
                exit 0
            elif [ "$(cat $line)" = "Charging" ]; then
                echo 'apps/cs-power.svg'
                exit 0
            fi
        done
    ]], function(stdout)
        _private.status_icon = beautiful.icon(stdout:gsub('%s+', ''))
        self:emit_signal('update')
    end)

    awful.spawn.easy_async_with_shell([[
        ls /sys/class/power_supply/BAT*/energy_now | while read line; do
            (( energy_now += $(cat $line) ))
        done

        ls /sys/class/power_supply/BAT*/energy_full | while read line; do
            (( energy_full += $(cat $line) ))
        done

        echo $(( 100 * $energy_now / $energy_full ))
    ]], function(stdout)
        _private.value = tonumber(stdout)
        self:emit_signal('update')
    end)
end

--------------------------------------------------------------------------------
-- DAEMONS
--------------------------------------------------------------------------------

gears.timer({
    timeout = 5,
    autostart = true,
    callback = function() battery:update() end,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

battery:update()
return battery
