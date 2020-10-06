local awful = require 'awful' 
local gears = require 'gears'

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------

local ram = gears.object()

local _private = {
    value = 0,
}

--------------------------------------------------------------------------------
-- METHODS
--------------------------------------------------------------------------------

function ram:get(param)
    return param and _private[param] or _private.value
end

function ram:update()
    local get_ram_usage = [[ free | grep Mem | awk '{print $3/$2 * 100}' ]]

    awful.spawn.easy_async_with_shell([[
        free | grep Mem | awk '{print $3/$2 * 100}' 
    ]], function(stdout)
        _private.value = math.floor(tonumber(stdout))
        self:emit_signal('update')

        if _private.value > 80 then
            self:emit_signal('warning_high')
        else
            self:emit_signal('no_warning')
        end
    end)
end

--------------------------------------------------------------------------------
-- DAEMONS
--------------------------------------------------------------------------------

gears.timer({
    timeout = 60,
    call_now = true,
    autostart = true,
    callback = function() ram:update() end,
})

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return ram
