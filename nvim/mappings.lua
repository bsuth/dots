-- -----------------------------------------------------------------------------
-- GENERAL
-- -----------------------------------------------------------------------------

nvim.nvim_set_var('mapleader', ' ')
nvim.nvim_set_keymap('n', '<leader>ev', ':Vifm ~/dots/nvim<cr>', { noremap = true })
nvim.nvim_set_keymap('n', '<leader>sv', ':source $MYVIMRC<cr>', { noremap = true })

nvim.nvim_set_keymap('n', '<leader>?', ':help ', { noremap = true })
nvim.nvim_set_keymap('n', '<leader>v?', ':vert :help ', { noremap = true })

-- Clear highlighting and redraw
nvim.nvim_set_keymap('n', '<leader>/', ':nohlsearch<cr><c-l>', { noremap = true })

-- For some reason, vim registers <c-/> as <c-_>
nvim.nvim_set_keymap('n', '<c-_>', ':Commentary<cr>', { noremap = true })
nvim.nvim_set_keymap('v', '<c-_>', ':Commentary<cr>', { noremap = true })

-- Terminal mode back to normal mode
nvim.nvim_set_keymap('t', '<c-[>', '<c-\\><c-n>', { noremap = true })

-- Open console in current directory
nvim.nvim_set_keymap('n', '<leader><cr>', ':silent !st -e nvim -c ":term" 2>/dev/null &<cr>', { noremap = true })

-- -----------------------------------------------------------------------------
-- WINDOWS
-- -----------------------------------------------------------------------------

nvim.nvim_set_keymap('n', '<leader>w', '<c-w>', { noremap = true })

nvim.nvim_set_keymap('n', '<c-h>', '<c-w>h', { noremap = true })
nvim.nvim_set_keymap('n', '<c-j>', '<c-w>j', { noremap = true })
nvim.nvim_set_keymap('n', '<c-k>', '<c-w>k', { noremap = true })
nvim.nvim_set_keymap('n', '<c-l>', '<c-w>l', { noremap = true })

nvim.nvim_set_keymap('n', '<leader><c-h>', '<c-w>H', { noremap = true })
nvim.nvim_set_keymap('n', '<leader><c-j>', '<c-w>J', { noremap = true })
nvim.nvim_set_keymap('n', '<leader><c-k>', '<c-w>K', { noremap = true })
nvim.nvim_set_keymap('n', '<leader><c-l>', '<c-w>L', { noremap = true })

nvim.nvim_set_keymap('n', '<leader>term', ':sp|:term<cr>', { noremap = true })
nvim.nvim_set_keymap('n', '<leader>vterm', ':vsp|:term<cr>', { noremap = true })
nvim.nvim_set_keymap('n', '<leader>sp', ':sp|:Vifm<cr>', { noremap = true })
nvim.nvim_set_keymap('n', '<leader>vsp', ':vsp|:Vifm<cr>', { noremap = true })

-- -----------------------------------------------------------------------------
-- BUFFERS
-- -----------------------------------------------------------------------------

nvim.nvim_set_keymap('n', '<c-w>', ':bd<cr>', { noremap = true })
nvim.nvim_set_keymap('n', '<c-t>', ':Vifm<cr>', { noremap = true })
nvim.nvim_set_keymap('n', '<Tab>', ':bn<cr>', { noremap = true })
nvim.nvim_set_keymap('n', '<s-Tab>', ':bp<cr>', { noremap = true })

-- -----------------------------------------------------------------------------
-- FZF
-- -----------------------------------------------------------------------------

-- TODO: Auto adjust fzf layout depending on vim dimensions
-- TODO: CD command
function FzfLayout(query, fullscreen)
end

nvim.nvim_set_var('fzf_layout', {up = '100%'})
nvim.nvim_set_var('fzf_preview_window', 'right:60%')
nvim.nvim_set_keymap('n', '<leader>o', ':Files<cr>', { noremap = true })
nvim.nvim_set_keymap('n', '<leader>cd', ':Files<cr>', { noremap = true })
nvim.nvim_set_keymap('n', '<leader>rg', ':Rg<cr>', { noremap = true })
