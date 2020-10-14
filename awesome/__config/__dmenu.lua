local awful = require 'awful'

return {
    anki = {
        callback = function() awful.spawn('anki') end,
    },
    discord = {
        callback = function() awful.spawn('discord') end,
    },
    gimp = {
        callback = function() awful.spawn('gimp') end,
    },
    inkscape = {
        callback = function() awful.spawn('inkscape') end,
    },
    kcharselect = {
        callback = function() awful.spawn('kcharselect') end,
    },
}
