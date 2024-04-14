local catnip = require('catnip')

local M = {}

--- @return CatnipWindow | nil
function M.get_focused_window()
  for window in catnip.windows do
    if window.focused then
      return window
    end
  end
end

--- @return CatnipWindow[]
function M.get_visible_windows()
  local visible_windows = {}

  for window in catnip.windows do
    if window.visible then
      table.insert(visible_windows, window)
    end
  end

  return visible_windows
end

--- @param window1 CatnipWindow
--- @param window2 CatnipWindow
--- @param direction CatnipDirection
--- @return number | nil
function M.get_window_distance_in_direction(window1, window2, direction)
  if direction == 'left' then
    return (
      window2.x < window1.x and
      window2.y < window1.y + window1.height and
      window2.y + window2.height > window1.y and
      window1.x - window2.x or
      nil
    )
  elseif direction == 'right' then
    return (
      window2.x + window2.width > window1.x + window1.width and
      window2.y < window1.y + window1.height and
      window2.y + window2.height > window1.y and
      (window2.x + window2.width) - (window1.x + window1.width) or
      nil
    )
  elseif direction == 'up' then
    return (
      window2.y < window1.y and
      window2.x < window1.x + window1.width and
      window2.x + window2.width > window1.x and
      window1.y - window2.y or
      nil
    )
  elseif direction == 'down' then
    return (
      window2.y + window2.height > window1.y + window1.height and
      window2.x < window1.x + window1.width and
      window2.x + window2.width > window1.x and
      (window2.y + window2.height) - (window1.y + window1.height) or
      nil
    )
  end
end

--- @param direction CatnipDirection
--- @param source_window? CatnipWindow
--- @return CatnipWindow | nil
function M.get_window_in_direction(direction, source_window)
  source_window = source_window or M.get_focused_window()

  if source_window == nil then
    return nil
  end

  local closest_window --- @type CatnipWindow | nil
  local closest_window_distance = math.huge

  for window in catnip.windows do
    local distance = M.get_window_distance_in_direction(source_window, window, direction)
    if distance and distance < closest_window_distance then
      closest_window = window
      closest_window_distance = distance
    end
  end

  return closest_window
end

--- @param direction CatnipDirection
--- @param window? CatnipWindow
function M.focus_window_in_direction(direction, window)
  window = window or M.get_focused_window()

  if window == nil then
    return
  end

  local new_focused_window = M.get_window_in_direction(direction, window)

  if new_focused_window == nil then
    return
  end

  new_focused_window.focused = true
end

--- @param window1 CatnipWindow
--- @param window2 CatnipWindow
function M.swap_windows(window1, window2)
  local tmp = {
    x = window1.x,
    y = window1.y,
    width = window1.width,
    height = window1.height,
  }

  window1:move(window2.x, window2.y)
  window1:resize(window2.width, window2.height)

  window2:move(tmp.x, tmp.y)
  window2:resize(tmp.width, tmp.height)
end

--- @param direction CatnipDirection
--- @param window? CatnipWindow
function M.swap_window_in_direction(direction, window)
  window = window or M.get_focused_window()

  if window == nil then
    return
  end

  local swap_window = M.get_window_in_direction(direction, window)

  if swap_window == nil then
    return
  end

  M.swap_windows(window, swap_window)
end

return M
