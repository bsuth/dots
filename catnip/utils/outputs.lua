local catnip = require('catnip')

local M = {}

--- @return CatnipOutput | nil
function M.get_focused_output()
  for output in catnip.outputs do
    local is_cursor_in_output = not (
      catnip.cursor.x < output.x or
      catnip.cursor.x > output.x + output.width or
      catnip.cursor.y < output.y or
      catnip.cursor.y > output.y + output.height
    )

    -- NOTE: Since outputs can share the same space, it is possible for there to
    -- be multiple "focused" outputs. However, this is usually not the case and
    -- this is provided simply as a helper function.
    if is_cursor_in_output then
      return output
    end
  end
end

--- @param output1 CatnipOutput
--- @param output2 CatnipOutput
--- @param direction CatnipDirection
--- @return number | nil
function M.get_output_distance_in_direction(output1, output2, direction)
  if direction == 'left' then
    return (
      output2.x < output1.x and
      output2.y < output1.y + output1.height and
      output2.y + output2.height > output1.y and
      output1.x - output2.x or
      nil
    )
  elseif direction == 'right' then
    return (
      output2.x + output2.width > output1.x + output1.width and
      output2.y < output1.y + output1.height and
      output2.y + output2.height > output1.y and
      (output2.x + output2.width) - (output1.x + output1.width) or
      nil
    )
  elseif direction == 'up' then
    return (
      output2.y < output1.y and
      output2.x < output1.x + output1.width and
      output2.x + output2.width > output1.x and
      output1.y - output2.y or
      nil
    )
  elseif direction == 'down' then
    return (
      output2.y + output2.height > output1.y + output1.height and
      output2.x < output1.x + output1.width and
      output2.x + output2.width > output1.x and
      (output2.y + output2.height) - (output1.y + output1.height) or
      nil
    )
  end
end

--- @param direction CatnipDirection
--- @param source_output? CatnipOutput
--- @return CatnipOutput | nil
function M.get_output_in_direction(direction, source_output)
  source_output = source_output or M.get_focused_output()

  if source_output == nil then
    return nil
  end

  local closest_output --- @type CatnipOutput | nil
  local closest_output_distance = math.huge

  for output in catnip.outputs do
    local distance = M.get_output_distance_in_direction(source_output, output, direction)
    if distance and distance < closest_output_distance then
      closest_output = output
      closest_output_distance = distance
    end
  end

  return closest_output
end

--- @param direction CatnipDirection
--- @param output? CatnipOutput
function M.focus_output_in_direction(direction, output)
  output = output or M.get_focused_output()

  if output == nil then
    return
  end

  local new_focused_output = M.get_output_in_direction(direction, output)

  if new_focused_output == nil then
    return
  end

  catnip.cursor:move(
    new_focused_output.x + new_focused_output.width / 2,
    new_focused_output.y + new_focused_output.height / 2
  )
end

--- @param output1 CatnipOutput
--- @param output2 CatnipOutput
function M.swap_outputs(output1, output2)
  local tmp = {
    x = output1.x,
    y = output1.y,
    width = output1.width,
    height = output1.height,
  }

  output1:move(output2.x, output2.y)
  output1:resize(output2.width, output2.height)

  output2:move(tmp.x, tmp.y)
  output2:resize(tmp.width, tmp.height)
end

--- @param direction CatnipDirection
--- @param output? CatnipOutput
function M.swap_output_in_direction(direction, output)
  output = output or M.get_focused_output()

  if output == nil then
    return
  end

  local swap_output = M.get_output_in_direction(direction, output)

  if swap_output == nil then
    return
  end

  M.swap_outputs(output, swap_output)
end

return M
