local format = require('lib.format')

-- -----------------------------------------------------------------------------
-- LSP
-- -----------------------------------------------------------------------------

vim.lsp.enable('clangd', true)
vim.lsp.config('clangd', {
  cmd = { 'clangd' },
  filetypes = { 'c' },
  root_markers = {
    'compile_commands.json',
    '.clang-format',
    '.git',
  },
})

-- -----------------------------------------------------------------------------
-- Format
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufWritePost', {
  group = 'bsuth',
  pattern = { '*.c', '*.h' },
  callback = function(args)
    if format.has_ancestor(args.buf, { '.clang-format' }) then
      format.sync(args.buf, 'clang-format ' .. vim.api.nvim_buf_get_name(args.buf))
    end
  end,
})
