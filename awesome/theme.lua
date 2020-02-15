
local naughty = require('naughty')
local theme_assets = require('beautiful.theme_assets')
local xresources = require('beautiful.xresources')
local gfs = require('gears.filesystem')

local dpi = xresources.apply_dpi
local themes_path = gfs.get_themes_dir()

---------------------------------------
-- COLORSCHEME: OneDark
---------------------------------------

local black = "#282c34"
local red = "#e06c75"
local green = "#98c379"
local yellow = "#e5c07b"
local blue = "#61afef"
local purple = "#c678dd"
local cyan = "#56b6c2"
local white = "#abb2bf"

local dark_grey = "#545862"
local light_grey = "#c8ccd4"


---------------------------------------
-- THEME
---------------------------------------

local theme = {
    font = 'Source Code Pro Medium 10',
    wallpaper = os.getenv('HOME') .. '/Pictures/system/wallpaper.jpeg',

    useless_gap   = dpi(8),
    border_width  = dpi(5),
    border_normal = black,
    border_focus  = green,
    border_marked = red,

    notification_font = 'Source Code Pro Medium 15',
    notification_bg = '#181818',
    notification_fg = purple,
    notification_margin = 15,
    notification_border_width = 5,
    notification_border_color = '#0000',
}

-- Some notification theme properties don't get overridden by default, so we
-- have to directly set them here. See defaults here:
-- https://awesomewm.org/doc/api/libraries/naughty.html#config.defaults
naughty.config.defaults.margin = 15
naughty.config.defaults.border_width = dpi(25)
naughty.config.defaults.position = 'bottom_right'

return theme
