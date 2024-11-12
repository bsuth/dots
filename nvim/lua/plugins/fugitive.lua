local C = require('constants')
local plugins = require('lib.plugins')

plugins.use('tpope/vim-fugitive')

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

table.insert(C.TRACK_CWD_FILTERS, function(buffer)
  return vim.api.nvim_buf_get_option(buffer, 'filetype') == 'fugitive'
end)

table.insert(C.TRACK_CWD_FILTERS, function(buffer)
  return vim.api.nvim_buf_get_option(buffer, 'filetype') == 'git'
end)

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<c-g>', ':Git ')
