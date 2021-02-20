local awful = require 'awful' 
local _model = require 'models/abstract'

--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

local LAYOUTS = { 'fcitx-keyboard-us', 'mozc' }

local model = _model.new({
	_modelname = 'kb_layout',
	layout = 1,
	layout_name = 'fcitx-keyboard-us',
})

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function model:next()
    local layout = self.layout == #LAYOUTS and 1 or (self.layout + 1)

    awful.spawn.easy_async_with_shell(([[
        fcitx-remote -s %s
    ]]):format(LAYOUTS[layout]), function(_, _, _, exit_code)
        if exit_code == 0 then
            self.layout = layout
			self.layout_name = LAYOUTS[self.layout]
			self:emit_signal('update')
        end
    end)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return model
