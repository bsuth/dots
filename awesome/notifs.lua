local awful = require 'awful' 
local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty' 

--------------------------------------------------------------------------------
-- NOTIFS
--------------------------------------------------------------------------------

local notifs = gears.table.crush(gears.object(), {
	stack = {},

	push = function(self, notif)
		table.insert(self.stack, notifs)
		self:emit_signal('notif::push', notifs)
	end,
})

naughty.config.notify_callback = function(notif)
	notif.icon = beautiful.icon('radio-on')
    notif.text = ([[
<span size='medium' weight='bold'>Incoming Broadcast</span>
<span size='small'>%s</span>
	]]):format(notif.text)
	return notif
end

return notifs
