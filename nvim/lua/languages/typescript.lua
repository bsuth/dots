-- -----------------------------------------------------------------------------
-- LSP
-- -----------------------------------------------------------------------------

vim.lsp.enable('vtsls', true)
vim.lsp.config('vtsls', {
  cmd = { 'vtsls', '--stdio' },
  filetypes = { 'typescript', 'javascript' },
  root_markers = { 'package.json', '.git' },
  init_options = { hostInfo = 'neovim' },
})
