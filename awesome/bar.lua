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
-- GLOBAL BUTTONS
---------------------------------------

function bar.attach(screen)
    local taglist = awful.widget.taglist({
        screen  = screen,
        filter  = awful.widget.taglist.filter.all,
        layout = {
            spacing = 12,
            layout  = wibox.layout.fixed.horizontal,
        },
        widget_template = {
            {
                {
                    id     = 'index_role',
                    widget = wibox.widget.textbox,
                },
                margins = 6,
                widget  = wibox.container.margin,
            },
            bg = '#181818',
            fg = '#e8e8e8',
            shape  = gears.shape.circle,
            widget = wibox.container.background,
            create_callback = function(self, tag, index, tags) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = index
                if tag.selected then
                    self.fg = '#181818'
                    self.bg = '#e8e8e8'
                else
                    self.fg = '#e8e8e8'
                    self.bg = '#181818'
                end
            end,
            update_callback = function(self, tag, index, tags) --luacheck: no unused args
                if tag.selected then
                    self.fg = '#181818'
                    self.bg = '#e8e8e8'
                else
                    self.fg = '#e8e8e8'
                    self.bg = '#181818'
                end
            end,
        },
    })

    local wibar = awful.wibar({
        position = 'top',
        screen = screen,
    })

    wibar:setup({
        layout = wibox.layout.flex.horizontal,
        clock,
        taglist,
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            kblayout,
            wibox.widget.systray(),
        },
    })
end

---------------------------------------
-- RETURN
---------------------------------------

return bar
