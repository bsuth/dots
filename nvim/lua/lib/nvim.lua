local M = {}

---@param buffer integer
---@param mode string
---@param lhs string
---@param rhs string | function
function M.nvim_buf_keymap(buffer, mode, lhs, rhs)
  local options = { noremap = true }

  if type(rhs) == 'function' then
    options.callback = rhs
    rhs = ''
  end

  vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, options)
end

---@param termcodes string
function M.nvim_feed_termcodes(termcodes)
  local keys = vim.api.nvim_replace_termcodes(termcodes, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end

---@return number, number
function M.nvim_get_position()
  local position = vim.fn.getpos('.')
  return position[2], position[3]
end

---@return string
function M.nvim_get_visual_selection()
  -- Do not use '> and '< registers in getpos! These registers are only updated
  -- _after_ leaving visual mode.
  -- @see https://github.com/neovim/neovim/pull/13896#issuecomment-774680224
  local _, line_start, column_start = unpack(vim.fn.getpos('v'))
  local _, line_end, column_end = unpack(vim.fn.getcurpos())

  local lines = vim.fn.getline(line_start, line_end)
  vim.fn.setpos('.', { 0, line_start, column_start, 0 })

  if type(lines) == 'string' then
    return lines
  elseif #lines == 1 then
    lines[1] = lines[1]:sub(column_start, column_end)
  elseif #lines > 1 then
    lines[1] = lines[1]:sub(column_start)
    lines[#lines] = lines[#lines]:sub(1, column_end)
  end

  return table.concat(lines, '\n')
end

return M
