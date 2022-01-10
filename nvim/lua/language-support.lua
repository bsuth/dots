-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

map('n', '<leader>lsp', ':silent :LspRestart<cr>')

-- map('n', 'gD', ':lua vim.lsp.buf.declaration()<cr>')
-- map('n', 'gd', ':lua vim.lsp.buf.definition()<cr>')
-- map('n', 'K', ':lua vim.lsp.buf.hover()<cr>')
-- map('n', 'gi', ':lua vim.lsp.buf.implementation()<cr>')
-- map('n', '<C-k>', ':lua vim.lsp.buf.signature_help()<cr>')
-- map('n', '<space>wa', ':lua vim.lsp.buf.add_workspace_folder()<cr>')
-- map('n', '<space>wr', ':lua vim.lsp.buf.remove_workspace_folder()<cr>')
-- map('n', '<space>wl', ':lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>')
-- map('n', '<space>D', ':lua vim.lsp.buf.type_definition()<cr>')
-- map('n', '<space>rn', ':lua vim.lsp.buf.rename()<cr>')
-- map('n', '<space>ca', ':lua vim.lsp.buf.code_action()<cr>')
-- map('n', 'gr', ':lua vim.lsp.buf.references()<cr>')
map('n', "'e", ':lua vim.lsp.diagnostic.show_line_diagnostics()<cr>')
-- map('n', '[d', ':lua vim.lsp.diagnostic.goto_prev()<cr>')
-- map('n', ']d', ':lua vim.lsp.diagnostic.goto_next()<cr>')
-- map('n', '<space>q', ':lua vim.lsp.diagnostic.set_loclist()<cr>')
-- map('n', '<space>f', ':lua vim.lsp.buf.formatting()<cr>')

-- -----------------------------------------------------------------------------
-- Treesitter
-- https://github.com/nvim-treesitter/nvim-treesitter
-- -----------------------------------------------------------------------------

require('nvim-treesitter.configs').setup({
  ensure_installed = 'maintained',
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
      fn['vsnip#anonymous'](args.body)
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
  tsserver = {},
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

function prettierFormatter()
  return {
    exe = 'prettierd',
    args = { nvim_buf_get_name(0) },
    stdin = true,
  }
end

vim.cmd([[
  augroup formatonsave
    autocmd!
    au BufWritePost *.jsonc,*.json FormatWrite
    au BufWritePost *.js,*.jsx,*.ts,*.tsx FormatWrite
    au BufWritePost *.css,*.scss,*.less FormatWrite
  augroup END
]])

formatter.setup({
  filetype = {
    json = { prettierFormatter },
    javascript = { prettierFormatter },
    javascriptreact = { prettierFormatter },
    typescript = { prettierFormatter },
    typescriptreact = { prettierFormatter },
    css = { prettierFormatter },
    scss = { prettierFormatter },
  },
})
