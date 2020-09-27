local awful = require 'awful' 

return {
    {
        alias = 'db',
        callback = function()
            awful.spawn('st -e nvim -c ":DBUI"')
        end,
    },
}
