local catnip = require('catnip')

local function get_active_window(direction)
  for _, window in ipairs(catnip.windows) do
    if window.active then
      return window
    end
  end
end

local function get_output_windows(output)
  local output_windows = {}

  for _, window in ipairs(catnip.windows) do
    local is_output_window = (
      output.x <= window.x and
      window.x + window.width <= output.x + output.width and
      output.y <= window.y and
      window.y + window.height <= output.y + output.height
    )

    if is_output_window then
      table.insert(output_windows, window)
    end
  end

  return output_windows
end

local function get_window_extents(window)
  local x = window.x
  local y = window.y
  local width = window.width
  local height = window.height
  return { left = x, right = x + width, top = y, bottom = y + height }
end

return {
  get_active_window = get_active_window,
  get_output_windows = get_output_windows,
  get_window_extents = get_window_extents,
}
