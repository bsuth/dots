local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

local naughty = require 'naughty' 

--------------------------------------------------------------------------------
-- SLIDER
--------------------------------------------------------------------------------

local slider = {}

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function slider:set_icon(icon)
    self._icon:set_image(icon)
end

function slider:set_value(val)
    self._value = math.min(math.max(0, val), 100)
    self._progressbar:set_value(self._value)
end

function slider:shift(dval)
    self:set_value(self._value + dval)
end

function slider:scroll(_, _, button, _, _)
    if button == 4 and self.scroll_up ~= nil then
        self:scroll_up()
    elseif button == 5 and self.scroll_down ~= nil then
        self:scroll_down()
    end
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return setmetatable(slider, {
    __call = function(self, args)
        args = args or {}

        local icon = wibox.widget({
            image = args.icon,
            forced_width = 20,
            forced_height = 20,
            widget = wibox.widget.imagebox,
        })

        local progressbar = wibox.widget({
            background_color = args.bg or beautiful.colors.blacker,
            color = args.color or beautiful.colors.red,
            value = args.value or 0,
            max_value = 100,
            shape = gears.shape.rounded_bar,
            bar_shape = gears.shape.rounded_bar,
            widget = wibox.widget.progressbar,
        })

        local newslider = wibox.widget({
            {
                icon,
                widget = wibox.container.place,
            },
            {
                progressbar,
                widget = wibox.container.place,
            },
            spacing = 10,
            layout = wibox.layout.fixed.horizontal,
        })

        newslider._value = args.value or 0
        newslider._icon = icon
        newslider._progressbar = progressbar

        gears.table.crush(newslider, args, true)
        gears.table.crush(newslider, slider, true)

        newslider:connect_signal('mouse::enter', function()
            newslider:connect_signal('button::press', newslider.scroll)
        end)

        newslider:connect_signal('mouse::leave', function()
            newslider:disconnect_signal('button::press', newslider.scroll)
        end)

        if newslider.init ~= nil then
            newslider:init()
        end

        return newslider
    end,
})