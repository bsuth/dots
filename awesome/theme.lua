local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')

-- -----------------------------------------------------------------------------
-- Palette
-- -----------------------------------------------------------------------------

local palette = {
  -- onedark warmer
  -- https://github.com/navarasu/onedark.nvim/blob/master/lua/onedark/palette.lua
  red = '#de5d68',
  green = '#8fb573',
  yellow = '#dbb671',
  blue = '#57a5e5',
  magenta = '#bb70d2',
  cyan = '#51a8b3',

  black = '#101012',
  darkGray = '#232326',
  lightGray = '#35353b',

  -- Custom
  white = '#e8e8e8',
  void = '#000000',
  dimmed = '#00000088',
  transparent = '#00000000',
}

-- -----------------------------------------------------------------------------
-- Theme
-- -----------------------------------------------------------------------------

beautiful.init({
  colors = colors,

  font = 'Quicksand Regular 16',
  fg_normal = palette.void,
  bg_focus = palette.white,
  fg_focus = palette.void,

  useless_gap = 5,
  border_width = 1,
  border_normal = palette.void,
  border_focus = palette.white,

  notification_font = 'Quicksand Regular 14',
  notification_bg = palette.darkGray,
  notification_fg = palette.white,
  notification_border_color = palette.cyan,
})

-- Copy palette into `beautiful` for convenience. This must be done after
-- `beautiful.init({ ... })`.
for color, hex in pairs(palette) do
  beautiful[color] = hex
end

-- Some notification theme properties don't get overridden by the beautiful
-- variables, so we have to directly set them here. See defaults here:
-- https://awesomewm.org/doc/api/libraries/naughty.html#config.defaults
naughty.config.padding = 16
naughty.config.defaults.timeout = 8
naughty.config.defaults.margin = 24
naughty.config.defaults.border_width = 1
naughty.config.defaults.position = 'top_right'

-- -----------------------------------------------------------------------------
-- Functions
-- -----------------------------------------------------------------------------

function beautiful.assets(path)
  return os.getenv('HOME') .. '/dots/awesome/assets/' .. path
end

function beautiful.hex2rgb(hex)
  hex = hex:gsub('#', '')
  return {
    tonumber('0x' .. hex:sub(1, 2)) / 255,
    tonumber('0x' .. hex:sub(3, 4)) / 255,
    tonumber('0x' .. hex:sub(5, 6)) / 255,
  }
end

function beautiful.setWallpaper(screen)
  local wallpaper = screen.geometry.width > screen.geometry.height
    and beautiful.assets('horizontal-wallpaper.svg')
    or beautiful.assets('vertical-wallpaper.svg')
  gears.wallpaper.maximized(wallpaper, screen)
end

-- -----------------------------------------------------------------------------
-- Signals
-- -----------------------------------------------------------------------------

-- Re-set wallpaper when screen geometry changes (e.g. resolution change)
screen.connect_signal('property::geometry', beautiful.setWallpaper)

awful.screen.connect_for_each_screen(function(s)
  beautiful.setWallpaper(s)
end)

client.connect_signal('focus', function(c)
  c.border_color = beautiful.border_focus
end)

client.connect_signal('unfocus', function(c)
  c.border_color = beautiful.border_normal
end)

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return beautiful
