local catnip = require('catnip')
local keymap = require('keymap')
local window_utils = require('windows.utils')

local function get_window_proximity(direction, source, target)
  if direction == "left" then
    return (target.top > source.bottom or target.bottom < source.top)
      and -1 or (source.left - target.left)
  elseif direction == "right" then
    return (target.top > source.bottom or target.bottom < source.top)
      and -1 or (target.right - source.right)
  elseif direction == "up" then
    return (target.left > source.right or target.right < source.left)
      and -1 or (source.top - target.top)
  elseif direction == "down" then
    return (target.left > source.right or target.right < source.left)
      and -1 or (target.bottom - source.bottom)
  end
end

local function get_window_in_direction(direction)
  local active_window = window_utils.get_active_window()

  if active_window == nil then
    return nil
  end

  local active_window_extents = window_utils.get_window_extents(active_window)

  local closest_window = nil
  local closest_window_proximity = -1

  for _, window in ipairs(catnip.windows) do
    local window_extents = window_utils.get_window_extents(window)

    local proximity = get_window_proximity(
      direction,
      active_window_extents,
      window_extents
    )

    local is_closer_proximity = (
      proximity > 0 and
      (closest_window_proximity == -1 or proximity < closest_window_proximity)
    )

    if is_closer_proximity then
      closest_window = window
      closest_window_proximity = proximity
    end
  end

  return closest_window
end

local function activate_window_in_direction(direction)
  local window = get_window_in_direction(direction)

  if window == nil then
    return
  end

  window.active = true
end

local function swap_window_in_direction(direction)
  local window = get_window_in_direction(direction)

  if window == nil then
    return
  end

  local active_window = window_utils.get_active_window()

  local active_window_box = {
    x = active_window.x,
    y = active_window.y,
    width = active_window.width,
    height = active_window.height,
  }

  active_window.x = window.x
  active_window.y = window.y
  active_window.width = window.width
  active_window.height = window.height

  window.x = active_window_box.x
  window.y = active_window_box.y
  window.width = active_window_box.width
  window.height = active_window_box.height
end

keymap({ 'alt' }, 'h', function()
  activate_window_in_direction('left')
end)

keymap({ 'alt' }, 'j', function()
  activate_window_in_direction('down')
end)

keymap({ 'alt' }, 'k', function()
  activate_window_in_direction('up')
end)

keymap({ 'alt' }, 'l', function()
  activate_window_in_direction('right')
end)

keymap({ 'alt', 'ctrl' }, 'h', function()
  swap_window_in_direction('left')
end)

keymap({ 'alt', 'ctrl' }, 'j', function()
  swap_window_in_direction('down')
end)

keymap({ 'alt', 'ctrl' }, 'k', function()
  swap_window_in_direction('up')
end)

keymap({ 'alt', 'ctrl' }, 'l', function()
  swap_window_in_direction('right')
end)
