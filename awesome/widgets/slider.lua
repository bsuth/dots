local gears = require 'gears' 
local naughty = require 'naughty' 
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- SLIDER
--------------------------------------------------------------------------------

local slider = {}

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

---------------------------------------
-- RETURN
---------------------------------------

return setmetatable(slider, {
    __call = function(self, args)
        local newslider = wibox.widget({
            {
                {
                    text = string.format('%-5s', args and args.icon or ''),
                    widget = wibox.widget.textbox,
                },
                widget = wibox.container.place,
            },
            {
                {
                    background_color = '#080808',
                    color = '#ff0000',
                    value = args and args.value or 0,
                    max_value = 100,
                    shape = gears.shape.rounded_bar,
                    bar_shape = gears.shape.rounded_bar,
                    widget = wibox.widget.progressbar,
                },
                widget = wibox.container.place,
            },

            layout = wibox.layout.fixed.horizontal,
        })

        gears.table.crush(newslider._private, args or {}, true)
        gears.table.crush(newslider, slider, true)

        return newslider
    end,
})
