local plugins = require('lib.plugins')

plugins.use('navarasu/onedark.nvim')

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

local onedark = require('onedark')
onedark.setup({ style = 'warmer' })
onedark.load()
