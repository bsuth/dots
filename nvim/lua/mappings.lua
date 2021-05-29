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
    ['<leader><c-l>'] = ':rightbelow :vsp | :Dirvish<cr>',
    ['<leader><c-k>'] = ':aboveleft :sp | :Dirvish<cr>',
    ['<leader><c-j>'] = ':rightbelow :sp | :Dirvish<cr>',
    ['<leader><c-h>'] = ':aboveleft :vsp | :Dirvish<cr>',

    -- fzf
    ['<leader><leader>'] = ':lua fzf_favorites_cd()<cr>',
    ['<leader>fd'] = ':Files<cr>',
    ['<leader>cd'] = ':lua fzf_cd()<cr>',
    ['<leader>rg'] = ':lua fzf_rg()<cr>',
    ['<leader>ls'] = ':Buffers<cr>',

    -- coc
    ['<leader>coc'] = ':silent CocRestart<cr>',

    -- tabby
    ['<c-t>'] = ':TabbyOpen|:Dirvish ~<cr>',
    ['<c-w>'] = ':TabbyClose<cr>',
    ['<tab>'] = ':tabnext<cr>',
    ['<s-tab>'] = ':tabprev<cr>',
    ['<lt>'] = ':TabbyMove -1<cr>',
    ['>'] = ':TabbyMove +1<cr>',
    ['<leader><tab>'] = ':TabbyRename ',
  },

  i = { -- insert mode
    -- emacs bindings
    ['<m-b>'] = '<c-o>b',
    ['<m-f>'] = '<c-o>w',
    ['<c-b>'] = '<c-o>h',
    ['<c-f>'] = '<c-o>l',
    ['<c-a>'] = '<c-o>^',
    ['<c-e>'] = '<c-o>$',
    ['<c-u>'] = '<c-o>d^',
    ['<c-k>'] = '<c-o>d$',
    ['<m-backspace>'] = '<c-o>db',
    ['<m-d>'] = '<c-o>dw',
  },

  v = { -- visual mode
    ['<c-_>'] = ':Commentary<cr>',
    ['<c-n>'] = ':lua search_visual_selection()<cr>',
    -- TODO: visual selection docs
    -- ['K'] = ':lua docs()<cr>',
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
