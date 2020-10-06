local awful = require 'awful' 
local naughty = require 'naughty' 

---------------------------------------
-- INIT
---------------------------------------

local notifier = {
    ids = { system = nil, },
    keyboard_id = 1,
}

---------------------------------------
-- KEYBOARD
---------------------------------------

function notifier:keyboard()
    local layouts = {'fcitx-keyboard-us', 'fcitx-keyboard-de', 'mozc'}

    local id = self.keyboard_id
    self.keyboard_id = (id == #layouts) and 1 or id + 1

    local keyboard_cmd = 'fcitx-remote -s' ..layouts[self.keyboard_id] 
    awful.spawn.easy_async_with_shell(keyboard_cmd, function()
        self.ids.system = naughty.notify({
            text = layouts[self.keyboard_id],
            timeout = 2,
            replaces_id = self.ids.system,
        }).id
    end)
end

---------------------------------------
-- RETURN
---------------------------------------

return notifier
