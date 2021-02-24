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

battery:update()
device.on_notify = function()
	battery:update()
end

--------------------------------------------------------------------------------
-- BRIGHTNESS
--------------------------------------------------------------------------------

local brightness = gears.table.crush(gears.object(), {
	percent = 0,

	set = function(self, percent)
		self.percent = math.min(math.max(0, percent), 100)
		awful.spawn.easy_async_with_shell(
			('brightnessctl set %s%%'):format(self.percent),
			function()
				self:emit_signal('update')
			end
		)
	end,
})

awful.spawn.easy_async_with_shell(
    [[ echo $(( 100 * $(brightnessctl get) / $(brightnessctl max) )) ]],
    function(stdout, _, _, _)
		brightness.percent = tonumber(stdout)
		brightness:emit_signal('update')
	end
)

--------------------------------------------------------------------------------
-- DISK
--------------------------------------------------------------------------------

local disk = gears.table.crush(gears.object(), {
	percent = 0,

	update = function(self)
		awful.spawn.easy_async_with_shell(
			[[ df --output='pcent' / | tail -n 1 | sed 's/%//' ]],
			function(stdout)
				self.percent = tonumber(stdout)
				self:emit_signal('update')
			end
		)
	end,
})

gears.timer {
	timeout = 60,
	call_now = true,
	autostart = true,
	callback = function()
		disk:update()
    end,
}

--------------------------------------------------------------------------------
-- KB LAYOUT
--------------------------------------------------------------------------------

local kb_layout = gears.table.crush(gears.object(), {
	index = 1,
	list = {
		'fcitx-keyboard-us',
		'mozc',
		-- 'fcitx-keyboard-de',
	},

	cycle = function(self)
		self.index = (self.index == #self.list) and 1 or (self.index + 1)
		awful.spawn.easy_async_with_shell(
			'fcitx-remote -s '..self.list[self.index],
			function() self:emit_signal('update') end
		)
	end,
})

--------------------------------------------------------------------------------
-- RAM
--------------------------------------------------------------------------------

local ram = gears.table.crush(gears.object(), {
	percent = 0,

	update = function(self)
		awful.spawn.easy_async_with_shell(
			[[ free | grep Mem | awk '{print $3/$2 * 100}' ]],
			function(stdout)
				self.percent = tonumber(stdout)
				self:emit_signal('update')
			end
		)
	end,
})

gears.timer {
	timeout = 5,
	call_now = true,
	autostart = true,
	callback = function()
		ram:update()
    end,
}

--------------------------------------------------------------------------------
-- VOLUME
--------------------------------------------------------------------------------

local volume = gears.table.crush(gears.object(), {
	percent = 0,
	mute = false,

	set = function(self, percent)
		self.percent = math.min(math.max(0, percent), 100)
		awful.spawn.easy_async_with_shell(
			('amixer sset Master %d%%'):format(self.percent),
			function()
				self:emit_signal('update')
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
	end,
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
	disk = disk,
	kb_layout = kb_layout,
	ram = ram,
	volume = volume,
}
