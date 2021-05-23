nvim_set_var('mapleader', ' ')

local bindings = {
  n = { -- normal mode
    -- common use
    ['<leader>ev'] = ':e $MYVIMRC<cr>',
    ['<leader>sv'] = ':source $MYVIMRC<cr>',
    ['<c-space>'] = ':term<cr>',
    ['<leader>/'] = ':nohlsearch<cr><c-l>',
    ['<leader>?'] = ':help ',
    ['<leader>v?'] = ':vert :help ',
    ['<c-_>'] = ':Commentary<cr>', -- secretly <c-/>

    -- window management
    ['<leader>w'] = '<c-w>',
    ['<c-h>'] = '<c-w>h',
    ['<c-j>'] = '<c-w>j',
    ['<c-k>'] = '<c-w>k',
    ['<c-l>'] = '<c-w>l',
    ['<leader><c-l>'] = ':rightbelow :vsp|:Dirvish<cr>',
    ['<leader><c-k>'] = ':aboveleft :sp|:Dirvish<cr>',
    ['<leader><c-j>'] = ':rightbelow :sp|:Dirvish<cr>',
    ['<leader><c-h>'] = ':aboveleft :vsp|:Dirvish<cr>',

    -- fzf
    ['<leader><leader>'] = ':FavoriteCDSelect<cr>',
    ['<leader>fd'] = ':Files<cr>',
    ['<leader>cd'] = ':FzfCDSelect<cr>',
    ['<leader>rg'] = ':Rg<cr>',
    ['<leader>ls'] = ':Buffers<cr>',

    -- coc
    ['<silent>'] = 'K :lua docs()<cr>',
    ['<leader>coc'] = ':silent CocRestart<cr>',

    -- tabby
    ['<leader>t'] = ':unlet g:loaded_tabby|:source $MYVIMRC<cr>',
    ['<c-t>'] = ':tabnew|:Dirvish ~<cr>',
    ['<c-w>'] = ':tabclose<cr>',
    ['<Tab>'] = ':tabnext<cr>',
    ['<s-Tab>'] = ':tabprev<cr>',
  },

  i = { -- insert mode
    -- emacs bindings
    ['<M-b>'] = '<C-o>b',
    ['<M-f>'] = '<C-o>w',
    ['<c-b>'] = '<C-o>h',
    ['<c-f>'] = '<C-o>l',
    ['<c-a>'] = '<C-o>^',
    ['<c-e>'] = '<C-o>$',
    ['<c-u>'] = '<C-o>d^',
    ['<c-k>'] = '<C-o>d$',
    ['<M-backspace>'] = '<C-o>db',
    ['<M-d>'] = '<C-o>dw',
  },

  v = { -- visual mode
    ['<c-_>'] = ':Commentary<cr>',
    ['<c-n>'] = ':lua search_visual_selection()<cr>',
  },

  t = { -- terminal mode
    ['<c-[>'] = '<c-\\><c-n>',
  },
}

for mode, modebindings in pairs(bindings) do
  for k, v in pairs(modebindings) do
    nvim_set_keymap(mode, k, v, { noremap = true })
  end
end
