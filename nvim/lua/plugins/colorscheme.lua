local plugins = require('lib.plugins')

plugins.use('navarasu/onedark.nvim')

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

require('onedark').setup({ style = 'cool' })
require('onedark').colorscheme()
