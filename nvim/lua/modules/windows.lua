-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

local function is_point_in_rect(point, rect)
  return (
    (rect.x <= point.x and point.x <= rect.x + rect.width) and
    (rect.y <= point.y and point.y <= rect.y + rect.height)
  )
end

local function get_window_rect(window)
  local position = vim.api.nvim_win_get_position(window)
  local width = vim.api.nvim_win_get_width(window)
  local height = vim.api.nvim_win_get_height(window)
  return { x = position[2], y = position[1], width = width, height = height }
end

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

vim.keymap.set('n', '<leader><c-h>', function() split_window('left') end)
vim.keymap.set('n', '<leader><c-j>', function() split_window('down') end)
vim.keymap.set('n', '<leader><c-k>', function() split_window('up') end)
vim.keymap.set('n', '<leader><c-l>', function() split_window('right') end)
vim.keymap.set('n', '<leader><c-left>', function() split_window('left') end)
vim.keymap.set('n', '<leader><c-down>', function() split_window('down') end)
vim.keymap.set('n', '<leader><c-up>', function() split_window('up') end)
vim.keymap.set('n', '<leader><c-right>', function() split_window('right') end)

vim.keymap.set('n', '<leader><m-h>', function() swap_window('left') end)
vim.keymap.set('n', '<leader><m-j>', function() swap_window('down') end)
vim.keymap.set('n', '<leader><m-k>', function() swap_window('up') end)
vim.keymap.set('n', '<leader><m-l>', function() swap_window('right') end)
vim.keymap.set('n', '<leader><m-left>', function() swap_window('left') end)
vim.keymap.set('n', '<leader><m-down>', function() swap_window('down') end)
vim.keymap.set('n', '<leader><m-up>', function() swap_window('up') end)
vim.keymap.set('n', '<leader><m-right>', function() swap_window('right') end)
