local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- DIAL
--------------------------------------------------------------------------------

local dial = {}

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function dial:fit(_, width, height)
    local m = math.min(width, height)
    return m, m
end

function dial:draw(_, cr, width, height)
    local m = math.min(width, height)

    local bg = beautiful.hex2rgb(beautiful.colors.blacker)
    cr:set_source_rgb(bg[1], bg[2], bg[3])
    gears.shape.arc(cr, m, m, m / 5, 0, 2*math.pi)
    cr:fill()

    local fg = beautiful.hex2rgb(self.color or beautiful.colors.green)
    cr:set_source_rgb(fg[1], fg[2], fg[3])
    local theta_start = 3 * (math.pi / 2) - ((self.percent or 0) / 100) * (2 * math.pi)
    local theta_end = 3 * math.pi / 2
    gears.shape.arc(cr, m, m, m / 5, theta_start, theta_end, true, true)
    cr:fill()

    cr:stroke()
end

function dial:layout(_, width, height)
    local m = math.min(width, height)
    local icon_padding = 10
    local icon_offset = m / 5 + icon_padding
    local icon_size = m - (2 * icon_offset)

    return {
        wibox.widget.base.place_widget_at(wibox.widget({
            {
                image = self.icon,
                widget = wibox.widget.imagebox,
            },
            widget = wibox.container.place,
        }), icon_offset, icon_offset, icon_size, icon_size),
    }
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return setmetatable(dial, {
    __call = function(self)
        local newdial = wibox.widget.base.make_widget(nil, nil, {
            enable_properties = true,
        })

        -- Must use crush here! The table from make_widget already has a
        -- metatable set!
        gears.table.crush(newdial, dial, true)
        return newdial
    end,
})
