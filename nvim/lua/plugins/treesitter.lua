local plugins = require('utils.plugins')

plugins.use('nvim-treesitter/nvim-treesitter')

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

require('nvim-treesitter.configs').setup({
  auto_install = true,
  sync_install = false,
  ignore_install = {},
  modules = {},
  highlight = { enable = true },
  ensure_installed = {
    'bash',
    'c',
    'cpp',
    'css',
    'dockerfile',
    'elixir',
    'git_config',
    'git_rebase',
    'gitattributes',
    'gitcommit',
    'gitignore',
    'go',
    'html',
    'javascript',
    'json',
    'lua',
    'make',
    'markdown',
    'scss',
    'sql',
    'toml',
    'typescript',
    'vimdoc',
    'vue',
    'yaml',
  },
})
