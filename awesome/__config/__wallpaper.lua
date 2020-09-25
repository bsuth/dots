local gears = require 'gears' 

local wallpaper = os.getenv('AWESOME') .. '/__config/wallpaper.png'

local function set_wallpaper(screen)
    -- gears.wallpaper.maximized(wallpaper, screen, true)
    gears.wallpaper.tiled(os.getenv('AWESOME') .. '/__config/wallpaper.png')
end

return set_wallpaper
