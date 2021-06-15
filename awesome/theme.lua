local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')

--
-- Colorscheme: OneDark
--

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
  void = '#000000',

  dimmed = '#000000C8',
  transparent = '#00000000',
}

--
-- Theme
--

beautiful.init({
  colors = colors,

  font = 'Quicksand Regular 16',

  fg_normal = colors.white,
  bg_focus = colors.white,
  fg_focus = colors.black,

  useless_gap = 5,
  border_width = 2,
  border_normal = colors.dark_grey,
  border_focus = colors.white,
  border_marked = colors.red,

  notification_font = 'Quicksand Regular 16',
  notification_bg = '#181818',
  notification_fg = colors.white,
  notification_border_color = colors.white,
  notification_icon_size = 40,
})

-- Some notification theme properties don't get overridden by the beautiful
-- variables, so we have to directly set them here. See defaults here:
-- https://awesomewm.org/doc/api/libraries/naughty.html#config.defaults
naughty.config.padding = 20
naughty.config.defaults.timeout = 8
naughty.config.defaults.margin = 5
naughty.config.defaults.border_width = 2
naughty.config.defaults.position = 'top_left'

--
-- Functions
--

function beautiful.svg(path)
  return ('/home/bsuth/dots/svg/%s.svg'):format(path)
end

function beautiful.hex2rgb(hex)
  hex = hex:gsub('#', '')
  return {
    tonumber('0x' .. hex:sub(1, 2)) / 255,
    tonumber('0x' .. hex:sub(3, 4)) / 255,
    tonumber('0x' .. hex:sub(5, 6)) / 255,
  }
end

function beautiful.set_wallpaper(screen)
  gears.wallpaper.maximized('/home/bsuth/dots/wallpaper.png', screen)
end

--
-- Signals
--

-- Re-set wallpaper when screen geometry changes (e.g. resolution change)
screen.connect_signal('property::geometry', beautiful.set_wallpaper)

client.connect_signal('focus', function(c)
  c.border_color = beautiful.border_focus
end)

client.connect_signal('unfocus', function(c)
  c.border_color = beautiful.border_normal
end)

--
-- Return
--

return beautiful
