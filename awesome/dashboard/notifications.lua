local gears = require 'gears' 
local wibox = require 'wibox' 

local switch = require 'widgets/switch' 

--------------------------------------------------------------------------------
-- HEAD
--------------------------------------------------------------------------------

local head = wibox.widget({
    {
        markup = 'Notifications',
        widget = wibox.widget.textbox,
    },
    nil,
    {
        checked = false,
        forced_height = 20,
        widget = switch,
    },
    layout = wibox.layout.align.horizontal,
})

--------------------------------------------------------------------------------
-- BODY
--------------------------------------------------------------------------------

local body = wibox.widget({
    spacing = 10,
    layout = wibox.layout.flex.vertical,
})

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function add(title, description)
    local body_children = body:get_children()
    table.insert(body_children, wibox.widget({
        {
            {
                {
                    markup = title,
                    widget = wibox.widget.textbox,
                },
                {
                    markup = description,
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.flex.vertical,
            },
            top = 10,
            bottom = 10,
            left = 10,
            right = 10,
            widget = wibox.container.margin,
        },
        shape = gears.shape.rounded_rect,
        bg = '#080808',
        widget = wibox.container.background,
    }))
    body:set_children(body_children)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

-- TODO: REMOVE DUMMY NOTIFICATIONS
add('Dummy', 'This is a dummy message')
add('Change Me', 'dummy message 2')

return wibox.widget({
    {
        {
            {
                head,
                body,
                spacing = 20,
                layout = wibox.layout.fixed.vertical,
            },
            top = 20,
            bottom = 20,
            left = 20,
            right = 20,
            widget = wibox.container.margin,
        },
        shape = gears.shape.rectangle,
        shape_border_color = '#d8d8d8',
        shape_border_width = 2,
        bg = '#181818',
        forced_width = 500,
        widget = wibox.container.background,
    },
    widget = wibox.container.place,
})
