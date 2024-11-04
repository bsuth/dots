local catnip = require('catnip')
local geometry = require('lib.geometry')

local M = {}

--- ----------------------------------------------------------------------------
--- API
--- ----------------------------------------------------------------------------

---@return CatnipWindow[]
function M.get_visible_windows()
  local visible_windows = {}

  for window in catnip.windows do
    if window.visible then
      table.insert(visible_windows, window)
    end
  end

  return visible_windows
end

---@param window CatnipWindow
---@param output CatnipOutput
---@return boolean
function M.is_window_in_output(window, output)
  return (
    window.x >= output.x and
    window.x + window.width <= output.x + output.width and
    window.y >= output.y and
    window.y + window.height <= output.y + output.height
  )
end

---@param window CatnipWindow
---@return CatnipOutput[]
function M.get_window_outputs(window)
  local window_outputs = {}

  for output in catnip.outputs do
    if M.is_window_in_output(window, output) then
      table.insert(window_outputs, output)
    end
  end

  return window_outputs
end

---@param source { x: number, y: number, width: number | nil, height: number | nil }
---@param direction 'left' | 'right' | 'up' | 'down'
---@return CatnipWindow | nil
function M.get_window_in_direction(source, direction)
  local closest_window = nil
  local closest_window_distance = math.huge
  local closest_window_y = math.huge

  for window in catnip.windows do
    if geometry.is_in_direction(source, window, direction) then
      local distance = geometry.get_distance_in_direction(source, window, direction)

      local is_closest_window = (
        distance < closest_window_distance or
        (distance == closest_window_distance and window.y < closest_window_y)
      )

      if is_closest_window then
        closest_window = window
        closest_window_distance = distance
        closest_window_y = window.y
      end
    end
  end

  return closest_window
end

---@param window1 CatnipWindow
---@param window2 CatnipWindow
function M.swap_windows(window1, window2)
  local tmp = {
    x = window1.x,
    y = window1.y,
    z = window1.z,
    width = window1.width,
    height = window1.height,
  }

  window1.x = window2.x
  window1.y = window2.y
  window1.z = window2.z
  window1.width = window2.width
  window1.height = window2.height

  window2.x = tmp.x
  window2.y = tmp.y
  window2.z = tmp.z
  window2.width = tmp.width
  window2.height = tmp.height
end

--- ----------------------------------------------------------------------------
--- Return
--- ----------------------------------------------------------------------------

return M
