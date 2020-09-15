local wibox = require 'wibox' 

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
    local bar_children = bar:get_children()
    table.insert(bar_children, wibox.widget({
        {
            {
                markup = title,
                widget = wibox.widget.textbox,
            },
            widget = wibox.container.place,
        },
        bg = '#181818',
        widget = wibox.container.background,
    }))
    bar:set_children(bar_children)

    local body_children = body:get_children()
    table.insert(body_children, content)
    body:set_children(body_children)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

add('weather', head, nil)
add('mail', head, nil)
add('bluez', foot, nil)
add('wifi', foot, nil)
add('system', foot, system)

return wibox.widget({
    head,
    {
        body,
        bg = '#181818',
        widget = wibox.container.background,
    },
    foot,
    fill_vertical = true,
    content_fill_vertical = true,
    layout = wibox.layout.align.vertical,
})
