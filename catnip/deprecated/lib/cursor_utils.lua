local catnip = require('catnip')

local M = {}

--- ----------------------------------------------------------------------------
--- API
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
--- Return
--- ----------------------------------------------------------------------------

return M
