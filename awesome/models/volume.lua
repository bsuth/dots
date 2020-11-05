local awful = require 'awful' 

local _model = require 'models/abstract'

--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

local model = _model.new({
	_modelname = 'volume',
	percent = 0,
	mute = false,
})

awful.spawn.easy_async_with_shell(
    [[ amixer sget Master | tail -n 1 | sed -E 's/.*\[([0-9]+)%\].*/\1/' ]],
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
    awful.spawn(('amixer sset Master %d%%'):format(self.percent))
    self:emit_signal('update')
end

function model:toggle()
    self.mute = not self.mute
    awful.spawn('amixer sset Master toggle')
    self:emit_signal('toggle', self.mute)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return model
