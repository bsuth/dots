-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

---@param point { x: number, y: number }
---@param rect { x: number, y: number, width: number, height: number }
local function is_point_in_rect(point, rect)
  return (
    (rect.x <= point.x and point.x <= rect.x + rect.width) and
    (rect.y <= point.y and point.y <= rect.y + rect.height)
  )
end

---@param window number
---@return { x: number, y: number, width: number, height: number }
local function get_window_rect(window)
  local position = vim.api.nvim_win_get_position(window)
  local width = vim.api.nvim_win_get_width(window)
  local height = vim.api.nvim_win_get_height(window)
  return { x = position[2], y = position[1], width = width, height = height }
end

---@param direction 'left' | 'down' | 'up' | 'right'
local function split_window(direction)
  if direction == 'left' then
    vim.cmd('aboveleft vsp ' .. vim.fn.getcwd())
  elseif direction == 'down' then
    vim.cmd('rightbelow sp ' .. vim.fn.getcwd())
  elseif direction == 'up' then
    vim.cmd('aboveleft sp ' .. vim.fn.getcwd())
  elseif direction == 'right' then
    vim.cmd('rightbelow vsp ' .. vim.fn.getcwd())
  else
    error('Invalid split direction: ' .. direction)
  end
end

---@param direction 'left' | 'down' | 'up' | 'right'
local function swap_window(direction)
  local current_window = vim.api.nvim_get_current_win()
  local current_window_rect = get_window_rect(current_window)

  local swap_window_point = { x = 0, y = 0 }

  if direction == 'left' then
    swap_window_point.x = current_window_rect.x - 1
    swap_window_point.y = current_window_rect.y
  elseif direction == 'down' then
    swap_window_point.x = current_window_rect.x
    swap_window_point.y = current_window_rect.y + current_window_rect.height + 1
  elseif direction == 'up' then
    swap_window_point.x = current_window_rect.x
    swap_window_point.y = current_window_rect.y - 1
  elseif direction == 'right' then
    swap_window_point.x = current_window_rect.x + current_window_rect.width + 1
    swap_window_point.y = current_window_rect.y
  else
    error('Invalid split direction: ' .. direction)
  end

  for _, window in ipairs(vim.api.nvim_list_wins()) do
    if window ~= current_window and is_point_in_rect(swap_window_point, get_window_rect(window)) then
      local current_buffer = vim.api.nvim_win_get_buf(current_window)
      vim.api.nvim_win_set_buf(current_window, vim.api.nvim_win_get_buf(window))
      vim.api.nvim_win_set_buf(window, current_buffer)
      vim.cmd(('%dwincmd w'):format(vim.api.nvim_win_get_number(window)))
      return
    end
  end
end

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<c-h>', '<c-w>h')
vim.keymap.set('n', '<c-j>', '<c-w>j')
vim.keymap.set('n', '<c-k>', '<c-w>k')
vim.keymap.set('n', '<c-l>', '<c-w>l')
vim.keymap.set('n', '<c-left>', '<c-w>h')
vim.keymap.set('n', '<c-down>', '<c-w>j')
vim.keymap.set('n', '<c-up>', '<c-w>k')
vim.keymap.set('n', '<c-right>', '<c-w>l')

vim.keymap.set('n', '<c-s-h>', function() split_window('left') end)
vim.keymap.set('n', '<c-s-j>', function() split_window('down') end)
vim.keymap.set('n', '<c-s-k>', function() split_window('up') end)
vim.keymap.set('n', '<c-s-l>', function() split_window('right') end)
vim.keymap.set('n', '<c-s-left>', function() split_window('left') end)
vim.keymap.set('n', '<c-s-down>', function() split_window('down') end)
vim.keymap.set('n', '<c-s-up>', function() split_window('up') end)
vim.keymap.set('n', '<c-s-right>', function() split_window('right') end)

vim.keymap.set('n', '<m-s-h>', '<c-w>H')
vim.keymap.set('n', '<m-s-j>', '<c-w>J')
vim.keymap.set('n', '<m-s-k>', '<c-w>K')
vim.keymap.set('n', '<m-s-l>', '<c-w>L')
vim.keymap.set('n', '<m-s-left>', '<c-w>H')
vim.keymap.set('n', '<m-s-down>', '<c-w>J')
vim.keymap.set('n', '<m-s-up>', '<c-w>K')
vim.keymap.set('n', '<m-s-right>', '<c-w>L')

vim.keymap.set('n', '<m-c-s-h>', function() swap_window('left') end)
vim.keymap.set('n', '<m-c-s-j>', function() swap_window('down') end)
vim.keymap.set('n', '<m-c-s-k>', function() swap_window('up') end)
vim.keymap.set('n', '<m-c-s-l>', function() swap_window('right') end)
vim.keymap.set('n', '<m-c-s-left>', function() swap_window('left') end)
vim.keymap.set('n', '<m-c-s-down>', function() swap_window('down') end)
vim.keymap.set('n', '<m-c-s-up>', function() swap_window('up') end)
vim.keymap.set('n', '<m-c-s-right>', function() swap_window('right') end)
