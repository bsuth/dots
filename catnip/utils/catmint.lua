local catnip = require('catnip')

local M = {}

--- ----------------------------------------------------------------------------
--- Directions
--- ----------------------------------------------------------------------------

---@param source { x: number, y: number, width: number | nil, height: number | nil }
---@param target { x: number, y: number, width: number | nil, height: number | nil }
---@param direction 'left' | 'right' | 'up' | 'down'
---@return boolean
function M.is_in_direction(source, target, direction)
  if direction == 'left' then
    return (
      target.x < source.x and
      target.y <= source.y + (source.height or 0) and
      target.y + (target.height or 0) >= source.y
    )
  elseif direction == 'right' then
    return (
      target.x + (target.width or 0) > source.x + (source.width or 0) and
      target.y <= source.y + (source.height or 0) and
      target.y + (target.height or 0) >= source.y
    )
  elseif direction == 'up' then
    return (
      target.y < source.y and
      target.x <= source.x + (source.width or 0) and
      target.x + (target.width or 0) >= source.x
    )
  elseif direction == 'down' then
    return (
      target.y + (target.height or 0) > source.y + (source.height or 0) and
      target.x <= source.x + (source.width or 0) and
      target.x + (target.width or 0) >= source.x
    )
  else
    return false
  end
end

---@param source { x: number, y: number, width: number | nil, height: number | nil }
---@param target { x: number, y: number, width: number | nil, height: number | nil }
---@param direction 'left' | 'right' | 'up' | 'down'
---@return number
function M.get_distance_in_direction(source, target, direction)
  if direction == 'left' then
    return source.x - target.x
  elseif direction == 'right' then
    return (target.x + (target.width or 0)) - (source.x + (source.width or 0))
  elseif direction == 'up' then
    return source.y - target.y
  elseif direction == 'down' then
    return (target.y + (target.height or 0)) - (source.y + (source.height or 0))
  else
    return 0
  end
end

--- ----------------------------------------------------------------------------
--- Cursor
--- ----------------------------------------------------------------------------

---@param output CatnipOutput
---@return boolean
function M.is_cursor_in_output(output)
  return (
    catnip.cursor.x >= output.x and
    catnip.cursor.x <= output.x + output.width and
    catnip.cursor.y >= output.y and
    catnip.cursor.y <= output.y + output.height
  )
end

---@return CatnipOutput[]
function M.get_cursor_outputs()
  local cursor_outputs = {}

  for output in catnip.outputs do
    if M.is_cursor_in_output(output) then
      table.insert(cursor_outputs, output)
    end
  end

  return cursor_outputs
end

---@param box { x: number, y: number, width: number, height: number }
function M.center_cursor(box)
  catnip.cursor.x = box.x + box.width / 2
  catnip.cursor.y = box.y + box.height / 2
end

--- ----------------------------------------------------------------------------
--- Outputs
--- ----------------------------------------------------------------------------

---@param output CatnipOutput
---@return CatnipWindow[], number
function M.get_output_windows(output)
  local output_windows = {}
  local num_output_windows = 0

  for window in catnip.windows do
    if M.is_window_in_output(window, output) then
      num_output_windows = num_output_windows + 1
      output_windows[num_output_windows] = window
    end
  end

  return output_windows, num_output_windows
end

---@param source { x: number, y: number, width: number | nil, height: number | nil }
---@param direction 'left' | 'right' | 'up' | 'down'
---@return CatnipOutput | nil
function M.get_output_in_direction(source, direction)
  local closest_output = nil
  local closest_output_distance = math.huge

  for output in catnip.outputs do
    if M.is_in_direction(source, output, direction) then
      local distance = M.get_distance_in_direction(source, output, direction)

      if distance < closest_output_distance then
        closest_output = output
        closest_output_distance = distance
      end
    end
  end

  return closest_output
end

---@param output1 CatnipOutput
---@param output2 CatnipOutput
function M.swap_outputs(output1, output2)
  local tmp = {
    x = output1.x,
    y = output1.y,
    width = output1.width,
    height = output1.height,
  }

  output1.x = output2.x
  output1.y = output2.y
  output1.width = output2.width
  output1.height = output2.height

  output2.x = tmp.x
  output2.y = tmp.y
  output2.width = tmp.width
  output2.height = tmp.height
end

--- ----------------------------------------------------------------------------
--- Windows
--- ----------------------------------------------------------------------------

---@return CatnipWindow | nil
function M.get_focused_window()
  for window in catnip.windows do
    if window.focused then
      return window
    end
  end
end

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
  local closest_window_z = math.huge

  for window in catnip.windows do
    if M.is_in_direction(source, window, direction) then
      local distance = M.get_distance_in_direction(source, window, direction)

      local is_closest_window = (
        distance < closest_window_distance or
        (distance == closest_window_distance and window.z > closest_window_z)
      )

      if is_closest_window then
        closest_window = window
        closest_window_distance = distance
        closest_window_z = window.z
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
