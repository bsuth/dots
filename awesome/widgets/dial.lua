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
    local thickness = m / 5

    local bg = beautiful.hex2rgb(beautiful.colors.blacker)
    cr:set_source_rgb(bg[1], bg[2], bg[3])
    gears.shape.arc(cr, m, m, thickness, 0, 2*math.pi)
    cr:fill()

    if self.percent and self.percent > 0 then
        local fg = beautiful.hex2rgb(self.color or beautiful.colors.green)
        cr:set_source_rgb(fg[1], fg[2], fg[3])

        -- 98 is close enough so round (plus, battery percent never reaches
        -- 100% on some computers)
        if self.percent < 98 then
            -- If (theta_end - theta_start) is too small, then cairo will shift
            -- theta_end slightly in an attempt to draw something over nothing.
            -- This causes a sort of "jump" when the percent gets to low, so to
            -- avoid this, we always draw a small circle centered at theta_end
            -- to mimic the rounded end, and just draw a rounded start for the
            -- actual arc.
            cr:arc(m / 2, thickness / 2, thickness / 2, 0, 2*math.pi)
            cr:fill()

            local theta_end = 3 * math.pi / 2
            local theta_start = theta_end - (self.percent / 100) * (2 * math.pi)
            gears.shape.arc(cr, m, m, thickness, theta_start, theta_end, true, false)
        else
            gears.shape.arc(cr, m, m, thickness, 0, 2 * math.pi)
        end

        cr:fill()
    end

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

function dial:onscroll(_, _, button, _, _)
    if button == 4 and self.onscrollup~= nil then
        self:onscrollup()
        self:emit_signal('widget::redraw_needed')
    elseif button == 5 and self.onscrolldown ~= nil then
        self:onscrolldown()
        self:emit_signal('widget::redraw_needed')
    end
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

        newdial:connect_signal('button::press', dial.onscroll)
        return newdial
    end,
})
