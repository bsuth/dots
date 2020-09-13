local awful = require 'awful' 

return {
    {
        alias = 'db',
        callback = function()
            awful.spawn('st -e nvim -c ":DBUI"')
        end,
    },
    {
        alias = 'sleep',
        callback = function()
            awful.spawn('systemctl suspend')
        end,
    },
    {
        alias = 'poweroff',
        callback = function()
            awful.spawn('poweroff')
        end,
    },
}
