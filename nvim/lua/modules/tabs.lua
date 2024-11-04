vim.keymap.set('n', '<c-t>', function() vim.cmd('tabnew ' .. vim.fn.getcwd()) end)
vim.keymap.set('n', '<Tab>', function() vim.cmd('tabnext') end)
vim.keymap.set('n', '<S-Tab>', function() vim.cmd('tabprevious') end)
vim.keymap.set('n', '<', function() pcall(function() vim.cmd('-tabmove') end) end)
vim.keymap.set('n', '>', function() pcall(function() vim.cmd('+tabmove') end) end)
