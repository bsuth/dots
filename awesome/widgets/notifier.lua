local awful = require 'awful' 
local beautiful = require 'beautiful' 
local gears = require 'gears' 
local naughty = require 'naughty' 

---------------------------------------
-- INIT
---------------------------------------

local notifier = {
    ids = {
        system = nil,
        battery = nil,
        ram = nil,
    },

    keyboard_id = 1,
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
-- KEYBOARD
---------------------------------------

function notifier:keyboard()
    local layouts = {'fcitx-keyboard-us', 'fcitx-keyboard-de', 'mozc'}

    local id = self.keyboard_id
    self.keyboard_id = (id == #layouts) and 1 or id + 1

    local keyboard_cmd = 'fcitx-remote -s' ..layouts[self.keyboard_id] 
    awful.spawn.easy_async_with_shell(keyboard_cmd, function()
        self.ids.system = naughty.notify({
            text = layouts[self.keyboard_id],
            timeout = 2,
            replaces_id = self.ids.system,
        }).id
    end)
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
                    bg = beautiful.colors.red,
                    fg = beautiful.colors.white,
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
