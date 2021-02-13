local beautiful = require 'beautiful' 
local dpi = require('beautiful/xresources').apply_dpi
local gears = require 'gears'
local naughty = require 'naughty' 

--------------------------------------------------------------------------------
-- COLORSCHEME: ONEDARK
--------------------------------------------------------------------------------

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
    blacker = '#181818',

    dimmed = '#00000088',
    transparent = '#00000000',
}

--------------------------------------------------------------------------------
-- THEME
--------------------------------------------------------------------------------

beautiful.init {
    colors = colors,

    font = 'Titan One 16',

    fg_normal = colors.white,
    bg_focus = colors.white,
    fg_focus = colors.black,

    useless_gap = dpi(5),
    border_width = dpi(3),
    border_normal = colors.dark_grey,
    border_focus = colors.green,
    border_marked = colors.red,

    notification_font = 'Quicksand Medium 16',
    notification_bg = '#181818',
    notification_fg = colors.purple,
    notification_border_color = colors.purple,
    notification_shape = function(cr, width, height)
        gears.shape.transform(gears.shape.infobubble)
            :rotate_at(width / 2, height / 2, math.pi)
                (cr, width, height, 20, 20, 30)
    end,
}

-- Some notification theme properties don't get overridden by the beautiful
-- variables, so we have to directly set them here. See defaults here:
-- https://awesomewm.org/doc/api/libraries/naughty.html#config.defaults
naughty.config.padding = 20
naughty.config.default = {
	timeout = 5,
	ontop = true,
	margin = dpi(5),
	border_width = dpi(5),
	position = 'bottom_right',
}
naughty.config.notify_callback = function(args)
    args.text = ([[
<span size='medium' weight='bold'>  Broadcast Received  </span>
<span size='small'>  %s  </span>
	]]):format(args.text)
	return args
end

--------------------------------------------------------------------------------
-- FUNCTIONS
--------------------------------------------------------------------------------

function beautiful.icon(icon)
    return ('/home/bsuth/dots/icons/%s.svg'):format(icon)
end

function beautiful.hex2rgb(hex)
    hex = hex:gsub('#','')
    return {
        tonumber('0x' .. hex:sub(1,2)) / 255,
        tonumber('0x' .. hex:sub(3,4)) / 255,
        tonumber('0x' .. hex:sub(5,6)) / 255,
    }
end

function beautiful.set_wallpaper(screen)
    gears.wallpaper.maximized('/home/bsuth/dots/wallpaper.png', screen)
end

--------------------------------------------------------------------------------
-- RETURN
--------------------------------------------------------------------------------

return beautiful
