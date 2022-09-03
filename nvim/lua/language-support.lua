local C = require('constants')

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<leader>lsp', ':silent :LspRestart<cr>')
vim.keymap.set('n', "'e", vim.diagnostic.open_float)
vim.keymap.set('n', "'h", vim.lsp.buf.hover)
vim.keymap.set('n', "'d", vim.lsp.buf.definition)
vim.keymap.set('n', "'D", vim.lsp.buf.declaration)
vim.keymap.set('n', "'p", vim.diagnostic.goto_prev)
vim.keymap.set('n', "'n", vim.diagnostic.goto_next)
vim.keymap.set('n', "'r", vim.lsp.buf.references)
vim.keymap.set('n', "'q", vim.diagnostic.setloclist)
vim.keymap.set('n', "'s", vim.lsp.buf.rename)
vim.keymap.set('n', "'c", vim.lsp.buf.code_action)

-- map('n', "'i", ':lua vim.lsp.buf.implementation()<cr>')
-- map('n', "'k", ':lua vim.lsp.buf.signature_help()<cr>')
-- map('n', "<space>D", ':lua vim.lsp.buf.type_definition()<cr>')
-- map('n', "'f", ':lua vim.lsp.buf.formatting()<cr>')

-- -----------------------------------------------------------------------------
-- Treesitter
-- https://github.com/nvim-treesitter/nvim-treesitter
-- -----------------------------------------------------------------------------

require('nvim-treesitter.configs').setup({
  ensure_installed = 'all',
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = '<M-p>',
      node_decremental = '<M-n>',
    },
  },
  highlight = {
    enable = true,
  },
})

-- -----------------------------------------------------------------------------
-- LSP Completion
-- https://github.com/hrsh7th/nvim-cmp/
-- -----------------------------------------------------------------------------

local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },
  mapping = {
    ['<c-d>'] = cmp.mapping.scroll_docs(-4),
    ['<c-f>'] = cmp.mapping.scroll_docs(4),
    ['<c-Space>'] = cmp.mapping.complete(),
    ['<c-c>'] = cmp.mapping.close(),
    ['<cr>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
})

-- -----------------------------------------------------------------------------
-- LSP Config
-- https://github.com/neovim/nvim-lspconfig
-- -----------------------------------------------------------------------------

local lspconfig = require('lspconfig')
local lspCapabilities = require('cmp_nvim_lsp').update_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)

local lspServers = {
  clangd = {},
  cssls = {},
  graphql = {},
  gopls = {},
  eslint = {},
  tsserver = {},
  jsonls = {
    filetypes = { 'json', 'jsonc' },
    settings = {
      json = {
        -- https://www.schemastore.org
        schemas = {
          {
            fileMatch = { 'package.json' },
            url = 'https://json.schemastore.org/package.json',
          },
          {
            fileMatch = { 'tsconfig*.json' },
            url = 'https://json.schemastore.org/tsconfig.json',
          },
          {
            fileMatch = {
              '.prettierrc',
              '.prettierrc.json',
              'prettier.config.json',
            },
            url = 'https://json.schemastore.org/prettierrc.json',
          },
          {
            fileMatch = { '.eslintrc', '.eslintrc.json' },
            url = 'https://json.schemastore.org/eslintrc.json',
          },
          {
            fileMatch = { '.babelrc', '.babelrc.json', 'babel.config.json' },
            url = 'https://json.schemastore.org/babelrc.json',
          },
        },
      },
    },
  },
}

for server, config in pairs(lspServers) do
  lspconfig[server].setup(vim.tbl_deep_extend('force', {
    capabilities = lspCapabilities,
  }, config))
end

-- -----------------------------------------------------------------------------
-- Formatter
-- https://github.com/mhartington/formatter.nvim
-- -----------------------------------------------------------------------------

local formatter = require('formatter')

local function applyPrettier()
  return {
    exe = 'prettierd',
    args = { nvim_buf_get_name(0) },
    stdin = true,
  }
end

local function applyStylua()
  return {
    exe = 'stylua --search-parent-directories',
    args = { nvim_buf_get_name(0) },
    stdin = false,
  }
end

nvim_create_autocmd('BufWritePre', {
  group = 'bsuth',
  pattern = C.JS_PATTERNS,
  command = 'if exists(":EslintFixAll") | EslintFixAll',
})

nvim_create_autocmd('BufWritePre', {
  group = 'bsuth',
  command = 'FormatWrite',
  pattern = vim.tbl_flatten({
    C.JSON_PATTERNS,
    C.CSS_PATTERNS,
    C.JS_PATTERNS,
    { '*.graphql' },
  }),
})

formatter.setup({
  filetype = {
    lua = { applyStylua },
    json = { applyPrettier },
    javascript = { applyPrettier },
    javascriptreact = { applyPrettier },
    typescript = { applyPrettier },
    typescriptreact = { applyPrettier },
    graphql = { applyPrettier },
    css = { applyPrettier },
    scss = { applyPrettier },
    less = { applyPrettier },
  },
})
