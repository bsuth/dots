
local awful = require('awful')


---------------------------------------
-- INIT
---------------------------------------

local clientbuffer = {
    buffer = awful.tag.add('buffer', {
        screen = screen.fake_add(0, 0, 0, 0),
    }),
    clients = {},
}


---------------------------------------
-- PUBLIC
---------------------------------------

function clientbuffer.push(client)
    local restore_screen = client.screen

    client:move_to_tag(clientbuffer.buffer)
    table.insert(clientbuffer.clients, client)

    awful.screen.focus(restore_screen)
end


function clientbuffer.pop()
    if #clientbuffer.clients > 0 then
        local client = table.remove(clientbuffer.clients)
        client:move_to_screen(awful.screen.focused())
    end
end


---------------------------------------
-- RETURN
---------------------------------------

return clientbuffer

