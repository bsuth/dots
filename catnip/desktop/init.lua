local catnip = require('catnip')
local keybind = require('lib.keybind')
local cursor_utils = require('lib.cursor_utils')
local output_utils = require('lib.output_utils')
local Workspace = require('desktop.workspace')

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

---@return Workspace | nil
local function get_cursor_workspace()
  for output in catnip.outputs do
    if cursor_utils.is_cursor_in_output(output) then
      return output.data.workspace
    end
  end
end

---@return Workspace | nil
local function get_focused_workspace()
  local focused_window = catnip.focused

  if focused_window == nil then
    return nil
  end

  for output in catnip.outputs do
    local workspace = output.data.workspace ---@type Workspace

    for _, window in ipairs(workspace) do
      if window == focused_window then
        return workspace
      end
    end
  end
end

---@param window CatnipWindow
---@return Workspace | nil, number | nil
local function get_window_workspace(window)
  for output in catnip.outputs do
    local workspace = output.data.workspace ---@type Workspace
    for i, workspace_window in ipairs(workspace) do
      if workspace_window == window then
        return workspace, i
      end
    end
  end
end

---@param source { x: number, y: number, width: number | nil, height: number | nil }
---@param direction 'left' | 'right' | 'up' | 'down'
---@return Workspace | nil
local function get_workspace_in_direction(source, direction)
  local output = output_utils.get_output_in_direction(source, direction)
  if output == nil then return end
  local workspace = output.data.workspace
  return workspace.mirrored_workspace ~= nil and workspace.mirrored_workspace or workspace
end

---@param direction 'left' | 'right' | 'up' | 'down'
local function focus_in_direction(direction)
  local focused_workspace = get_focused_workspace()

  local adjacent_workspace = focused_workspace ~= nil
      and get_workspace_in_direction(focused_workspace.output, direction)
      or get_workspace_in_direction(catnip.cursor, direction)
  if adjacent_workspace == nil then return end

  adjacent_workspace:focus()
end

---@param direction 'left' | 'right' | 'up' | 'down'
local function move_in_direction(direction)
  local focused_workspace = get_focused_workspace()
  if focused_workspace == nil then return end

  local focused_window, focused_window_index = focused_workspace:get_active_window()
  if focused_window == nil or focused_window_index == nil then return end

  local adjacent_workspace = get_workspace_in_direction(focused_workspace.output, direction)
  if adjacent_workspace == nil then return end

  focused_workspace:remove(focused_window_index)
  adjacent_workspace:insert(focused_window)
  adjacent_workspace:focus()
end

---@param direction 'left' | 'right' | 'up' | 'down'
local function swap_in_direction(direction)
  local focused_workspace = get_focused_workspace()
  if focused_workspace == nil then return end

  local focused_window, focused_window_index = focused_workspace:get_active_window()
  if focused_window == nil or focused_window_index == nil then return end

  local adjacent_workspace = get_workspace_in_direction(focused_workspace.output, direction)
  if adjacent_workspace == nil then return end

  local adjacent_window, adjacent_window_index = adjacent_workspace:get_active_window()
  if adjacent_window == nil or adjacent_window_index == nil then return end

  focused_workspace:remove(focused_window_index)
  adjacent_workspace:remove(adjacent_window_index)

  focused_workspace:insert(adjacent_window, focused_window_index)
  adjacent_workspace:insert(focused_window, adjacent_window_index)

  adjacent_workspace:focus()
end

---@param direction 'forwards' | 'backwards'
local function cycle_focused_workspace(direction)
  local focused_workspace = get_focused_workspace()
  if focused_workspace == nil then return end
  focused_workspace:cycle(direction)
end

---@param direction 'forwards' | 'backwards'
local function shift_focused_workspace(direction)
  local focused_workspace = get_focused_workspace()
  if focused_workspace == nil then return end
  focused_workspace:shift(direction)
end

-- -----------------------------------------------------------------------------
-- Keymaps
-- -----------------------------------------------------------------------------

keybind.release({ 'mod1' }, 'h', function() focus_in_direction('left') end)
keybind.release({ 'mod1' }, 'j', function() focus_in_direction('down') end)
keybind.release({ 'mod1' }, 'k', function() focus_in_direction('up') end)
keybind.release({ 'mod1' }, 'l', function() focus_in_direction('right') end)

keybind.release({ 'mod1' }, 'H', function() move_in_direction('left') end)
keybind.release({ 'mod1' }, 'J', function() move_in_direction('down') end)
keybind.release({ 'mod1' }, 'K', function() move_in_direction('up') end)
keybind.release({ 'mod1' }, 'L', function() move_in_direction('right') end)

keybind.release({ 'mod1', 'ctrl' }, 'H', function() swap_in_direction('left') end)
keybind.release({ 'mod1', 'ctrl' }, 'J', function() swap_in_direction('down') end)
keybind.release({ 'mod1', 'ctrl' }, 'K', function() swap_in_direction('up') end)
keybind.release({ 'mod1', 'ctrl' }, 'L', function() swap_in_direction('right') end)

keybind.release({ 'mod1' }, 'Tab', function() cycle_focused_workspace('forwards') end)
keybind.release({ 'mod1' }, 'ISO_Left_Tab', function() cycle_focused_workspace('backwards') end)

keybind.release({ 'mod1' }, '>', function() shift_focused_workspace('forwards') end)
keybind.release({ 'mod1' }, '<', function() shift_focused_workspace('backwards') end)

-- -----------------------------------------------------------------------------
-- Subscriptions
-- -----------------------------------------------------------------------------

catnip.subscribe('output::create', function(output)
  output.data.workspace = Workspace(output)
end)

catnip.subscribe('window::create', function(window)
  local cursor_workspace = get_cursor_workspace()
  if cursor_workspace == nil then return end
  cursor_workspace:insert(window)
  cursor_workspace:focus()
end)

catnip.subscribe('window::destroy', function(window)
  local workspace, window_index = get_window_workspace(window)
  if workspace == nil or window_index == nil then return end
  workspace:remove(window_index)
  workspace:activate(math.min(#workspace, window_index))
  workspace:focus()
end)
