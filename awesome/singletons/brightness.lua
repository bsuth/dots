local awful = require 'awful' 
local gears = require 'gears'

--------------------------------------------------------------------------------
-- BRIGHTNESS
--------------------------------------------------------------------------------

local brightness = gears.object()
gears.table.crush(brightness, { value = 0 }, true)

awful.spawn.easy_async_with_shell(
    [[ printf '%.0f' $(xbacklight) ]],
    function(stdout, _, _, _) brightness:set(tonumber(stdout)) end
)

-- -------------------------------------------------------------------------
-- TODO: Add notification
--
-- Note: xbacklight is SLOW. If we wait for xbacklight to finish before
-- sending the notification, there is a considerable amount of lag. Thus,
-- we precompute the new brightness percentage when sending the notification
-- and only change it after.
-- -------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function brightness:get()
    return self.value
end

function brightness:set(value)
    value = math.min(math.max(0, value), 100)
    awful.spawn(('xbacklight -set %s'):format(value))
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
