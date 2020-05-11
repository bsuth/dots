local awful = require('awful')
local gears = require('gears')
local theme = require('theme')
local wibox = require('wibox')

---------------------------------------
-- INIT
---------------------------------------

local bar = {}

local kblayout = awful.widget.keyboardlayout()
local clock = wibox.widget.textclock()

---------------------------------------
-- TAGLIST
---------------------------------------

function taglist(widget, is_selected)
    return awful.widget.taglist({
        screen = screen,
        filter = awful.widget.taglist.filter.all,
        widget_template = {
            {
                {
                    id = 'index_role',
                    widget = wibox.widget.textbox,
                },
                margins = 10,
                widget = wibox.container.margin,
            },
            widget = wibox.container.background,

            -- Set tag widget content and colors
            create_callback = function(self, tag, index, tags)
                self:get_children_by_id('index_role')[1].markup = index
                taglist_widget_color(self, tag.selected)
            end,
            update_callback = function(self, tag, index, tags)
                taglist_widget_color(self, tag.selected)
            end,
        },
    })
end

function taglist_widget_color(widget, is_selected)
    if is_selected then
        widget.fg = '#000000'
        widget.bg = '#d8d8d8'
    else
        widget.fg = '#d8d8d8'
        widget.bg = '#000000'
    end
end

---------------------------------------
-- BAR
---------------------------------------

function bar:attach(screen)
    local wibar = awful.wibar({
        position = 'top',
        screen = screen,
    })

    wibar:setup({
        {
            {
                clock,
                layout = wibox.layout.fixed.horizontal,
            },
            {
                -- Center the taglist
                nil,
                taglist(screen),
                nil,
                expand = 'outside',
                layout = wibox.layout.align.horizontal,
            },
            {
                kblayout,
                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.align.horizontal,
        },

        -- Padding
        left = 20,
        right = 20,
        widget = wibox.container.margin,
    })
end

---------------------------------------
-- RETURN
---------------------------------------

return bar
