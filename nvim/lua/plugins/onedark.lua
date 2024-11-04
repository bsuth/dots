local plugins = require('utils.plugins')

plugins.use('navarasu/onedark.nvim')

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

local onedark = require('onedark')
local palette = require('onedark.palette').warmer

onedark.setup({ style = 'warmer' })
onedark.load()

vim.api.nvim_set_hl(0, 'NormalFloat', { bg = palette.bg0 })
