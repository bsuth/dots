local catnip = require('catnip')
local tile = require('lib.tile')
local cursor_utils = require('lib.cursor_utils')
local window_utils = require('lib.window_utils')
local table = require('extern.stdlib').table

---@class Workspace
---@field output CatnipOutput
---@field windows CatnipWindow[]
---@field tile_windows CatnipWindow[]

--- @type table<CatnipOutput, Workspace>
local workspaces = {}

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

---@return Workspace | nil
local function get_cursor_workspace()
  for output in catnip.outputs do
    if cursor_utils.is_cursor_in_output(output) then
      return workspaces[output]
    end
  end
end

---@param window CatnipWindow
---@return Workspace | nil, number | nil
local function get_window_workspace(window)
  for output in catnip.outputs do
    local workspace = workspaces[output] ---@type Workspace

    for i, workspace_window in ipairs(workspace.windows) do
      if workspace_window == window then
        return workspace, i
      end
    end
  end
end

---@param workspace Workspace
local function tile_workspace(workspace)
  local tile_space = {
    x = workspace.output.x,
    y = workspace.output.y,
    width = workspace.output.width,
    height = workspace.output.height,
    gap = 4,
  }

  if #workspace.tile_windows < 4 then
    tile.master_left(workspace.tile_windows, tile_space)
  else
    tile.grid_horizontal(workspace.tile_windows, tile_space)
  end
end

-- -----------------------------------------------------------------------------
-- Actions
-- -----------------------------------------------------------------------------

---@param window CatnipWindow | nil
local function add_window_tile(window, autofocus)
  local workspace

  if window ~= nil then
    workspace = get_window_workspace(window)
  else
    workspace = get_window_workspace(catnip.focused) or get_cursor_workspace()
  end

  if workspace == nil then
    return
  end

  if window == nil then
    window = table.find(workspace.windows, function(workspace_window)
      return not table.has(workspace.tile_windows, workspace_window)
    end)
  end

  if window == nil then
    return
  end

  table.insert(workspace.tile_windows, window)
  tile_workspace(workspace)

  if autofocus then
    window.visible = true
    catnip.focused = window
  end
end

---@param window CatnipWindow
local function remove_window_tile(window, autohide)
  local workspace = get_window_workspace(window)

  if workspace == nil then
    return
  end

  local _, tile_index = table.find(workspace.tile_windows, catnip.focused)

  if tile_index == nil then
    return
  end

  local num_tile_windows = #workspace.tile_windows

  if window == catnip.focused and num_tile_windows > 1 then
    if tile_index == num_tile_windows then
      catnip.focused = workspace.tile_windows[tile_index - 1]
    else
      catnip.focused = workspace.tile_windows[tile_index + 1]
    end
  end

  table.remove(workspace.tile_windows, tile_index)
  tile_workspace(workspace)

  if autohide then
    window.visible = false
  end
end

---@param direction 'left' | 'right' | 'up' | 'down'
local function focus_in_direction(direction)
  local focused_window = catnip.focused

  local new_focused_window = focused_window ~= nil
      and window_utils.get_window_in_direction(focused_window, direction)
      or window_utils.get_window_in_direction(catnip.cursor, direction)

  if new_focused_window == nil then
    return
  end

  catnip.focused = new_focused_window
end

---@param direction 'left' | 'right' | 'up' | 'down'
local function move_in_direction(direction)
  local focused_window = catnip.focused
  local focused_workspace = get_window_workspace(catnip.focused)

  if focused_workspace == nil then
    return
  end

  local adjacent_window = window_utils.get_window_in_direction(focused_window, direction)

  if adjacent_window == nil then
    return
  end

  local adjacent_workspace = get_window_workspace(adjacent_window)

  if adjacent_workspace == nil then
    return
  end

  local _, focused_tile_index = table.find(focused_workspace.tile_windows, focused_window)
  local _, adjacent_tile_index = table.find(adjacent_workspace.tile_windows, adjacent_window)

  if focused_tile_index == nil or adjacent_tile_index == nil then
    return
  end

  if focused_workspace == adjacent_workspace then
    focused_workspace.tile_windows[focused_tile_index] = adjacent_window
    adjacent_workspace.tile_windows[adjacent_tile_index] = focused_window
    window_utils.swap_windows(catnip.focused, adjacent_window)
  else
    remove_window_tile(focused_window)
    table.insert(adjacent_workspace.tile_windows, adjacent_tile_index, focused_window)
    tile_workspace(adjacent_workspace)
  end
end

---@param direction 'left' | 'right' | 'up' | 'down'
local function swap_in_direction(direction)
  local focused_window = catnip.focused
  local focused_workspace = get_window_workspace(focused_window)

  if focused_workspace == nil then
    return
  end

  local adjacent_window = window_utils.get_window_in_direction(focused_window, direction)

  if adjacent_window == nil then
    return
  end

  local adjacent_workspace = get_window_workspace(adjacent_window)

  if adjacent_workspace == nil then
    return
  end

  local _, focused_tile_index = table.find(focused_workspace.tile_windows, focused_window)
  local _, adjacent_tile_index = table.find(adjacent_workspace.tile_windows, adjacent_window)

  if focused_tile_index == nil or adjacent_tile_index == nil then
    return
  end

  focused_workspace.tile_windows[focused_tile_index] = adjacent_window
  adjacent_workspace.tile_windows[adjacent_tile_index] = focused_window
  window_utils.swap_windows(catnip.focused, adjacent_window)
end

---@param direction 'forwards' | 'backwards'
local function shift_focused_workspace(direction)
  local focused_workspace = get_window_workspace(catnip.focused)

  if focused_workspace == nil then
    return
  end

  local _, focused_index = table.find(focused_workspace.windows, catnip.focused)

  if focused_index == nil then
    return
  end

  local new_focused_index = direction == 'forwards'
      and math.min(#focused_workspace.windows, focused_index + 1)
      or math.max(1, focused_index - 1)

  focused_workspace.windows[focused_index] = focused_workspace.windows[new_focused_index]
  focused_workspace.windows[new_focused_index] = catnip.focused
end

---@param direction 'forwards' | 'backwards'
local function cycle_focused_workspace(direction)
  local old_focused_window = catnip.focused
  local focused_workspace = get_window_workspace(catnip.focused)

  if focused_workspace == nil then
    return
  end

  local _, old_focused_index = table.find(focused_workspace.windows, old_focused_window)
  local _, old_focused_tile_index = table.find(focused_workspace.tile_windows, old_focused_window)

  if old_focused_index == nil or old_focused_tile_index == nil then
    return
  end

  local new_focused_window = nil
  local num_windows = #focused_workspace.windows

  for i = 1, num_windows - 1 do
    local next_index = old_focused_index + (direction == 'forwards' and i or -i)

    if next_index < 1 then
      next_index = next_index + num_windows
    elseif next_index > num_windows then
      next_index = next_index - num_windows
    end

    local next_window = focused_workspace.windows[next_index]

    if not table.has(focused_workspace.tile_windows, next_window) then
      new_focused_window = next_window
      break
    end
  end

  if new_focused_window == nil then
    return
  end

  focused_workspace.tile_windows[old_focused_tile_index] = new_focused_window

  new_focused_window.x = old_focused_window.x
  new_focused_window.y = old_focused_window.y
  new_focused_window.width = old_focused_window.width
  new_focused_window.height = old_focused_window.height

  old_focused_window.visible = false
  new_focused_window.visible = true
  catnip.focused = new_focused_window
end

-- -----------------------------------------------------------------------------
-- Keymaps
-- -----------------------------------------------------------------------------

catnip.bind({ 'mod1' }, 'h', function() focus_in_direction('left') end)
catnip.bind({ 'mod1' }, 'j', function() focus_in_direction('down') end)
catnip.bind({ 'mod1' }, 'k', function() focus_in_direction('up') end)
catnip.bind({ 'mod1' }, 'l', function() focus_in_direction('right') end)

catnip.bind({ 'mod1' }, 'H', function() move_in_direction('left') end)
catnip.bind({ 'mod1' }, 'J', function() move_in_direction('down') end)
catnip.bind({ 'mod1' }, 'K', function() move_in_direction('up') end)
catnip.bind({ 'mod1' }, 'L', function() move_in_direction('right') end)

catnip.bind({ 'mod1', 'ctrl' }, 'H', function() swap_in_direction('left') end)
catnip.bind({ 'mod1', 'ctrl' }, 'J', function() swap_in_direction('down') end)
catnip.bind({ 'mod1', 'ctrl' }, 'K', function() swap_in_direction('up') end)
catnip.bind({ 'mod1', 'ctrl' }, 'L', function() swap_in_direction('right') end)

catnip.bind({ 'mod1' }, '>', function() shift_focused_workspace('forwards') end)
catnip.bind({ 'mod1' }, '<', function() shift_focused_workspace('backwards') end)

catnip.bind({ 'mod1' }, 'Tab', function() cycle_focused_workspace('forwards') end)
catnip.bind({ 'mod1' }, 'ISO_Left_Tab', function() cycle_focused_workspace('backwards') end)

catnip.bind({ 'mod1' }, '+', function() add_window_tile(nil, true) end)
catnip.bind({ 'mod1' }, '-', function() remove_window_tile(catnip.focused, true) end)

-- -----------------------------------------------------------------------------
-- Subscriptions
-- -----------------------------------------------------------------------------

catnip.outputs:on('create', function(output)
  workspaces[output] = {
    output = output,
    windows = {},
    tile_windows = {},
  }
end)

catnip.outputs:on('destroy', function(output)
  local workspace = workspaces[output]
  local backup_workspace = get_window_workspace(catnip.focused) or get_cursor_workspace()

  if backup_workspace == nil or backup_workspace.output == output then
    for backup_output in catnip.outputs do
      if backup_output ~= output then
        backup_workspace = workspaces[backup_output]
      end
    end
  end

  if backup_workspace == nil then
    return -- should never happen
  end

  for _, window in ipairs(workspace.windows) do
    table.insert(backup_workspace.windows, window)
  end
end)

catnip.windows:on('create', function(window)
  local workspace = get_window_workspace(catnip.focused) or get_cursor_workspace()

  if workspace == nil then
    return
  end

  table.insert(workspace.windows, window)

  local old_focused_window = catnip.focused

  window.x = old_focused_window.x
  window.y = old_focused_window.y
  window.width = old_focused_window.width
  window.height = old_focused_window.height

  old_focused_window.visible = false
  window.visible = true

  catnip.focused = window
end)

catnip.windows:on('destroy', function(window)
  remove_window_tile(window)

  local workspace, index = get_window_workspace(window)

  if workspace ~= nil then
    table.remove(workspace.windows, index)
  end
end)
