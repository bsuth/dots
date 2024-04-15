local C = require('constants')
local edit = require('utils.edit')

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<c-space>', ':term<cr>')
vim.keymap.set('t', '<c-[>', '<c-\\><c-n>')
vim.keymap.set('t', '<esc>', '<c-\\><c-n>')

-- -----------------------------------------------------------------------------
-- Autocommands
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('TermOpen', {
  group = 'bsuth',
  pattern = C.TERM_PATTERNS,
  callback = function()
    vim.wo.number = false
    vim.wo.wrap = true
    vim.cmd('startinsert')
  end,
})

vim.api.nvim_create_autocmd('TermClose', {
  group = 'bsuth',
  pattern = C.TERM_PATTERNS,
  callback = function()
    local buffer = vim.api.nvim_win_get_buf(0)
    edit(vim.fn.getcwd())
    vim.api.nvim_buf_delete(buffer, {})
  end,
})
