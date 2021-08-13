-- -----------------------------------------------------------------------------
-- Environment
-- -----------------------------------------------------------------------------

for k, v in pairs(vim) do
  if _G[k] == nil then
    _G[k] = v
  end
end

for k, v in pairs(vim.api) do
  if type(v) == 'function' and k:match('^nvim_') then
    _G[k] = v
  end
end

for _, v in ipairs({ 'helpers', 'plugins' }) do
  package.loaded[v] = nil
  require(v)
end

-- -----------------------------------------------------------------------------
-- Options
-- -----------------------------------------------------------------------------

local global_options = {
  wrap = false,
  ignorecase = true,
  smartcase = true,
  splitright = true,
  splitbelow = true,
  termguicolors = true,
  tabstop = 2,
  softtabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  clipboard = 'unnamedplus',
  scrollback = 100000,
  updatetime = 300,
  suffixes = '.bak,~,.o,.info,.swp,.obj',
  showmode = false, -- replaced by lightline
}

local window_options = {
  number = true,
  colorcolumn = '80',
  signcolumn = 'yes',
}

local buffer_options = {}

for k, v in pairs(global_options) do
  nvim_set_option(k, v)
end

for k, v in pairs(window_options) do
  nvim_win_set_option(0, k, v)
end

for k, v in pairs(buffer_options) do
  nvim_buf_set_option(0, k, v)
end

nvim_command('highlight ColorColumn guibg=#585858')

-- -----------------------------------------------------------------------------
-- Autocommands
-- -----------------------------------------------------------------------------

nvim_command('augroup bsuth')

-- CWD Tracking
nvim_command('au TermOpen term://*zsh* lua save_cwd()')
nvim_command('au TermClose term://*zsh* lua restore_cwd()')
nvim_command('au BufEnter * lua track_cwd()')

-- Dirvish
nvim_command('au TermClose term://*zsh* Dirvish')
nvim_command('au FileType dirvish nnoremap <buffer><silent> <cr> :lua dirvish_xdg_open()<cr>')

-- Term
nvim_command('au TermOpen term://*zsh* setlocal nonumber wrap')
nvim_command('au TermOpen term://*zsh* startinsert')

-- Misc
nvim_command('au BufWritePost *.lua lua apply_stylua()')

nvim_command('augroup END')

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

nvim_set_var('mapleader', ' ')

local mappings = {
  n = { -- normal mode
    -- common use
    ['<leader>ev'] = ':Dirvish ~/dots/nvim/lua<cr>',
    ['<leader>sv'] = ':source $MYVIMRC<cr>',
    ['<c-space>'] = ':term<cr>',
    ['<leader>/'] = ':nohlsearch<cr><c-l>',
    ['<leader>?'] = ':help ',
    ['<leader>v?'] = ':vert :help ',
    ['<c-_>'] = ':Commentary<cr>', -- secretly <c-/>
    ['<c-f>'] = 'l%',

    -- windows
    ['<leader>w'] = '<c-w>',
    ['<c-h>'] = '<c-w>h',
    ['<c-j>'] = '<c-w>j',
    ['<c-k>'] = '<c-w>k',
    ['<c-l>'] = '<c-w>l',
    ['<leader><c-l>'] = ':rightbelow :vsp | :Dirvish<cr>',
    ['<leader><c-k>'] = ':aboveleft :sp | :Dirvish<cr>',
    ['<leader><c-j>'] = ':rightbelow :sp | :Dirvish<cr>',
    ['<leader><c-h>'] = ':aboveleft :vsp | :Dirvish<cr>',

    -- tabs
    ['<c-t>'] = ':tabnew | :Dirvish<cr>',
    ['<c-w>'] = ':tabclose<cr>',
    ['<tab>'] = ':tabnext<cr>',
    ['<s-tab>'] = ':tabprev<cr>',
    ['<lt>'] = ':tabmove -1<cr>',
    ['>'] = ':tabmove +1<cr>',

    -- fake marks
    ["'r"] = ':cd / | :Dirvish<cr>',
    ["'h"] = ':cd ~ | :Dirvish<cr>',

    -- telescope
    ['<leader><leader>'] = ':lua telescope_favorites()<cr>',
    ['<leader>cd'] = ':lua telescope_change_dir()<cr>',
    ['<leader>fd'] = ':Telescope find_files<cr>',
    ['<leader>rg'] = ':Telescope live_grep<cr>',
    ['<leader>ls'] = ':Telescope buffers<cr>',

    -- coc
    ['<leader>coc'] = ':silent CocRestart<cr>',
  },

  i = { -- insert mode
    -- coc
    ['<c-space>'] = {
      rhs = 'coc#refresh()',
      opts = { expr = true, silent = true },
    },

    -- emacs mappings
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
    ['<c-f>'] = 'l%',
  },

  t = { -- terminal mode
    ['<c-[>'] = '<c-\\><c-n>',
  },
}

for mode, modemappings in pairs(mappings) do
  for k, v in pairs(modemappings) do
    if type(v) == 'string' then
      nvim_set_keymap(mode, k, v, { noremap = true })
    elseif type(v) == 'table' then
      v.opts.noremap = true
      nvim_set_keymap(mode, k, v.rhs, v.opts)
    end
  end
end
