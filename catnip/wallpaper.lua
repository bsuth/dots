local catnip = require('catnip')

local wallpapers = {}
local wallpaper_svg = catnip.svg(io.readfile('wallpaper.svg'))

local function create_wallpaper(output)
  local output_wallpaper = catnip.canvas({
    x = output.x,
    y = output.y,
    width = output.width,
    height = output.height,
  })

  output_wallpaper:svg(wallpaper_svg, {
    x = output.x,
    y = output.y,
    width = output.width,
    height = output.height,
  })

  output:subscribe('destroy', function()
    for i, wallpaper in ipairs(wallpapers) do
      if wallpaper == output_wallpaper then
        table.remove(wallpapers, i)
        break
      end
    end
  end)

  table.insert(wallpapers, output_wallpaper)
end

do
  catnip.subscribe('output::create', create_wallpaper)

  for _, output in ipairs(catnip.outputs) do
    create_wallpaper(output)
  end
end
