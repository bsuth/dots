local catnip = require('catnip')
local table = require('extern.stdlib').table
local onedark = require('utils.onedark')

local wallpapers = {}

local COLORS = {
  radius = 20,
  spacing = 24,
  onedark.red,
  onedark.yellow,
  onedark.green,
  onedark.cyan,
  onedark.blue,
  onedark.magenta,
}

-- TODO: handle mirrored outputs
catnip.subscribe('output::create', function(output)
  local canvas = catnip.canvas({
    x = output.x,
    y = output.y,
    width = output.width,
    height = output.height,
  })

  -- Ensure the wallpaper is in the back
  canvas.z = 0

  canvas:rectangle({
    x = 0,
    y = 0,
    width = canvas.width,
    height = canvas.height,
    fill_color = onedark.dark_gray,
  })

  local color_row_width = (#COLORS - 1) * COLORS.spacing + 2 * COLORS.radius
  local color_row_x = (canvas.width - color_row_width) / 2

  for i, color in ipairs(COLORS) do
    local x = color_row_x + (i - 1) * COLORS.spacing
    local y = canvas.height / 2 - COLORS.radius

    canvas:path({
      fill_color = color,
      { 'move', x,             y },
      { 'arc',  COLORS.radius, 0, 2 * math.pi },
    })
  end

  table.insert(wallpapers, {
    output = output,
    canvas = canvas,
  })
end)

catnip.subscribe('output::destroy', function(output)
  table.clear(wallpapers, function(wallpaper)
    return wallpaper.output ~= output
  end)
end)
