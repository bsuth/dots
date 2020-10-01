local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

local volume = require 'singletons/volume'
local brightness = require 'singletons/brightness'
local battery = require 'singletons/battery'

local tab_notifications = require 'apps/dashboard/tab_notifications'
local tab_weather = require 'apps/dashboard/tab_weather'

local popup = require 'apps/dashboard/popup'
local dial = require 'widgets/dial' 

--------------------------------------------------------------------------------
-- DATETIME + DIALS
--------------------------------------------------------------------------------

local time = wibox.widget({
    {
        format = ("<span color='%s'>%%H</span><span color='%s'>%%M</span>"):format(
            beautiful.colors.white, beautiful.colors.cyan
        ),
        font = 'Titan One 50',
        widget = wibox.widget.textclock,
    },
    widget = wibox.container.place,
})

local date = wibox.widget({
    {
        format = "<span>%a %b %d, %Y</span>",
        widget = wibox.widget.textclock,
    },
    widget = wibox.container.place,
})

local separator = wibox.widget({
    {
        {
            {
                color = beautiful.colors.cyan,
                shape = gears.shape.rounded_bar,
                forced_width = 100,
                forced_height = 5,
                widget = wibox.widget.separator,
            },
            widget = wibox.container.place,
        },
        {
            {
                image = beautiful.icon('apps/cs-date-time.svg'),
                forced_width = 30,
                forced_height = 30,
                widget = wibox.widget.imagebox,
            },
            widget = wibox.container.place,
        },
        {
            {
                color = beautiful.colors.cyan,
                shape = gears.shape.rounded_bar,
                forced_width = 100,
                forced_height = 5,
                widget = wibox.widget.separator,
            },
            widget = wibox.container.place,
        },
        spacing = 15,
        layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
})

local volume_dial = wibox.widget({
    forced_width = 70,
    forced_height = 70,

    icon = beautiful.icon('apps/cs-sound.svg'),
    color = beautiful.colors.green,
    percent = volume:get(),

    onscrollup = function(self) volume:shift(5) end,
    onscrolldown = function(self) volume:shift(-5) end,

    widget = dial,
})

volume:connect_signal('update', function()
    volume_dial.percent = volume:get()
    volume_dial:emit_signal('widget::redraw_needed')
end)

local brightness_dial = wibox.widget({
    forced_width = 70,
    forced_height = 70,

    icon = beautiful.icon('apps/display-brightness.svg'),
    color = beautiful.colors.yellow,
    percent = brightness:get(),

    onscrollup = function(self) brightness:shift(5) end,
    onscrolldown = function(self) brightness:shift(-5) end,

    widget = dial,
})

brightness:connect_signal('update', function()
    brightness_dial.percent = brightness:get()
    brightness_dial:emit_signal('widget::redraw_needed')
end)

local battery_dial = wibox.widget({
    forced_width = 70,
    forced_height = 70,

    icon = beautiful.icon('devices/battery.svg'),
    color = beautiful.colors.red,
    percent = battery:get(),

    widget = dial,
})

battery:connect_signal('update', function()
    battery_dial.percent = battery:get()
    battery.icon = battery:get('status_icon')
    brightness_dial:emit_signal('widget::redraw_needed')
end)

local dials = wibox.widget({
    {
        {
            {
                volume_dial,
                brightness_dial,
                spacing = 50,
                layout = wibox.layout.flex.horizontal,
            },
            {
                battery_dial,
                widget = wibox.container.place,
            },
            layout = wibox.layout.flex.vertical,
        },
        top = 10,
        widget = wibox.container.margin,
    },
    widget = wibox.container.place,
})

local datetime_dials = wibox.widget({
    {
        {
            {
                time,
                date,
                {
                    separator,
                    top = 10,
                    widget = wibox.container.margin,
                },
                dials,
                layout = wibox.layout.fixed.vertical,
            },
            margins = 50,
            widget = wibox.container.margin,
        },
        shape = gears.shape.circle,
        shape_border_color = beautiful.colors.cyan,
        shape_border_width = 5,
        bg = beautiful.colors.black,
        widget = wibox.container.background,
    },
    widget = wibox.container.place,
})

--------------------------------------------------------------------------------
-- TABS
--------------------------------------------------------------------------------

local tabs_head = wibox.widget({
    spacing = 0,
    layout = wibox.layout.flex.horizontal,
})

local tabs_body = wibox.widget({
    top_only = true,
    layout = wibox.layout.stack,
})

local tabs_foot = wibox.widget({
    spacing = 0,
    layout = wibox.layout.flex.horizontal,
})

local tabs = wibox.widget({
    {
        tabs_head,
        {
            tabs_body,
            margins = 50,
            widget = wibox.container.margin,
        },
        tabs_foot,
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

local function addTab(title, bar, content)
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
            tabs_body:set(1, content)
        end
    end)

    local bar_children = bar:get_children()
    table.insert(bar_children, tab)
    bar:set_children(bar_children)
    tabs_body:insert(1, content)
end

--------------------------------------------------------------------------------
-- RETURN
--
-- Note: Return the popup here, since we only need to access the popup's toggle
-- method externally.
--------------------------------------------------------------------------------

addTab('notifications', tabs_head, tab_notifications)
addTab('weather', tabs_head, tab_weather)

popup:set(wibox.widget({
    {
        datetime_dials,
        tabs,
        spacing = 200,
        layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
}))

return popup
