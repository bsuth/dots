local C = require('constants')

-- -----------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------

local buffer_cwd = {}

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

-- Do not make this local! zsh needs this for cd hook in nested terminal.
function SAVE_BUFFER_CWD()
  local buffer = vim.api.nvim_get_current_buf()
  buffer_cwd[buffer] = vim.fn.getcwd()
end

-- -----------------------------------------------------------------------------
-- Filters
-- -----------------------------------------------------------------------------

table.insert(C.TRACK_CWD_FILTERS, function(buffer)
  return vim.api.nvim_buf_get_option(buffer, 'filetype') == 'help'
end)

table.insert(C.TRACK_CWD_FILTERS, function(buffer)
  return vim.api.nvim_buf_get_option(buffer, 'filetype') == 'man'
end)

table.insert(C.TRACK_CWD_FILTERS, function(buffer)
  return vim.api.nvim_buf_get_option(buffer, 'buftype') == 'terminal'
end)

table.insert(C.TRACK_CWD_FILTERS, function(buffer)
  return vim.api.nvim_buf_get_option(buffer, 'buftype') == 'prompt'
end)

table.insert(C.TRACK_CWD_FILTERS, function(buffer)
  return vim.api.nvim_buf_get_name(buffer):match('^/tmp/nvim.bsuth')
end)

-- -----------------------------------------------------------------------------
-- Autocommands
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('TermOpen', {
  group = 'bsuth',
  callback = SAVE_BUFFER_CWD,
})

vim.api.nvim_create_autocmd('TermClose', {
  group = 'bsuth',
  callback = function(params)
    buffer_cwd[params.buf] = nil
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = 'bsuth',
  callback = function()
    local buffer = vim.api.nvim_get_current_buf()

    if buffer_cwd[buffer] ~= nil then
      vim.cmd('cd ' .. buffer_cwd[buffer])
      return
    end

    for _, filter in ipairs(C.TRACK_CWD_FILTERS) do
      if filter(buffer) then
        return
      end
    end

    vim.cmd('cd ' .. vim.fn.expand('%:p:h'))
  end,
})
