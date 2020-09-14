local awful = require 'awful' 
local gears = require 'gears'

--------------------------------------------------------------------------------
-- BATTERY
--------------------------------------------------------------------------------

local battery = gears.object()
gears.table.crush(battery, { value = 0 }, true)

awful.spawn.easy_async_with_shell(
    [[ amixer sget Master | tail -n 1 | sed -E 's/.*\[([0-9]+)%\].*/\1/' ]],
    function(stdout, _, _, _) battery:set(tonumber(stdout)) end
)

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

function battery:get()
    return self.value
end

function battery:set(value)
    self.value = math.min(math.max(0, value), 100)
    awful.spawn(('amixer sset Master %d%%'):format(self.value))
    self:emit_signal('update', self.value)
end

--------------------------------------------------------------------------------
-- DAEMONS
--------------------------------------------------------------------------------

gears.timer({
    timeout = 60,
    autostart = true,

    callback = function()
        local get_bat_files_cmd = [[ find /sys/class/power_supply/ -name 'BAT*' ]]

        awful.spawn.easy_async_with_shell(get_bat_files_cmd, function(stdout)
            local energy_now = 0
            local energy_full = 0
            local batteries = string.gmatch(stdout, "%S+");

            for battery in batteries do
                local status = string.gsub(fread(battery .. '/status'), '%s+', '')
                if status == 'Charging' then
                    return
                end

                energy_now = energy_now + tonumber(fread(battery .. '/energy_now'))
                energy_full = energy_full + tonumber(fread(battery .. '/energy_full'))
            end

            if energy_full == 0 then
                notifier.ids.battery = naughty.notify({
                    text = 'Battery Daemon Error: No batteries found.',
                    bg = beautiful.colors.red,
                    fg = beautiful.colors.white,
                    position = 'top_middle',
                    timeout = 0,
                    replaces_id = notifier.ids.battery,
                }).id
            else
                local battery_percent = math.ceil(100 * energy_now / energy_full)

                if battery_percent < 20 then
                    notifier.ids.battery = naughty.notify({
                        text = 'Battery Warning: ' .. tostring(battery_percent) .. '%',
                        bg = beautiful.colors.red,
                        fg = beautiful.colors.white,
                        position = 'top_middle',
                        timeout = 0,
                        replaces_id = notifier.ids.battery,
                    }).id
                end
            end
        end)
    end,
})


--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return volume
