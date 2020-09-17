local awful = require 'awful' 
local gears = require 'gears'

--------------------------------------------------------------------------------
-- VOLUME
--------------------------------------------------------------------------------

local volume = gears.object()

local _private = { 
    mute = false,
    value = 0,
}

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function volume:get(param)
    return param and _private[param] or _private.value
end

function volume:set(value)
    _private.value = math.min(math.max(0, value), 100)
    awful.spawn(('amixer sset Master %d%%'):format(_private.value))
    self:emit_signal('update')
end

function volume:shift(dvalue)
    self:set(_private.value + dvalue)
end

function volume:toggle()
    _private.mute = not _private.mute
    awful.spawn('amixer sset Master toggle')
    self:emit_signal('toggle', _private.mute)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

awful.spawn.easy_async_with_shell(
    [[ amixer sget Master | tail -n 1 | sed -E 's/.*\[([0-9]+)%\].*/\1/' ]],
    function(stdout, _, _, _) volume:set(tonumber(stdout)) end
)

return volume
