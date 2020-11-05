local awful = require 'awful' 

local _model = require 'models/abstract'

--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

local model = _model.new({
	_modelname = 'brightness',
	percent = 0,
})

awful.spawn.easy_async_with_shell(
    [[ echo $(( 100 * $(brightnessctl get) / $(brightnessctl max) )) ]],
    function(stdout, _, _, _)
		model.percent = tonumber(stdout)
		model:emit_signal('update')
	end
)

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function model:shift(dv)
    self.percent = math.min(math.max(0, self.percent + dv), 100)
    awful.spawn(('brightnessctl set %s%%'):format(self.percent))
    self:emit_signal('update')
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return model
