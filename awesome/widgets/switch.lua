local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local naughty = require 'naughty' 
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- SWITCH
--------------------------------------------------------------------------------

local switch = {}

--------------------------------------------------------------------------------
-- SWITCH: API
--------------------------------------------------------------------------------

function switch:fit(_, width, height)
    return width, height
end

function switch:draw(_, cr, width, height)
    local rs = math.min(width, height)

    if self._private.checked then
        cr:set_source_rgb(0, 0, 1)
        gears.shape.rounded_bar(cr, 2*rs, rs)
        cr:fill()

        cr:set_source_rgb(0, 1, 0)
        cr:move_to(2*rs, rs/2)
        cr:arc((3/2)*rs, rs/2, rs/2, 0, 2*math.pi)
    else
        cr:set_source_rgb(1, 0, 0)
        gears.shape.rounded_bar(cr, 2*rs, rs)
        cr:fill()

        cr:set_source_rgb(0, 1, 0)
        cr:move_to(rs, rs/2)
        cr:arc(rs/2, rs/2, rs/2, 0, 2*math.pi)
    end

    cr:fill()
    cr:stroke()
end

---------------------------------------
-- RETURN
---------------------------------------

return setmetatable(switch, {
    __call = function(self, args)
        local newswitch = wibox.widget.base.make_widget(nil, nil, {
            enable_properties = true,
        })

        -- Must use crush here! The table from make_widget already has a
        -- metatable set!
        gears.table.crush(newswitch._private, args or {})
        gears.table.crush(newswitch, switch, true)

        newswitch:connect_signal('button::release', function(self)
            self._private.checked = not self._private.checked
            self:emit_signal('widget::redraw_needed')
        end)

        return newswitch
    end,
})
