local catnip = require('catnip')
local cursor_utils = require('lib.cursor_utils')

---@class WorkspaceFields
---@field output CatnipOutput
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
end

---@param self Workspace
---@param index number | nil
---@return CatnipWindow | nil
function Workspace:remove(index)
  ---@type CatnipWindow | nil
  local window = table.remove(self, index)
  return window
end

---@param self Workspace
---@param index number
function Workspace:activate(index)
  for i, window in ipairs(self) do
    if i ~= index then
      window.visible = false
    else
      window.x = self.output.x
      window.y = self.output.y
      window.width = self.output.width
      window.height = self.output.height

      -- Resize the window before showing it to avoid flickering
      window.visible = true
    end
  end
end

---@param self Workspace
function Workspace:focus()
  local active_window = self:get_active_window()

  if active_window ~= nil then
    catnip.focused = active_window
  end

  cursor_utils.center_cursor(self.output)
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
  end

  if target ~= nil then
    self.output.x = target.output.x
    self.output.y = target.output.y
    self.output.width = target.output.width
    self.output.height = target.output.height
  end

  self.mirrored_workspace = target
end

---@param output CatnipOutput
---@return Workspace
return function(output)
  local workspace = { output = output }
  return setmetatable(workspace, WorkspaceMT)
end
