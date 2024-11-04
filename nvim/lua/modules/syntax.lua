-- -----------------------------------------------------------------------------
-- MDX
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('BufRead', {
  group = 'bsuth',
  pattern = '*.mdx',
  callback = function()
    vim.bo.syntax = 'markdown'
  end,
})
