local awful = require 'awful' 
local gears = require 'gears'

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------

local brightness = gears.object()

local _private = {
    value = 0,
}

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function brightness:get(param)
    return param and _private[param] or _private.value
end

function brightness:set(value)
    _private.value = math.min(math.max(0, value), 100)
    awful.spawn(('brightnessctl set %s%%'):format(_private.value))
    self:emit_signal('update')
end

function brightness:shift(dvalue)
    self:set(_private.value + dvalue)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

awful.spawn.easy_async_with_shell(
    [[ echo $(( 100 * $(brightnessctl get) / $(brightnessctl max) )) ]],
    function(stdout, _, _, _) brightness:set(tonumber(stdout)) end
)

return brightness
