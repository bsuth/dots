

local awful = require('awful')
local naughty = require('naughty')


---------------------------------------
-- INIT
---------------------------------------

local _this = {
    buffer = awful.tag.add('buffer', {
        screen = screen.fake_add(0, 0, 0, 0),
    }),
    clients = {},
}


---------------------------------------
-- PUBLIC
---------------------------------------

function _this.push(client)
    local restore_screen = client.screen

    client:move_to_tag(_this.buffer)
    table.insert(_this.clients, client)

    awful.screen.focus(restore_screen)
end


function _this.pop()
    if #_this.clients > 0 then
        local client = table.remove(_this.clients)
        client:move_to_screen(awful.screen.focused())
    end
end


---------------------------------------
-- RETURN
---------------------------------------

return _this

