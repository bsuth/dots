local C = require('constants')
local edit = require('utils.edit')

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

-- Do not make this local! zsh needs this for exit hook in nested terminal.
function RESTORE_TERM_WINDOW_BUFFER()
  local buffer = vim.api.nvim_get_current_buf()
  local window = vim.api.nvim_get_current_win()

  local needs_restore = (
    vim.api.nvim_win_get_buf(window) == buffer and
    vim.api.nvim_get_option_value('buftype', { buf = buffer }) == 'terminal'
  )

  if not needs_restore then
    return
  end

  edit(vim.fn.getcwd())
end

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
