local awful = require 'awful'
local gears = require 'gears'
local wibox = require 'wibox'

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function button(icon, click)
    local button = wibox.widget({
        markup = icon,
        widget = wibox.widget.textbox,
    })

    button:connect_signal('button::press', click)

    return button
end

--------------------------------------------------------------------------------
-- SYSTEM
--------------------------------------------------------------------------------

local system = wibox.widget({
    {
        button('reboot', function() awful.spawn('reboot') end),
        button('logout', function() awful.quit() end),
        layout = wibox.layout.flex.horizontal,
    },
    {
        button('sleep', function() awful.spawn('systemctl suspend') end),
        button('shutdown', function() awful.spawn('poweroff') end),
        layout = wibox.layout.flex.horizontal,
    },
    layout = wibox.layout.flex.vertical,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return system
