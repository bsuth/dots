local awful = require 'awful' 
local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty' 

--------------------------------------------------------------------------------
-- NOTIFICATIONS
--------------------------------------------------------------------------------

local notifications = gears.table.crush(gears.object(), {
	stack = {},

	push = function(self, notification)
		table.insert(self.stack, notifications)
		self:emit_signal('notification::push', notifications)
	end,
})

naughty.config.notify_callback = function(notification)
    notification.text = ([[
<span size='medium' weight='bold'>  Broadcast Received  </span>
<span size='small'>  %s  </span>
	]]):format(notification.text)
	notifications:push(notification)
	return nil
end
