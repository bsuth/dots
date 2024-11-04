local plugins = require('utils.plugins')

plugins.use('tpope/vim-commentary')

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<c-_>', ':Commentary<cr>') -- <c-_> is secretly <c-/>
vim.keymap.set('v', '<c-_>', ':Commentary<cr>') -- <c-_> is secretly <c-/>
