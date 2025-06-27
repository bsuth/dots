local M = {}

-- Get the current platform path separator. Note that while this is undocumented
-- in the Lua 5.1 manual, it is indeed supported in 5.1+.
-- https://www.lua.org/manual/5.3/manual.html#pdf-package.config
M.separator = package.config:sub(1, 1)

---@param s string
---@return string
function M.dedup(s)
  -- Wrap in parentheses to ensure we return only 1 value.
  return (s:gsub(M.separator .. '+', M.separator))
end

---@param ... string
---@return string
function M.join(...)
  return M.dedup(table.concat({ ... }, M.separator))
end

---@param ... string
---@return string
function M.trim(...)
  -- Wrap in parentheses to ensure we return only 1 value.
  return (M.join(...):gsub('^' .. M.separator .. '+', ''):gsub(M.separator .. '+$', ''))
end

---@param ... string
---@return string
function M.pad(...)
  return M.dedup(M.separator .. M.join(...) .. M.separator)
end

---@param ... string
---@return string
function M.lead(...)
  return M.separator .. M.trim(...)
end

---@param ... string
---@return string
function M.trail(...)
  return M.trim(...) .. M.separator
end

---@param s string
---@return string
function M.basename(s)
  return s:match('[^' .. M.separator .. ']*$')
end

---@param s string
---@return string
function M.dirname(s)
  -- Wrap in parentheses to ensure we return only 1 value.
  return (s:gsub('[^' .. M.separator .. ']*$', ''))
end

return M
