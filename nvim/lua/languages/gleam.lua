-- -----------------------------------------------------------------------------
-- LSP
-- -----------------------------------------------------------------------------

vim.lsp.enable('gleam', true)
vim.lsp.config('gleam', {
  cmd = { 'gleam', 'lsp' },
  filetypes = { 'gleam' },
  root_markers = { 'gleam.toml', '.git' },
})

-- -----------------------------------------------------------------------------
-- Format
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'bsuth',
  pattern = { '*.gleam' },
  callback = function()
    vim.lsp.buf.format()
  end,
})
