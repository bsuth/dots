local awful = require('awful')
local naughty = require('naughty')

----------------------------------------
-- PIE FOCUS WIDGET
----------------------------------------

local Pie = {}

function Pie:new(screen)
    local pie = wibox.widget.base.make_widget('pie_focus')
    setmetatable(pie, { __index = self })
    return pie 
end

function Pie:fit(context, width, height)
    -- Find the maximum square available
    local m = math.min(width, height)
    return m, m
end

function Pie:draw(context, cr, width, height)
    cr:move_to(0, 0)
    cr:line_to(width, height)
    cr:move_to(0, height)
    cr:line_to(width, 0)
    cr:stroke()
end