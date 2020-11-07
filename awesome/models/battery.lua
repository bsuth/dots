local beautiful = require 'beautiful' 
local gears = require 'gears'

local upower = require('lgi').require('UPowerGlib')

local _model = require 'models/abstract'

--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

local device = upower.Client():get_display_device()

local model = _model.new({
	_modelname = 'battery',
	percent = device.percentage,
	discharging = true,
	warning = false,
    icon = beautiful.icon('battery-charging'),
})

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function model:update()
	self.percent = device.percentage
	self.discharging = gears.table.hasitem({
		upower.DeviceState.PENDING_DISCHARGE,
		upower.DeviceState.DISCHARGING,
	}, device.state) ~= nil

	if self.percent < 20 and self.discharging then
		if not self.warning then
			self.warning = true
			self.icon = beautiful.icon('battery-warning')
			self:emit_signal('warning')
		end
	else
		self.icon = self.discharging and
			beautiful.icon('battery-discharging') or
			beautiful.icon('battery-charging')

		if self.warning then
			self.warning = false
			self:emit_signal('clear_warning')
		end
	end

	self:emit_signal('update')
end

--------------------------------------------------------------------------------
-- DAEMONS
--------------------------------------------------------------------------------

-- TODO: Get rid of the gears.timer and replace with the line below. The timer
-- is only there because for some reason on_notify is not actually working.
-- device.on_notify = model.update

gears.timer({
    timeout = 10,
    call_now = true,
    autostart = true,
    callback = function()
		model:update()
	end,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return model
