local awful = require 'awful' 
local gears = require 'gears'

local _model = require 'models/abstract'

--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

local model = _model.new({
	_modelname = 'cpu',
	percent = 0,
	warning = false,
})

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function model:update()
    awful.spawn.easy_async_with_shell(
		[[ echo $(( 100 - $(vmstat 1 2|tail -1|awk '{print $15}') )) ]],
		function(stdout)
			self.percent = tonumber(stdout)

			if self.percent > 80 then
				if not self.warning then
					self.warning = true
					self:emit_signal('warning')
				end
			elseif self.warning then
				self.warning = false
				self:emit_signal('clear_warning')
			end

			self:emit_signal('update')
		end
	)
end

--------------------------------------------------------------------------------
-- DAEMONS
--------------------------------------------------------------------------------

gears.timer({
    timeout = 20,
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
