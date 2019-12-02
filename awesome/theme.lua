
local theme_assets = require('beautiful.theme_assets')
local xresources = require('beautiful.xresources')
local gfs = require('gears.filesystem')

local dpi = xresources.apply_dpi
local themes_path = gfs.get_themes_dir()


---------------------------------------
-- INIT
---------------------------------------

local _this = {}

_this.font = 'Source Code Pro Medium 10'

_this.wallpaper = os.getenv('HOME') .. '/Pictures/system/wallpaper.jpg'

_this.bg_normal     = '#222222'
_this.bg_focus      = '#535d6c'
_this.bg_urgent     = '#ff0000'
_this.bg_minimize   = '#444444'
_this.bg_systray    = _this.bg_normal

_this.fg_normal     = '#aaaaaa'
_this.fg_focus      = '#ffffff'
_this.fg_urgent     = '#ffffff'
_this.fg_minimize   = '#ffffff'

_this.useless_gap   = dpi(0)
_this.border_width  = dpi(3)
_this.border_normal = '#282828'
_this.border_focus  = '#535d6c'
_this.border_marked = '#91231c'

-- Variables set for theming notifications:
_this.notification_font = 'Source Code Pro Medium 10'
_this.notification_bg = _this.bg_normal
_this.notification_fg = _this.fg_normal
_this.notification_margin = 0
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]


return _this
