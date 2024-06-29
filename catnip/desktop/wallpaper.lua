local catnip = require('catnip')
local onedark = require('utils.onedark')

---@class WorkspaceWallpaperFields
---@field workspace Workspace
---@field canvas CatnipCanvas
---@field render_subscription fun() | nil

local Wallpaper = {} --- @class WorkspaceWallpaperSuper
local WallpaperMT = { __index = Wallpaper }

---@alias WorkspaceWallpaper WorkspaceWallpaperSuper | WorkspaceWallpaperFields

local WALLPAPER_CIRCLES = {
  radius = 20,
  spacing = 24,
  onedark.red,
  onedark.yellow,
  onedark.green,
  onedark.cyan,
  onedark.blue,
  onedark.magenta,
}

---@param self WorkspaceWallpaper
function Wallpaper:render()
  -- Ensure the wallpaper is in the back
  self.canvas.z = 0

  self.canvas:rectangle({
    x = 0,
    y = 0,
    width = self.canvas.width,
    height = self.canvas.height,
    fill_color = onedark.dark_gray,
  })

  local width = (#WALLPAPER_CIRCLES - 1) * WALLPAPER_CIRCLES.spacing + 2 * WALLPAPER_CIRCLES.radius
  local x = (self.canvas.width - width) / 2

  for i, color in ipairs(WALLPAPER_CIRCLES) do
    self.canvas:rectangle({
      x = x + (i - 1) * WALLPAPER_CIRCLES.spacing,
      y = self.canvas.height / 2 - WALLPAPER_CIRCLES.radius,
      width = 2 * WALLPAPER_CIRCLES.radius,
      height = 2 * WALLPAPER_CIRCLES.radius,
      radius = WALLPAPER_CIRCLES.radius,
      fill_color = color,
    })
  end
end

---@param workspace Workspace
---@return WorkspaceWallpaper
return function(workspace)
  local canvas = catnip.canvas({
    x = workspace.output.x,
    y = workspace.output.y,
    width = workspace.output.width,
    height = workspace.output.height,
  })

  local wallpaper = setmetatable({
    workspace = workspace,
    canvas = canvas,
  }, WallpaperMT)

  workspace.output:subscribe('update::x', function()
    wallpaper.canvas.x = workspace.output.x
    wallpaper:render()
  end)

  workspace.output:subscribe('update::y', function()
    wallpaper.canvas.y = workspace.output.y
    wallpaper:render()
  end)

  workspace.output:subscribe('update::width', function()
    wallpaper.canvas.width = workspace.output.width
    wallpaper:render()
  end)

  workspace.output:subscribe('update::height', function()
    wallpaper.canvas.height = workspace.output.height
    wallpaper:render()
  end)

  wallpaper:render()

  return wallpaper
end
