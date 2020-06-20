local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful.xresources').apply_dpi
local gears = require('gears')
local naughty = require('naughty')

---------------------------------------
-- COLORSCHEME: ONEDARK
---------------------------------------

local black = '#282c34'
local red = '#e06c75'
local green = '#98c379'
local yellow = '#e5c07b'
local blue = '#61afef'
local purple = '#c678dd'
local cyan = '#56b6c2'
local white = '#abb2bf'

local dark_grey = '#545862'
local light_grey = '#c8ccd4'

---------------------------------------
-- THEME
---------------------------------------

beautiful.init({
    font = 'Quicksand Medium 15',
    wallpaper = os.getenv('HOME') .. '/Pictures/cubes.png',

    fg_normal = white,
    bg_focus = white,
    fg_focus = black,

    useless_gap = dpi(5),
    border_width = dpi(3),
    border_normal = red,
    border_focus = green,
    border_marked = red,

    notification_font = 'Quicksand Medium 15',
    notification_bg = '#181818',
    notification_fg = purple,
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
-- WALLPAPER SETUP
---------------------------------------

local function set_wallpaper(screen)
    if beautiful.wallpaper then
        gears.wallpaper.maximized(beautiful.wallpaper, screen, true)
    end
end

-- Re-set wallpaper when screen geometry changes (e.g. resolution change)
screen.connect_signal('property::geometry', set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
end)
