local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function add(args)
    local widget = wibox.widget({
        {
            {
                forced_width = 100,
                image = args.icon,
                widget = wibox.widget.imagebox,
            },
            {
                markup = args.label,
                align = 'center',
                widget = wibox.widget.textbox,
            },
            fill_space = false,
            layout = wibox.layout.fixed.vertical,
        },
        widget = wibox.container.place,
    })

    widget:connect_signal('button::press', args.callback)
    return widget
end

--------------------------------------------------------------------------------
-- SYSTEM
--------------------------------------------------------------------------------

local system = wibox.widget({
    {
        add({
            label = 'logout',
            icon = beautiful.icon('apps/system-log-out.svg'),
            callback = function() awful.quit() end,
            test = true,
        }),
        add({
            label = 'suspend',
            icon = beautiful.icon('apps/system-suspend.svg'),
            callback = function() awful.spawn('systemctl suspend') end,
        }),
        add({
            label = 'reboot',
            icon = beautiful.icon('apps/system-reboot.svg'),
            callback = function() awful.spawn('reboot') end,
        }),
        add({
            label = 'poweroff',
            icon = beautiful.icon('apps/system-shutdown.svg'),
            callback = function() awful.spawn('poweroff') end,
        }),
        spacing = 20,
        layout = wibox.layout.flex.horizontal,
    },
    widget = wibox.container.place,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return system
