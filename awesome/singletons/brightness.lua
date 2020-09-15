local awful = require 'awful' 
local gears = require 'gears'

--------------------------------------------------------------------------------
-- BRIGHTNESS
--------------------------------------------------------------------------------

local brightness = gears.object()
gears.table.crush(brightness, { value = 0 }, true)

awful.spawn.easy_async_with_shell(
    [[ echo $(( 100 * $(brightnessctl get) / $(brightnessctl max) )) ]],
    function(stdout, _, _, _) brightness:set(tonumber(stdout)) end
)

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function brightness:get()
    return self.value
end

function brightness:set(value)
    value = math.min(math.max(0, value), 100)
    awful.spawn(('brightnessctl set %s%%'):format(value))
    self.value = value
    self:emit_signal('update', value)
end

function brightness:shift(dvalue)
    self:set(self.value + dvalue)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return brightness
