local beautiful = require 'beautiful'
local wibox = require 'wibox' 

local popup = require 'dashboard/popup'
local system = require 'dashboard/tabs/system'
local weather = require 'dashboard/tabs/weather'

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

-- add('weather', head, nil)
-- add('mail', head, nil)
-- add('bluez', foot, nil)
-- add('wifi', foot, nil)
add('weather', head, weather)
add('system', foot, system)

return wibox.widget({
    head,
    {
        body,
        bg = beautiful.colors.black,
        widget = wibox.container.background,
    },
    foot,
    fill_vertical = true,
    content_fill_vertical = true,
    layout = wibox.layout.align.vertical,
})
