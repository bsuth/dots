local C = require('constants')
local catnip = require('catnip')
local keymap = require('keymap')
local catmint = require('utils.catmint')
local table = require('extern.stdlib').table

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

---@param direction 'left' | 'right' | 'up' | 'down'
local function focus_in_direction(direction)
  local focused_window = catmint.get_focused_window()

  local adjacent_window = catmint.get_window_in_direction(focused_window or catnip.cursor, direction)
  local adjacent_output = catmint.get_output_in_direction(focused_window or catnip.cursor, direction)

  if adjacent_window ~= nil then
    catnip.cursor.x = adjacent_window.x + adjacent_window.width / 2
    catnip.cursor.y = adjacent_window.y + adjacent_window.height / 2
    adjacent_window.focused = true
  elseif adjacent_output ~= nil then
    if focused_window ~= nil then focused_window.focused = false end
    catnip.cursor.x = adjacent_output.x + adjacent_output.width / 2
    catnip.cursor.y = adjacent_output.y + adjacent_output.height / 2
  end
end

---@param direction 'left' | 'right' | 'up' | 'down'
local function move_in_direction(direction)
  local focused_window = catmint.get_focused_window()
  if focused_window == nil then return end

  local adjacent_output = catmint.get_output_in_direction(focused_window, direction)
  if adjacent_output == nil then return end

  focused_window.x = adjacent_output.x
  focused_window.y = adjacent_output.y + C.BAR_HEIGHT
  focused_window.z = 99 -- raise
  focused_window.width = adjacent_output.width
  focused_window.height = adjacent_output.height - C.BAR_HEIGHT

  catnip.cursor.x = focused_window.x + focused_window.width / 2
  catnip.cursor.y = focused_window.y + focused_window.height / 2
end

---@param direction 'left' | 'right' | 'up' | 'down'
local function swap_in_direction(direction)
  local focused_window = catmint.get_focused_window()
  if focused_window == nil then return end

  local adjacent_window = catmint.get_window_in_direction(focused_window, direction)
  if adjacent_window == nil then return end

  catmint.swap_windows(focused_window, adjacent_window)
end

---@param direction 'forwards' | 'backwards'
local function cycle_windows(direction)
  local focused_window = catmint.get_focused_window()
  if focused_window == nil then return end

  local focused_output = catmint.get_window_outputs(focused_window)[1]
  if focused_output == nil then return end

  local output_windows, num_output_windows = catmint.get_output_windows(focused_output);
  if num_output_windows < 2 then return end

  table.sort(output_windows, function(a, b) return a.z < b.z end)

  if direction == 'forwards' then
    output_windows[num_output_windows].z = output_windows[1].z
    output_windows[num_output_windows - 1].focused = true
  elseif direction == 'backwards' then
    output_windows[1].z = output_windows[num_output_windows].z + 1
    output_windows[1].focused = true
  end
end

---@param direction 'forwards' | 'backwards'
local function shift_windows(direction)
  local focused_window = catmint.get_focused_window()
  if focused_window == nil then return end

  local focused_output = catmint.get_window_outputs(focused_window)[1]
  if focused_output == nil then return end

  local output_windows, num_output_windows = catmint.get_output_windows(focused_output);
  if num_output_windows < 2 then return end

  table.sort(output_windows, function(a, b) return a.z < b.z end)

  if direction == 'forwards' then
    output_windows[num_output_windows - 1].z = output_windows[1].z
  elseif direction == 'backwards' then
    output_windows[1].z = output_windows[num_output_windows].z
  end
end

-- -----------------------------------------------------------------------------
-- Keymaps
-- -----------------------------------------------------------------------------

keymap({ 'mod1' }, 'h', function() focus_in_direction('left') end)
keymap({ 'mod1' }, 'j', function() focus_in_direction('down') end)
keymap({ 'mod1' }, 'k', function() focus_in_direction('up') end)
keymap({ 'mod1' }, 'l', function() focus_in_direction('right') end)

keymap({ 'mod1' }, 'H', function() move_in_direction('left') end)
keymap({ 'mod1' }, 'J', function() move_in_direction('down') end)
keymap({ 'mod1' }, 'K', function() move_in_direction('up') end)
keymap({ 'mod1' }, 'L', function() move_in_direction('right') end)

keymap({ 'mod1', 'ctrl' }, 'H', function() swap_in_direction('left') end)
keymap({ 'mod1', 'ctrl' }, 'J', function() swap_in_direction('down') end)
keymap({ 'mod1', 'ctrl' }, 'K', function() swap_in_direction('up') end)
keymap({ 'mod1', 'ctrl' }, 'L', function() swap_in_direction('right') end)

keymap({ 'mod1' }, 'Tab', function() cycle_windows('forwards') end)
keymap({ 'mod1', 'shift' }, 'ISO_Left_Tab', function() cycle_windows('backwards') end)

keymap({ 'mod1' }, '>', function() shift_windows('forwards') end)
keymap({ 'mod1' }, '<', function() shift_windows('backwards') end)

-- -----------------------------------------------------------------------------
-- Subscriptions
-- -----------------------------------------------------------------------------

catnip.subscribe('window::create', function(window)
  local cursor_output = catmint.get_cursor_outputs()[1]
  if cursor_output == nil then return end

  -- TODO: hide bar for 1 client

  window.x = cursor_output.x
  window.y = cursor_output.y + C.BAR_HEIGHT
  window.width = cursor_output.width
  window.height = cursor_output.height - C.BAR_HEIGHT
  window.focused = true

  catnip.cursor.x = cursor_output.x + cursor_output.width / 2
  catnip.cursor.y = cursor_output.y + cursor_output.height / 2
end)

catnip.subscribe('window::destroy', function(window)
  if not window.focused then
    return
  end

  -- TODO: hide bar for 1 client

  local focused_output = catmint.get_window_outputs(window)[1]
  if focused_output == nil then return end

  local output_windows, num_output_windows = catmint.get_output_windows(focused_output);
  table.sort(output_windows, function(a, b) return a.z < b.z end)

  for i = num_output_windows, 1, -1 do
    if output_windows[i] ~= window then
      output_windows[i].focused = true
      break
    end
  end
end)
