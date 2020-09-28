local beautiful = require 'beautiful'
local gears = require 'gears' 
local wibox = require 'wibox' 

--------------------------------------------------------------------------------
-- SWITCH
--------------------------------------------------------------------------------

local switch = {}

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

local function _hex2rgb(hex)
    hex = hex:gsub('#','')
    return {
        tonumber('0x' .. hex:sub(1,2)) / 255,
        tonumber('0x' .. hex:sub(3,4)) / 255,
        tonumber('0x' .. hex:sub(5,6)) / 255,
    }
end

function switch:fit(_, width, height)
    local m = math.min(width, height)
    return 2*m, m
end

function switch:draw(_, cr, width, height)
    local m = math.min(width, height)

    local bg = _hex2rgb(beautiful.colors.blacker)
    cr:set_source_rgb(bg[1], bg[2], bg[3])
    gears.shape.rounded_bar(cr, 2*m, m)
    cr:fill()

    if self.checked then
        local fg = _hex2rgb(beautiful.colors.green)
        cr:set_source_rgb(fg[1], fg[2], fg[3])
        cr:move_to(2*m, m/2)
        cr:arc((3/2)*m, m/2, m/2, 0, 2*math.pi)
    else
        local fg = _hex2rgb(beautiful.colors.red)
        cr:set_source_rgb(fg[1], fg[2], fg[3])
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