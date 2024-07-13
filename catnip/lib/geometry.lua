local M = {}

--- ----------------------------------------------------------------------------
--- Types
--- ----------------------------------------------------------------------------

---@class Point
---@field x number
---@field y number

---@class Box
---@field x number
---@field y number
---@field width number
---@field height number

--- ----------------------------------------------------------------------------
--- API
--- ----------------------------------------------------------------------------

---@param source Point | Box
---@param target Point | Box
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

---@param source Point | Box
---@param target Point | Box
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
--- Return
--- ----------------------------------------------------------------------------

return M
