local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears'

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------

local LOW_THRESHOLD = 20

local battery = gears.object()

local _private = {
    value = 0,
	charging = true,
	warning = false,
    icon = '',
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
				exit 1
			fi
		done
	]], function(stdout, _, _, exitcode)
		_private.charging = (exitcode == 0)
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

        if _private.value < LOW_THRESHOLD and not _private.charging then
			_private.icon = beautiful.icon('battery-warning')

			if not _private.warning then
				_private.warning = true
				self:emit_signal('warning_low')
			end
		else
			_private.icon = _private.charging and
				beautiful.icon('battery-charging') or
				beautiful.icon('battery-discharging')

			if _private.warning then
				_private.warning = false
				self:emit_signal('no_warning')
			end
        end

        self:emit_signal('update')
    end)
end

--------------------------------------------------------------------------------
-- DAEMONS
--------------------------------------------------------------------------------

gears.timer({
    timeout = 60,
    call_now = true,
    autostart = true,
    callback = function() battery:update() end,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return battery
