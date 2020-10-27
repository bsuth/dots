local awful = require 'awful'

return {
    anki = {
        callback = function() awful.spawn('anki') end,
    },
    inkscape = {
        callback = function() awful.spawn('inkscape') end,
    },
    kcharselect = {
        callback = function() awful.spawn('kcharselect') end,
    },
}
