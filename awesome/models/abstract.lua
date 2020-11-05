local gears = require 'gears'
local naughty = require 'naughty'

--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

local model = {
	_modelname = 'abstract',
}

local model_mt = {
	__index = model,
}

--------------------------------------------------------------------------------
-- FUNCTIONS
--------------------------------------------------------------------------------

function model.new(t)
	t = gears.table.crush(gears.object(), t)
	setmetatable(t, model_mt)

	return setmetatable({}, {
		__index = function(_, k)
			if t[k] == nil then
				naughty.notify({text = ([[
					key does exist on model
					%s.%s
				]]):format(t._modelname, k)})
			end

			return t[k]
		end,

		__newindex = function(_, k, v)
			if t[k] == nil then
				if type(v) == 'function' then
					t[k] = v
				else
					naughty.notify({text = ([[
						cannot add new model attribute.
						%s.%s = %s
					]]):format(t._modelname, k, v)})
				end
			elseif type(t[k]) ~= type(v) then
				naughty.notify({text = ([[
					cannot change type of model attribute.
					%s.%s (%s => %s)
				]]):format(t._modelname, k, t[k], v)})
			else
				t[k] = v
			end
		end,

		__pairs = function()
			return function(_, k)
				return next(t, k)
			end
		end,

		__len = function()
			return #t
		end,
	})
end

--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------

return model
