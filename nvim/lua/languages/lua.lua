-- -----------------------------------------------------------------------------
-- LSP
-- -----------------------------------------------------------------------------

vim.lsp.enable('lua_ls', true)
vim.lsp.config('lua_ls', {
  cmd = { '/home/bsuth/.local/share/nvim/mason/bin/lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.git' },
})

-- -----------------------------------------------------------------------------
-- Format
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'bsuth',
  pattern = { '*.lua' },
  callback = function(args)
    vim.lsp.buf.format()

    -- Sometimes diagnostics seem to disappear after editing, so manually
    -- refresh here.
    vim.diagnostic.enable(true, { bufnr = args.buf })
  end,
})
