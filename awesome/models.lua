local awful = require 'awful' 
local beautiful = require 'beautiful'
local gears = require 'gears'

--------------------------------------------------------------------------------
-- BATTERY
--------------------------------------------------------------------------------

local upower = require('lgi').require('UPowerGlib')
local device = upower.Client():get_display_device()

local battery = gears.table.crush(gears.object(), {
	percent = 0,
	discharging = true,

	update = function(self)
		self.percent = device.percentage
		self.discharging = gears.table.hasitem({
			upower.DeviceState.PENDING_DISCHARGE,
			upower.DeviceState.DISCHARGING,
		}, device.state) ~= nil
		self:emit_signal('update')
	end,
})

-- battery:update()
-- device.on_notify = function()
	-- battery:update()
-- end

gears.timer {
	timeout   = 5,
    call_now  = true,
    autostart = true,
    callback  = function()
		battery:update()
    end,
}

--------------------------------------------------------------------------------
-- BRIGHTNESS
--------------------------------------------------------------------------------

local brightness = gears.table.crush(gears.object(), {
	percent = 0,

	shift = function(self, dv)
		self.percent = math.min(math.max(0, self.percent + dv), 100)
		awful.spawn.easy_async_with_shell(
			('brightnessctl set %s%%'):format(self.percent),
			function()
				self:emit_signal('update')
			end
		)
	end
})

awful.spawn.easy_async_with_shell(
    [[ echo $(( 100 * $(brightnessctl get) / $(brightnessctl max) )) ]],
    function(stdout, _, _, _)
		brightness.percent = tonumber(stdout)
		brightness:emit_signal('update')
	end
)

--------------------------------------------------------------------------------
-- VOLUME
--------------------------------------------------------------------------------

local volume = gears.table.crush(gears.object(), {
	percent = 0,
	mute = false,

	shift = function(self, dv)
		self.percent = math.min(math.max(0, self.percent + dv), 100)
		awful.spawn.easy_async_with_shell(
			('amixer sset Master %d%%'):format(self.percent),
			function()
				self.mute = not self.mute
				self:emit_signal('update', self.mute)
			end
		)
	end,

	toggle_mute = function(self)
		awful.spawn.easy_async_with_shell(
			'amixer sset Master toggle',
			function()
				self.mute = not self.mute
				self:emit_signal('update', self.mute)
			end
		)
	end
})

awful.spawn.easy_async_with_shell(
    [[ amixer sget Master | tail -n 1 | sed -E 's/.*\[([0-9]+)%\].*/\1/' ]],
    function(stdout, _, _, _)
		volume.percent = tonumber(stdout)
		volume:emit_signal('update')
	end
)

--------------------------------------------------------------------------------
-- MODELS
--------------------------------------------------------------------------------

return {
	battery = battery,
	brightness = brightness,
	volume = volume,
}
