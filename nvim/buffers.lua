-- -----------------------------------------------------------------------------
-- GENERAL MAPPINGS
-- -----------------------------------------------------------------------------

vim.api.nvim_set_keymap('n', '<c-w>', ':bd<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-t>', ':Vifm<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Tab>', ':bn<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<s-Tab>', ':bp<cr>', { noremap = true })

-- -----------------------------------------------------------------------------
-- BUFFER LIST
-- -----------------------------------------------------------------------------

function hello()
	print('hello world?')
end

vim.api.nvim_set_keymap('n', '<leader>test', ':lua hello()<cr>', { noremap = true })

