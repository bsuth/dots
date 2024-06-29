local C = require('constants')
local path = require('utils.path')
local plugins = require('utils.plugins')

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<leader>lsp', ':silent :LspRestart<cr>')
vim.keymap.set('n', "''", vim.lsp.buf.hover)
vim.keymap.set('n', "'o", vim.diagnostic.open_float) -- o(pen)
vim.keymap.set('n', "'r", vim.lsp.buf.rename)        -- r(ename)
vim.keymap.set('n', "'d", vim.lsp.buf.definition)    -- d(efinition)
vim.keymap.set('n', "'p", vim.diagnostic.goto_prev)  -- p(rev)
vim.keymap.set('n', "'n", vim.diagnostic.goto_next)  -- n(ext)
vim.keymap.set('n', "'l", vim.diagnostic.setloclist) -- l(ist)
vim.keymap.set('n', "'u", vim.lsp.buf.references)    -- u(sage)
vim.keymap.set('n', "'a", vim.lsp.buf.code_action)   -- a(ction)

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
-- Neodev
-- -----------------------------------------------------------------------------

-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
plugins.use('folke/neodev.nvim')
require("neodev").setup({})

-- -----------------------------------------------------------------------------
-- LSP Config
-- -----------------------------------------------------------------------------

plugins.use('neovim/nvim-lspconfig')

local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

local mason_registry = require('mason-registry')

local LSP_SERVERS = {
  clangd = {},
  cssls = {},
  elixirls = { cmd = { path.join(C.HOME, '.local/share/nvim/mason/bin/elixir-ls') } },
  eslint = {},
  jsonls = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
      },
    },
  },
  tailwindcss = {},
  tsserver = {
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    init_options = {
      plugins = {
        {
          name = '@vue/typescript-plugin',
          languages = { 'vue' },
          location = mason_registry.get_package('vue-language-server'):get_install_path() ..
              '/node_modules/@vue/language-server',
        },
      },
    },
  },
  volar = {
    settings = {
      scss = {
        lint = {
          unknownAtRules = 'ignore',
        },
      }
    },
  },
}

for server, config in pairs(LSP_SERVERS) do
  local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.completion.completionItem.snippetSupport = false
  lspconfig[server].setup(vim.tbl_deep_extend('force', { capabilities = capabilities }, config))
end
