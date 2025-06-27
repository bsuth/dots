local plugins = require('lib.plugins')

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>o', vim.diagnostic.open_float)                          -- o(pen)
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename)                                 -- r(ename)
vim.keymap.set('n', '<leader>d', vim.lsp.buf.definition)                             -- d(efinition)
vim.keymap.set('n', '<leader>p', function() vim.diagnostic.jump({ count = -1 }) end) -- p(rev)
vim.keymap.set('n', '<leader>n', function() vim.diagnostic.jump({ count = 1 }) end)  -- n(ext)
vim.keymap.set('n', '<leader>l', vim.diagnostic.setloclist)                          -- l(ist)
vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action)                            -- a(ction)

-- -----------------------------------------------------------------------------
-- Mason (Language Servers)
-- -----------------------------------------------------------------------------

plugins.use('williamboman/mason.nvim')
plugins.use('williamboman/mason-lspconfig.nvim')

require('mason').setup()
require('mason-lspconfig').setup()

-- -----------------------------------------------------------------------------
-- Completion
-- -----------------------------------------------------------------------------

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

-- -----------------------------------------------------------------------------
-- lazydev
-- -----------------------------------------------------------------------------

-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
plugins.use('folke/lazydev.nvim')
require('lazydev').setup()

-- -----------------------------------------------------------------------------
-- LSP Config
-- -----------------------------------------------------------------------------

plugins.use('neovim/nvim-lspconfig')

local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local mason_registry = require('mason-registry')

---@param server string
---@param config table?
---@param snippets boolean?
local function setup_lsp(server, config, snippets)
  local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.completion.completionItem.snippetSupport = snippets or false
  lspconfig[server].setup(vim.tbl_deep_extend('force', { capabilities = capabilities }, config or {}))
end

setup_lsp('clangd')
setup_lsp('cssls', nil, true)
setup_lsp('eslint')
setup_lsp('gopls')
setup_lsp('lua_ls')
setup_lsp('pyright')
setup_lsp('ruff')
setup_lsp('tailwindcss', nil, true)
setup_lsp('volar')

setup_lsp('elixirls', {
  settings = {
    cmd = vim.fn.stdpath('data') .. '/mason/bin/elixir-ls'
  },
})

setup_lsp('ts_ls', {
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = mason_registry.get_package('vue-language-server'):get_install_path() ..
            '/node_modules/@vue/language-server',
        languages = { 'vue' },
      },
    },
  },
  filetypes = {
    'typescript',
    'javascript',
    'javascriptreact',
    'typescriptreact',
    'vue',
  },
})
