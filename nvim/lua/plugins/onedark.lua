local plugins = require('lib.plugins')

plugins.use('projekt0n/github-nvim-theme')

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

require('github-theme').setup({})
vim.cmd('colorscheme github_dark')
