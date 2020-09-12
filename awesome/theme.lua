local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful.xresources').apply_dpi
local gears = require('gears')
local naughty = require('naughty')

---------------------------------------
-- COLORSCHEME: ONEDARK
---------------------------------------

local colors = {
    black = '#282c34',
    red = '#e06c75',
    green = '#98c379',
    yellow = '#e5c07b',
    blue = '#61afef',
    purple = '#c678dd',
    cyan = '#56b6c2',
    white = '#abb2bf',

    dark_grey = '#545862',
    light_grey = '#c8ccd4',
}

---------------------------------------
-- THEME
---------------------------------------

beautiful.init({
    colors = colors,

    font = 'Quicksand Medium 15',

    fg_normal = colors.white,
    bg_focus = colors.white,
    fg_focus = colors.black,

    useless_gap = dpi(5),
    border_width = dpi(3),
    border_normal = colors.dark_grey,
    border_focus = colors.green,
    border_marked = colors.red,

    notification_font = 'Quicksand Medium 15',
    notification_bg = '#181818',
    notification_fg = colors.purple,
    notification_margin = 15,
    notification_border_width = 5,
    notification_border_color = '#0000',
})

-- Some notification theme properties don't get overridden by default, so we
-- have to directly set them here. See defaults here:
-- https://awesomewm.org/doc/api/libraries/naughty.html#config.defaults
naughty.config.defaults.margin = 15
naughty.config.defaults.border_width = dpi(25)
naughty.config.defaults.position = 'bottom_right'

---------------------------------------
-- WALLPAPER
---------------------------------------

local set_wallpaper = require('__config/wallpaper')

-- Re-set wallpaper when screen geometry changes (e.g. resolution change)
screen.connect_signal('property::geometry', set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
end)
