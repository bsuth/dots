local awful = require 'awful' 
local gears = require 'gears'

--------------------------------------------------------------------------------
-- VOLUME
--------------------------------------------------------------------------------

local volume = gears.object()
gears.table.crush(volume, { mute = false, value = 0 }, true)

awful.spawn.easy_async_with_shell(
    [[ amixer sget Master | tail -n 1 | sed -E 's/.*\[([0-9]+)%\].*/\1/' ]],
    function(stdout, _, _, _) volume:set(tonumber(stdout)) end
)

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function volume:get()
    return self.value
end

function volume:set(value)
    self.value = math.min(math.max(0, value), 100)
    awful.spawn(('amixer sset Master %d%%'):format(self.value))
    self:emit_signal('update', self.value)
end

function volume:shift(dvalue)
    self:set(self.value + dvalue)
end

function volume:toggle()
    self.mute = not self.mute
    awful.spawn('amixer sset Master toggle')
    self:emit_signal('toggle', self.mute)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return volume
