local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

--------------------------------------------------------------------------------
-- SLIDER
--------------------------------------------------------------------------------

local slider = {}

local gradient = { 
    type = 'linear',
    from = { 0, 0 },
    to = { 100, 0 },
    stops = {
        { 0, '#70fabc' },
        { 1, '#78f597' },
    },
}

--------------------------------------------------------------------------------
-- SLIDER: API
--------------------------------------------------------------------------------

function slider:set(value)
    self.progressbar:set_value(value)
end

---------------------------------------
-- RETURN
---------------------------------------

return setmetatable(slider, {
    __call = function(self, args)
        local newslider = wibox.widget({
            {
                {
                    text   = string.format('%-5s', args.icon or ''),
                    widget = wibox.widget.textbox,
                },
                widget = wibox.container.place,
            },
            {
                {
                    background_color = beautiful.colors.black,
                    color = gradient,

                    value = args.value or 0,
                    max_value = 100,

                    shape = gears.shape.rounded_bar,
                    bar_shape = gears.shape.rounded_bar,
                    widget = wibox.widget.progressbar,
                },
                widget = wibox.container.place,
            },

            layout = wibox.layout.fixed.horizontal,
        })

        return setmetatable(newslider, { __index = self })
    end
})
