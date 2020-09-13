local awful = require 'awful'
local naughty = require 'naughty'
local wibox = require 'wibox' 

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
-- HELPERS
--------------------------------------------------------------------------------

local function add(title, content)
    local head_children = head:get_children()
    table.insert(head_children, wibox.widget({
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
    head:set_children(head_children)

    local body_children = body:get_children()
    table.insert(body_children, content)
    body:set_children(body_children)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

add('a', nil)
add('b', nil)

return wibox.widget({
    head,
    body,
    fill_vertical = true,
    content_fill_vertical = true,
    layout = wibox.layout.align.vertical,
})
