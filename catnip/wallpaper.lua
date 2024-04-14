local catnip = require('catnip')
local table = require('utils.stdlib').table

local wallpapers = {}

local wallpaper_svg = catnip.svg('wallpaper.svg')

local function render_wallpaper_canvas(wallpaper)
  wallpaper.canvas:clear()
  wallpaper.canvas:svg(wallpaper_svg, {
    x = wallpaper.output.x,
    y = wallpaper.output.y,
    width = wallpaper.output.width,
    height = wallpaper.output.height,
  })
end

local function create_wallpaper(output)
  local wallpaper = {
    output = output,
    canvas = catnip.canvas({
      x = output.x,
      y = output.y,
      width = output.width,
      height = output.height,
    }),
  }

  -- TODO: ensure the wallpaper is always in the back
  render_wallpaper_canvas(wallpaper)
  table.insert(wallpapers, wallpaper)
end

catnip.subscribe('output::destroy', function(output)
  table.clear(wallpapers, function(wallpaper)
    return wallpaper.output ~= output
  end)
end)

do
  catnip.subscribe('output::create', create_wallpaper)

  for output in catnip.outputs do
    create_wallpaper(output)
  end
end
