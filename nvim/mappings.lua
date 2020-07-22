-- -----------------------------------------------------------------------------
-- GENERAL MAPPINGS
-- -----------------------------------------------------------------------------

vim.api.nvim_set_var('mapleader', ' ')
vim.api.nvim_set_keymap('n', '<leader>ev', ':Vifm ~/dots/nvim<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>sv', ':source $MYVIMRC<cr>', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>?', ':help ', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>v?', ':vert :help ', { noremap = true })

-- Clear highlighting and redraw
vim.api.nvim_set_keymap('n', '<leader>/', ':nohlsearch<cr><c-l>', { noremap = true })

-- For some reason, vim registers <c-/> as <c-_>
vim.api.nvim_set_keymap('n', '<c-_>', ':Commentary<cr>', { noremap = true })
vim.api.nvim_set_keymap('v', '<c-_>', ':Commentary<cr>', { noremap = true })

-- Terminal mode back to normal mode
vim.api.nvim_set_keymap('t', '<c-[>', '<c-\\><c-n>', { noremap = true })

-- -----------------------------------------------------------------------------
-- WINDOW MAPPINGS
-- -----------------------------------------------------------------------------

vim.api.nvim_set_keymap('n', '<leader>w', '<c-w>', { noremap = true })

vim.api.nvim_set_keymap('n', '<c-h>', '<c-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-j>', '<c-w>j', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-k>', '<c-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-l>', '<c-w>l', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader><c-h>', '<c-w>H', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader><c-j>', '<c-w>J', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader><c-k>', '<c-w>K', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader><c-l>', '<c-w>L', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>term', ':sp|:term<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>vterm', ':vsp|:term<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>sp', ':sp|:Vifm<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>vsp', ':vsp|:Vifm<cr>', { noremap = true })
