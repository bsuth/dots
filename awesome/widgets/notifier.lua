local awful = require('awful')
local gears = require('gears')
local naughty = require('naughty')
local theme = require('theme')

---------------------------------------
-- INIT
---------------------------------------

local notifier = {
    ids = {
        system = nil,
        battery = nil,
        ram = nil,
    },
}


---------------------------------------
-- HELPERS
---------------------------------------

function fread(file)
    local f = io.open(file, 'rb')
    local value = nil

    if f then
        value = f:read('*a')
        f:close()
    end

    return value
end


---------------------------------------
-- VOLUME
---------------------------------------

function notifier:volume()
    local get_vol_cmd = [[ awk -F"[][]" 'END { print $2 }' <(amixer sget -D pulse Master) ]]

    awful.spawn.easy_async_with_shell(get_vol_cmd, function(stdout)
        self.ids.system = naughty.notify({
            text = string.gsub(stdout, "\n", ""), -- remove empty new line
            timeout = 2,
            replaces_id = self.ids.system,
        }).id
    end)
end


---------------------------------------
-- BRIGHTNESS
-- ----------
-- Note: The arguments here are used to precompute new brightness percentages
-- before they actually take effect. To see why we do this, refer the following
-- keybindings in keys.lua:
--      XF86MonBrightnessDown
--      XF86MonBrightnessUp
---------------------------------------

function notifier:brightness(plus_minus, diff)
    local br_dir = '/sys/class/backlight/intel_backlight/'

    local curr_br = tonumber(fread(br_dir .. 'brightness'))
    local max_br = tonumber(fread(br_dir .. 'max_brightness'))
    local br_percent = math.floor(100 * curr_br / max_br)

    if plus_minus == '+' then
        br_percent = math.min(br_percent + diff, 100)
    else
        br_percent = math.max(br_percent - diff, 0)
    end

    self.ids.system = naughty.notify({
        text = tostring(br_percent) .. '%',
        timeout = 2,
        replaces_id = self.ids.system,
    }).id
end


---------------------------------------
-- BATTERY (daemon)
---------------------------------------

gears.timer({
    timeout = 60, --seconds
    autostart = true,

    callback = function()
        local get_bat_files_cmd = [[ find /sys/class/power_supply/ -name 'BAT*' ]]

        awful.spawn.easy_async_with_shell(get_bat_files_cmd, function(stdout)
            local energy_now = 0
            local energy_full = 0
            local batteries = string.gmatch(stdout, "%S+");

            for battery in batteries do
                energy_now = energy_now + tonumber(fread(battery .. '/energy_now'))
                energy_full = energy_full + tonumber(fread(battery .. '/energy_full'))
            end

            if energy_full == 0 then
                notifier.ids.battery = naughty.notify({
                    text = 'Battery Daemon Error: No batteries found.',
                    bg = theme.red,
                    fg = theme.white,
                    position = 'top_middle',
                    timeout = 0,
                    replaces_id = notifier.ids.battery,
                }).id
            else
                local battery_percent = math.ceil(100 * energy_now / energy_full)

                if battery_percent < 20 then
                    notifier.ids.battery = naughty.notify({
                        text = 'Battery Warning: ' .. tostring(battery_percent) .. '%',
                        bg = theme.red,
                        fg = theme.white,
                        position = 'top_middle',
                        timeout = 0,
                        replaces_id = notifier.ids.battery,
                    }).id
                end
            end
        end)
    end,
})


---------------------------------------
-- RAM (daemon)
---------------------------------------

gears.timer({
    timeout = 60, --seconds
    autostart = true,

    callback = function()
        local get_ram_usage = [[ free | grep Mem | awk '{print $3/$2 * 100}' ]]

        awful.spawn.easy_async_with_shell(get_ram_usage, function(stdout)
            local ram_usage = math.floor(tonumber(stdout))

            if ram_usage > 90 then
                notifier.ids.ram = naughty.notify({
                    text = 'RAM Warning: ' .. tostring(ram_usage) .. '%',
                    bg = theme.red,
                    fg = theme.white,
                    position = 'top_middle',
                    timeout = 0,
                    replaces_id = notifier.ids.ram,
                }).id
            end
        end)
    end,
})


---------------------------------------
-- RETURN
---------------------------------------

return notifier
