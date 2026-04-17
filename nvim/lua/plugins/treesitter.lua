local plugins = require('lib.plugins')

plugins.use('romus204/tree-sitter-manager.nvim')

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

require("tree-sitter-manager").setup({
  auto_install = true,
})
