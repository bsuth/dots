local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox' 

local popup = require 'dashboard/popup'
local notifications = require 'dashboard/tabs/notifications'
local weather = require 'dashboard/tabs/weather'
local system = require 'dashboard/tabs/system'

--------------------------------------------------------------------------------
-- HEAD
--------------------------------------------------------------------------------

local head = wibox.widget({
    spacing = 0,
    layout = wibox.layout.flex.horizontal,
})

--------------------------------------------------------------------------------
-- BODY
--------------------------------------------------------------------------------

local body = wibox.widget({
    top_only = true,
    layout = wibox.layout.stack,
})

--------------------------------------------------------------------------------
-- FOOT
--------------------------------------------------------------------------------

local foot = wibox.widget({
    spacing = 0,
    layout = wibox.layout.flex.horizontal,
})

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function add(title, bar, content)
    local tab = wibox.widget({
        {
            {
                markup = title,
                widget = wibox.widget.textbox,
            },
            widget = wibox.container.place,
        },
        bg = beautiful.colors.black,
        widget = wibox.container.background,
    })

    popup:register_hover(tab)

    tab:connect_signal('button::press', function(_, _, _, button, _, _)
        if button == 1 then
            body:set(1, content)
        end
    end)

    local bar_children = bar:get_children()
    table.insert(bar_children, tab)
    bar:set_children(bar_children)
    body:insert(1, content)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

-- add('bluez', foot, nil)
-- add('wifi', foot, nil)
add('notifications', head, notifications)
add('weather', head, weather)
add('system', foot, system)

return wibox.widget({
    {
        head,
        {
            body,
            margins = 50,
            widget = wibox.container.margin,
        },
        foot,
        fill_vertical = true,
        content_fill_vertical = true,
        layout = wibox.layout.align.vertical,
    },
    shape = gears.shape.rectangle,
    shape_border_color = beautiful.colors.cyan,
    shape_border_width = 2,
    bg = beautiful.colors.black,
    widget = wibox.container.background,
})
