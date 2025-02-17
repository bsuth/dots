local C = require('constants')
local plugins = require('lib.plugins')

plugins.use('tpope/vim-fugitive')

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

table.insert(C.TRACK_CWD_FILTERS, function(buffer)
  return vim.api.nvim_get_option_value('filetype', { buf = buffer }) == 'fugitive'
end)

table.insert(C.TRACK_CWD_FILTERS, function(buffer)
  return vim.api.nvim_get_option_value('filetype', { buf = buffer }) == 'git'
end)

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<c-g>', ':Git ')
