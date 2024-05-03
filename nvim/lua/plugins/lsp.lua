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

local LSP_SERVERS = {
  clangd = {},
  cssls = {},
  eslint = {},
  jsonls = {},
  elixirls = {
    cmd = { path.join(C.HOME, '.local/share/nvim/mason/bin/elixir-ls') },
  },
  tailwindcss = {},
  tsserver = {},
  volar = {
    filetypes = { 'vue', 'typescript' },
    settings = {
      scss = {
        lint = {
          unknownAtRules = 'ignore',
        },
      }
    },
  },
  lua_ls = {
    Lua = {
      format = {
        enable = true,
        defaultConfig = {
        },
      },
    },
  },
}

for server, config in pairs(LSP_SERVERS) do
  local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.completion.completionItem.snippetSupport = false
  lspconfig[server].setup(vim.tbl_deep_extend('force', { capabilities = capabilities }, config))
end

-- -----------------------------------------------------------------------------
-- Volar Takeover Mode
--
-- https://vuejs.org/guide/typescript/overview.html#volar-takeover-mode
-- -----------------------------------------------------------------------------

local volar_client = nil
local tsserver_client = nil

vim.api.nvim_create_autocmd('LspAttach', {
  group = 'bsuth',
  callback = function(params)
    local client = vim.lsp.get_client_by_id(params.data.client_id)

    if client.name == "tsserver" then
      if volar_client then
        client:stop()
      else
        tsserver_client = client
      end
    elseif client.name == "volar" then
      volar_client = client

      if tsserver_client then
        tsserver_client:stop()
      end
    end
  end,
})
