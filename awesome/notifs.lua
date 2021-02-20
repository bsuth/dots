local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty' 

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------

local TITLE_TEXT_TEMPLATE = [[
<span size='small'>%s</span>
<span size='small'>%s</span>
]]

local TEXT_TEMPLATE = [[
<span size='small'>%s</span>
]]

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

naughty.config.defaults.timeout = 8
naughty.config.notify_callback = function(notif)
	notif.icon = beautiful.icon('systray/radio-on')

	if notif.title ~= nil then
		notif.text = TITLE_TEXT_TEMPLATE:format(notif.title, notif.text)
	else
		notif.text = TEXT_TEMPLATE:format(notif.text)
	end

	notif.title = 'Incoming Broadcast'
	return notif
end

return notifs
