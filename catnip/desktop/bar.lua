local C = require('constants')
local catnip = require('catnip')
local onedark = require('lib.onedark')

-- TODO: rename
-- TODO: "background" windows

---@class WorkspaceBarFields
---@field workspace Workspace
---@field canvas CatnipCanvas
---@field render_subscription fun() | nil

local Bar = {} --- @class WorkspaceBarSuper
local BarMT = { __index = Bar }

---@alias WorkspaceBar WorkspaceBarSuper | WorkspaceBarFields

---@param self WorkspaceBar
function Bar:render()
  if self.render_subscription ~= nil then
    return -- already queued
  end

  self.render_subscription = catnip.subscribe('tick', function()
    catnip.unsubscribe('tick', self.render_subscription)
    self.render_subscription = nil
    self.canvas:clear()

    local num_windows = #self.workspace
    local width = self.canvas.width / num_windows

    for i, window in ipairs(self.workspace) do
      local x = (i - 1) * width

      self.canvas:rectangle({
        x = x,
        y = 0,
        width = width,
        height = C.BAR_HEIGHT,
        fill_color = window.visible and onedark.light_gray or onedark.dark_gray,
      })

      self.canvas:text(window.data.title or window.title, {
        x = x,
        y = 0,
        width = width,
        height = C.BAR_HEIGHT,
        color = onedark.white,
        align = 'center',
        valign = 'center',
      })
    end
  end)
end

---@param workspace Workspace
---@return WorkspaceBar
return function(workspace)
  local canvas = catnip.canvas({
    x = workspace.output.x,
    y = workspace.output.y,
    width = workspace.output.width,
    height = C.BAR_HEIGHT,
  })

  local bar = setmetatable({
    workspace = workspace,
    canvas = canvas,
  }, BarMT)

  workspace.output:subscribe('update::x', function()
    bar.canvas.x = workspace.output.x
    bar:render()
  end)

  workspace.output:subscribe('update::y', function()
    bar.canvas.y = workspace.output.y
    bar:render()
  end)

  workspace.output:subscribe('update::width', function()
    bar.canvas.width = workspace.output.width
    bar:render()
  end)

  return bar
end
