local C = require('constants')
local WorkspaceBar = require('desktop.bar')
local WorkspaceWallpaper = require('desktop.wallpaper')
local catmint = require('utils.catmint')

---@class WorkspaceFields
---@field output CatnipOutput
---@field bar WorkspaceBar
---@field wallpaper WorkspaceWallpaper
---@field mirrored_workspace Workspace | nil
---@field refresh_subscription fun() | nil

local Workspace = {} --- @class WorkspaceSuper
local WorkspaceMT = { __index = Workspace }

---@alias Workspace WorkspaceSuper | WorkspaceFields | CatnipWindow[]

---@param self Workspace
---@return CatnipWindow | nil, number | nil
function Workspace:get_active_window()
  for i, window in ipairs(self) do
    if window.visible then
      return window, i
    end
  end
end

---@param self Workspace
---@param window CatnipWindow
---@param index? number
function Workspace:insert(window, index)
  local active_window_index = select(2, self:get_active_window())

  if index ~= nil then
    table.insert(self, index, window)
    self:activate(index)
  elseif active_window_index ~= nil then
    table.insert(self, active_window_index + 1, window)
    self:activate(active_window_index + 1)
  else
    table.insert(self, window)
    self:activate(#self)
  end

  self:render()
end

---@param self Workspace
---@param index number | nil
---@return CatnipWindow | nil
function Workspace:remove(index)
  ---@type CatnipWindow | nil
  local window = table.remove(self, index)
  self:render()
  return window
end

---@param self Workspace
---@param index number
function Workspace:activate(index)
  for i, window in ipairs(self) do
    if i ~= index then
      window.visible = false
    else
      local num_windows = #self
      local bar_height = num_windows > 1 and C.BAR_HEIGHT or 0

      window.x = self.output.x
      window.y = self.output.y + bar_height
      window.width = self.output.width
      window.height = self.output.height - bar_height

      -- Resize the window before showing it to avoid flickering
      window.visible = true
    end
  end

  self:render()
end

---@param self Workspace
function Workspace:focus()
  local active_window = self:get_active_window()

  if active_window ~= nil then
    active_window.focused = true
  end

  catmint.center_cursor(self.output)
end

---@param self Workspace
---@param direction 'forwards' | 'backwards'
function Workspace:cycle(direction)
  local num_windows = #self
  if num_windows < 2 then return end

  local active_window_index = select(2, self:get_active_window())
  if active_window_index == nil then return end

  local new_active_window_index = direction == 'forwards'
      and (active_window_index == num_windows and 1 or active_window_index + 1)
      or (active_window_index == 1 and num_windows or active_window_index - 1)

  self:activate(new_active_window_index)
  self:focus()
  self:render()
end

---@param self Workspace
---@param direction 'forwards' | 'backwards'
function Workspace:shift(direction)
  local num_windows = #self
  if num_windows < 2 then return end

  local active_window, active_window_index = self:get_active_window()
  if active_window == nil or active_window_index == nil then return end

  local new_active_window_index = direction == 'forwards'
      and math.min(num_windows, active_window_index + 1)
      or math.max(1, active_window_index - 1)

  self[active_window_index] = self[new_active_window_index]
  self[new_active_window_index] = active_window

  self:render()
end

---@param self Workspace
---@param target Workspace | nil
function Workspace:mirror(target)
  if self.mirrored_workspace == nil and target ~= nil then
    local num_target_windows = #target

    for i = #self, 1, -1 do
      num_target_windows = num_target_windows + 1
      table.insert(target, num_target_windows, self[i])
      table.remove(self, i)
    end

    target:render()
  end

  if target ~= nil then
    self.output.x = target.output.x
    self.output.y = target.output.y
    self.output.width = target.output.width
    self.output.height = target.output.height
  end

  self.mirrored_workspace = target
  self.wallpaper.canvas.visible = target == nil

  self:render()
end

---@param self Workspace
function Workspace:render()
  if self.mirrored_workspace ~= nil or #self < 2 then
    self.bar.canvas.visible = false
  else
    self.bar.canvas.visible = true
    self.bar:render()
  end
end

---@param output CatnipOutput
---@return Workspace
return function(output)
  local workspace = { output = output }
  workspace.bar = WorkspaceBar(workspace)
  workspace.wallpaper = WorkspaceWallpaper(workspace)
  return setmetatable(workspace, WorkspaceMT)
end
