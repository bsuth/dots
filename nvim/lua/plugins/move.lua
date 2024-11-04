local plugins = require('utils.plugins')

plugins.use('matze/vim-move')

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

vim.g.move_map_keys = false

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<m-h>', '<Plug>MoveCharLeft')
vim.keymap.set('n', '<m-j>', '<Plug>MoveLineDown')
vim.keymap.set('n', '<m-k>', '<Plug>MoveLineUp')
vim.keymap.set('n', '<m-l>', '<Plug>MoveCharRight')
vim.keymap.set('n', '<m-left>', '<Plug>MoveCharLeft')
vim.keymap.set('n', '<m-down>', '<Plug>MoveLineDown')
vim.keymap.set('n', '<m-up>', '<Plug>MoveLineUp')
vim.keymap.set('n', '<m-right>', '<Plug>MoveCharRight')

vim.keymap.set('v', '<m-h>', '<Plug>MoveBlockLeft')
vim.keymap.set('v', '<m-j>', '<Plug>MoveBlockDown')
vim.keymap.set('v', '<m-k>', '<Plug>MoveBlockUp')
vim.keymap.set('v', '<m-l>', '<Plug>MoveBlockRight')
vim.keymap.set('v', '<m-left>', '<Plug>MoveBlockLeft')
vim.keymap.set('v', '<m-down>', '<Plug>MoveBlockDown')
vim.keymap.set('v', '<m-up>', '<Plug>MoveBlockUp')
vim.keymap.set('v', '<m-left>', '<Plug>MoveBlockRight')
