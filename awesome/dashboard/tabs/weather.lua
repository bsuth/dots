local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'

local popup = require 'dashboard/popup'
local weather = require 'singletons/weather'

--------------------------------------------------------------------------------
-- UNIT PICKER
--------------------------------------------------------------------------------

local units = 'c'

local unit_C = wibox.widget({
    {
        {
            markup = 'C',
            font = 'Titan One 20',
            widget = wibox.widget.textbox,
        },
        top = 10,
        bottom = 10,
        left = 25,
        right = 25,
        widget = wibox.container.margin,
    },
    shape = gears.shape.rectangle,
    shape_border_color = beautiful.colors.cyan,
    shape_border_width = 5,
    widget = wibox.container.background,
})

local unit_F = wibox.widget({
    {
        {
            markup = 'F',
            font = 'Titan One 20',
            widget = wibox.widget.textbox,
        },
        top = 10,
        bottom = 10,
        left = 25,
        right = 25,
        widget = wibox.container.margin,
    },
    shape = gears.shape.rectangle,
    shape_border_color = beautiful.colors.dark_grey,
    shape_border_width = 5,
    widget = wibox.container.background,
})

popup:register_hover(unit_C)
popup:register_hover(unit_F)

local unit_picker = wibox.widget({
    {
        unit_C,
        unit_F,
        layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
})

--------------------------------------------------------------------------------
-- WEATHER REPORT WIDGETS
--------------------------------------------------------------------------------

local icon = wibox.widget({
    markup = '',
    font = 'Weather Icons 120',
    widget = wibox.widget.textbox,
})

local maxmin = wibox.widget({
    markup = '',
    font = 'Titan One 20',
    align = 'center',
    widget = wibox.widget.textbox,
})

local temp = wibox.widget({
    markup = '',
    font = 'Titan One 20',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
})

local feel = wibox.widget({
    markup = '',
    font = 'Titan One 20',
    align = 'center',
    widget = wibox.widget.textbox,
})

local humidity = wibox.widget({
    markup = '',
    font = 'Titan One 20',
    align = 'center',
    widget = wibox.widget.textbox,
})

--------------------------------------------------------------------------------
-- FORECAST BAR
--------------------------------------------------------------------------------

local forecast = wibox.widget({
    spacing = 30,
    layout = wibox.layout.fixed.horizontal,
})

local forecast_children = {}
local forecast_children_widgets = {}

for i = 1, 8 do
    local time = wibox.widget({
        markup = tostring(3 * (i - 1)) .. ':00',
        font = 'Titan One 10',
        align = 'center',
        widget = wibox.widget.textbox,
    })

    local icon = wibox.widget({
        markup = '',
        font = 'Weather Icons 20',
        align = 'center',
        widget = wibox.widget.textbox,
    })

    local temp = wibox.widget({
        markup = '',
        font = 'Titan One 12',
        align = 'center',
        widget = wibox.widget.textbox,
    })

    table.insert(forecast_children, {
        icon = icon,
        temp = temp,
    })
    
    table.insert(forecast_children_widgets, wibox.widget({
        time,
        icon,
        temp,
        layout = wibox.layout.fixed.vertical,
    }))
end

forecast:set_children(forecast_children_widgets)

--------------------------------------------------------------------------------
-- WEATHER UPDATE
--------------------------------------------------------------------------------

local function update()
    icon.markup = weather:get('icon')
    maxmin.markup = ('%d - %d'):format(
        weather:get('min' .. units),
        weather:get('max' .. units)
    )

    temp.markup = string.format('%3d', weather:get('temp' .. units))
    feel.markup = string.format('%3d', weather:get('feel' .. units))
    humidity.markup = string.format('%3d', weather:get('humidity'))

    for i, forecast_child in ipairs(forecast_children) do
        forecast_child.icon.markup = weather:get('icon', i)
        forecast_child.temp.markup = weather:get('temp' .. units, i)
    end
end

unit_C:connect_signal('button::press', function(_, _, _, button, _, _)
    if button == 1 then
        unit_C.shape_border_color = beautiful.colors.cyan
        unit_F.shape_border_color = beautiful.colors.dark_grey

        units = 'c'
        update()
    end
end)

unit_F:connect_signal('button::press', function(_, _, _, button, _, _)
    if button == 1 then
        unit_C.shape_border_color = beautiful.colors.dark_grey
        unit_F.shape_border_color = beautiful.colors.cyan

        units = 'f'
        update()
    end
end)

weather:connect_signal('update', update)

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return wibox.widget({
    {
        unit_picker,
        {
            {
                {
                    {
                        icon,
                        maxmin,
                        layout = wibox.layout.fixed.vertical,
                    },
                    right = 50,
                    widget = wibox.container.margin,
                },
                {
                    {
                        {
                            markup = '',
                            font = 'Weather Icons 20',
                            widget = wibox.widget.textbox,
                        },
                        {
                            markup = '',
                            font = 'Weather Icons 20',
                            widget = wibox.widget.textbox,
                        },
                        {
                            markup = '',
                            font = 'Weather Icons 20',
                            widget = wibox.widget.textbox,
                        },
                        layout = wibox.layout.flex.vertical,
                    },
                    {
                        temp,
                        feel,
                        humidity,
                        layout = wibox.layout.flex.vertical,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                spacing = 50,
                layout = wibox.layout.fixed.horizontal,
            },
            widget = wibox.container.place,
        },
        forecast,
        spacing = 50,
        layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
})
