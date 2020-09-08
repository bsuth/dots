local awful = require('awful')
local naughty = require('naughty')

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------

local history = {
	screens = {},
	max_size = 20,
}

awful.screen.connect_for_each_screen(function(s)
	local stack = {}

	history.screens[s.index] = {
		stack = stack, 
		stack_pointer = 1,
	}

	for _, t in ipairs(s.tags) do
		if t == s.selected_tag then
			table.insert(stack, 1, t)
		else
			table.insert(stack, t)
		end
	end

	s:connect_signal('tag::history::update', function()
		local stack_pointer = history.screens[s.index].stack_pointer

		if s.history_event then
			s.history_event = false
		elseif s.selected_tag ~= stack[stack_pointer] then
			table.insert(stack, 1, s.selected_tag)
			history.screens[s.index].stack_pointer = 1

			if #stack > history.max_size then
				table.remove(stack)
			end
		end
	end)
end)

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function history:shift(offset)
	local s = awful.screen.focused()
	local stack = self.screens[s.index].stack
	local stack_pointer = self.screens[s.index].stack_pointer

	s.history_event = true

	stack_pointer = math.min(math.max(1, stack_pointer + offset), #stack)
	self.screens[s.index].stack_pointer = stack_pointer

	stack[stack_pointer]:view_only()
end

function history:back()
	self:shift(1)
end

function history:forward()
	self:shift(-1)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return history
