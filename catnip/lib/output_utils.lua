local catnip = require('catnip')
local geometry = require('lib.geometry')
local window_utils = require('lib.window_utils')

local M = {}

--- ----------------------------------------------------------------------------
--- API
--- ----------------------------------------------------------------------------

---@param output CatnipOutput
---@return CatnipWindow[], number
function M.get_output_windows(output)
  local output_windows = {}
  local num_output_windows = 0

  for window in catnip.windows do
    if window_utils.is_window_in_output(window, output) then
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
      local distance = geometry.get_distance_in_direction(source, output, direction)

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
--- Return
--- ----------------------------------------------------------------------------

return M
