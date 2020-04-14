local awful = require('awful')

---------------------------------------
-- CLIENTBUFFER
---------------------------------------

local clientbuffer = {
    buffer = awful.tag.add('buffer', {
        screen = screen.fake_add(0, 0, 0, 0),
    }),
    clients = {},
}
setmetatable(clientbuffer, { __index = self })


function clientbuffer:push(client)
    local restore_screen = client.screen

    client:move_to_tag(self.buffer)
    table.insert(self.clients, client)

    awful.screen.focus(restore_screen)
end


function clientbuffer:pop()
    if #self.clients > 0 then
        local c = table.remove(self.clients)
        c:move_to_screen(awful.screen.focused())
        client.focus = c
        c:raise()
    end
end


return clientbuffer
