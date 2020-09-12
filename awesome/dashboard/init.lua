local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local slider = require('widgets/slider')

--------------------------------------------------------------------------------
-- GRID
--------------------------------------------------------------------------------

local grid = wibox.widget({
    forced_num_rows = 12,
    forced_num_cols = 2,
    spacing = 20,
    expand = true,
    homogeneous = true,
    layout = wibox.layout.grid,
})

--------------------------------------------------------------------------------
-- SLIDERS
--------------------------------------------------------------------------------

local volume = slider({ icon = 'vol', value = 50, })
local brightness = slider({ icon = 'br', value = 50, })
local battery = slider({ icon = 'bat', value = 50, })

local sliders = wibox.widget({
    {
        {
            {
                volume,
                brightness,
                battery,
                spacing = 20,
                forced_width = 400,
                layout = wibox.layout.flex.vertical,
            },
            top = 30,
            bottom = 30,
            left = 80,
            right = 80,
            widget = wibox.container.margin,
        },
        shape = gears.shape.rounded_rect,
        bg = '#181818',
        widget = wibox.container.background,
    },
    widget = wibox.container.place,
})

-- grid:add_widget_at(sliders, 5, 1, 3, 1)

--------------------------------------------------------------------------------
-- DATETIME
--------------------------------------------------------------------------------

local time = wibox.widget({
    format = "<span color='#ff0000'>%H</span><span color='#00ff00'>%M</span>",
    font = 'Titan One 50',
    widget = awful.widget.textclock,
})

local date = wibox.widget({
    format = "<span>%a %b %d, %Y</span>",
    font = 'Titan One 15',
    widget = awful.widget.textclock,
})

local separator = wibox.widget({
    {
        {
            color = '#ff0000',
            shape = gears.shape.rounded_bar,
            forced_width = 100,
            forced_height = 5,
            widget = wibox.widget.separator,
        },
        widget = wibox.container.place,
    },
    {
        {
            markup = 'h',
            widget = wibox.widget.textbox,
        },
        widget = wibox.container.place,
    },
    {
        {
            color = '#ff0000',
            shape = gears.shape.rounded_bar,
            forced_width = 100,
            forced_height = 5,
            widget = wibox.widget.separator,
        },
        widget = wibox.container.place,
    },
    spacing = 15,
    layout = wibox.layout.fixed.horizontal,
})

local datetime = wibox.widget({
    {
        {
            {
                {
                    time,
                    widget = wibox.container.place,
                },
                {
                    date,
                    widget = wibox.container.place,
                },
                {
                    separator,
                    widget = wibox.container.place,
                },
                {
                    sliders,
                    widget = wibox.container.place,
                },
                spacing = 0,
                layout = wibox.layout.fixed.vertical,
            },
            top = 30,
            bottom = 30,
            left = 80,
            right = 80,
            widget = wibox.container.margin,
        },
        shape = gears.shape.rounded_rect,
        bg = '#181818',
        widget = wibox.container.background,
    },
    widget = wibox.container.place,
})

grid:add_widget_at(datetime, 1, 1, 6, 1)

--------------------------------------------------------------------------------
-- TABBED CONTAINERS
--------------------------------------------------------------------------------

function newtab(markup)
    return {
        {
            {
                markup = markup,
                widget = wibox.widget.textbox,
            },
            widget = wibox.container.place,
        },
        bg = '#181818',
        widget = wibox.container.background,
    }
end

local tabs_content = wibox.widget({
    {
        fill_vertical = true,
        content_fill_vertical = true,
        widget = wibox.container.place,
    },
    bg = '#ff0000',
    widget = wibox.container.background,
})

local tabs = wibox.widget({
    {
        newtab('h'),
        newtab('b'),
        spacing = 0,
        layout = wibox.layout.flex.horizontal,
    },
    tabs_content,
    layout = wibox.layout.align.vertical,
})

grid:add_widget_at(tabs, 6, 2, 6, 1)

--------------------------------------------------------------------------------
-- POPUP
--------------------------------------------------------------------------------

local popup = awful.popup({
    widget = {
        grid,
        left = 50,
        right = 50,
        top = 50,
        bottom = 50,
        widget = wibox.container.margin,
    },
    ontop = true,
    visible = false,
    bg = '#000000cc',
})

function popup:toggle()
    if not self.visible then
        self.screen = awful.screen.focused()
        self.widget.forced_width = self.screen.geometry.width
        self.widget.forced_height = self.screen.geometry.height
        self.visible = true
    else
        self.visible = false
    end
end

---------------------------------------
-- RETURN
---------------------------------------

return popup
