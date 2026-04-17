local plugins = require('lib.plugins')

plugins.use('hrsh7th/nvim-cmp')
plugins.use('hrsh7th/cmp-nvim-lsp')
plugins.use('hrsh7th/cmp-path')
plugins.use('hrsh7th/cmp-buffer')

local cmp = require('cmp')

cmp.setup({
  mapping = {
    ['<c-Space>'] = cmp.mapping.complete(),
    ['<c-p>'] = cmp.mapping.select_prev_item(),
    ['<c-n>'] = cmp.mapping.select_next_item(),
    ['<s-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<up>'] = cmp.mapping.select_prev_item(),
    ['<down>'] = cmp.mapping.select_next_item(),
    ['<cr>'] = cmp.mapping.confirm(),
    ['<c-d>'] = cmp.mapping.scroll_docs(-4),
    ['<c-u>'] = cmp.mapping.scroll_docs(4),
    ['<c-c>'] = cmp.mapping.close(),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
  },
})
