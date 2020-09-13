local gears = require 'gears' 
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- SWITCH
--------------------------------------------------------------------------------

local switch = {}

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function switch:fit(_, width, height)
    local m = math.min(width, height)
    return 2*m, m
end

function switch:draw(_, cr, width, height)
    local m = math.min(width, height)

    if self.checked then
        cr:set_source_rgb(0, 0, 1)
        gears.shape.rounded_bar(cr, 2*m, m)
        cr:fill()

        cr:set_source_rgb(0, 1, 0)
        cr:move_to(2*m, m/2)
        cr:arc((3/2)*m, m/2, m/2, 0, 2*math.pi)
    else
        cr:set_source_rgb(1, 0, 0)
        gears.shape.rounded_bar(cr, 2*m, m)
        cr:fill()

        cr:set_source_rgb(0, 1, 0)
        cr:move_to(m, m/2)
        cr:arc(m/2, m/2, m/2, 0, 2*math.pi)
    end

    cr:fill()
    cr:stroke()
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return setmetatable(switch, {
    __call = function(self)
        local newswitch = wibox.widget.base.make_widget(nil, nil, {
            enable_properties = true,
        })

        -- Must use crush here! The table from make_widget already has a
        -- metatable set!
        gears.table.crush(newswitch, switch, true)

        newswitch:connect_signal('button::release', function(self)
            self.checked = not self.checked
            self:emit_signal('widget::redraw_needed')
        end)

        return newswitch
    end,
})
