local awful = require('awful')
local naughty = require('naughty')

---------------------------------------
-- KEY HELPER
---------------------------------------

local hkeys = {}

---------------------------------------
-- API
---------------------------------------

function hkeys.create_keys(keybindings)
    local keys = {}

    for _, kb in ipairs(keybindings) do
        table.insert(keys, {
            modifiers = kb[1],
            key = kb[2],
            callback = kb[3],
        })
    end

    return keys
end

function hkeys.keypress(keys, mods, k)
    for _, key in ipairs(keys) do
        if awful.key.match(key, mods, k) then
            key.callback()
        end
    end
end

---------------------------------------
-- RETURN
---------------------------------------

return hkeys
