local C = require('constants')
local path = require('utils.path')
local plugins = require('utils.plugins')

-- -----------------------------------------------------------------------------
-- Color Scheme
-- -----------------------------------------------------------------------------

plugins.use('navarasu/onedark.nvim')

local onedark = require('onedark')
local palette = require('onedark.palette').warmer

onedark.setup({ style = 'warmer' })
onedark.load()

vim.api.nvim_set_hl(0, 'NormalFloat', { bg = palette.bg0 })

-- -----------------------------------------------------------------------------
-- Treesitter
-- -----------------------------------------------------------------------------

plugins.use('nvim-treesitter/nvim-treesitter')

local treesitter_configs = require('nvim-treesitter.configs')

treesitter_configs.setup({
  auto_install = true,
  sync_install = false,
  ignore_install = {},
  modules = {},
  highlight = { enable = true },
  ensure_installed = {
    'bash',
    'c',
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

-- -----------------------------------------------------------------------------
-- Erde
-- -----------------------------------------------------------------------------

plugins.use(path.join(C.HOME, 'repos/vim-erde'), { symlink = true })

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
