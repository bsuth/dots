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

-- casing
opt.ignorecase = true
opt.smartcase = true

-- splitting
opt.splitright = true
opt.splitbelow = true

-- tabs
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- interface
opt.termguicolors = true
opt.number = true
opt.signcolumn = 'yes'
opt.showmode = false
opt.colorcolumn = '80'
cmd('highlight ColorColumn guibg=#585858')

-- misc
opt.wrap = false
opt.clipboard = 'unnamedplus'
opt.updatetime = 300
opt.scrollback = 100000
opt.commentstring = '//%s'

-- -----------------------------------------------------------------------------
-- Autocommands
-- -----------------------------------------------------------------------------

cmd('augroup bsuth')

-- CWD Tracking
cmd('au TermOpen term://*zsh* lua save_cwd()')
cmd('au TermClose term://*zsh* lua restore_cwd()')
cmd('au BufEnter * lua track_cwd()')

-- Dirvish
cmd('au TermClose term://*zsh* Dirvish')
cmd('au FileType dirvish nnoremap <buffer><silent> <cr> :lua dirvish_xdg_open()<cr>')

-- Term
cmd('au TermOpen term://*zsh* setlocal nonumber wrap')
cmd('au TermOpen term://*zsh* startinsert')

-- Headers
cmd('au FileType * lua setupheaders()')

-- Stylua 
cmd('au BufWritePost *.lua lua apply_stylua()')

cmd('augroup END')

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

--
-- Setup
--

g.mapleader = ' '

local function map(mode, lhs, rhs, opts)
  opts = tbl_extend('force', { noremap = true }, opts or {})
  nvim_set_keymap(mode, lhs, rhs, opts)
end

--
-- Core
--

map('n', '<leader>ev', ':Dirvish ~/dots/nvim/lua<cr>')
map('n', '<leader>sv', ':source $MYVIMRC<cr>')

map('n', '<c-space>', ':term<cr>')
map('n', '<leader>/', ':nohlsearch<cr><c-l>')
map('t', '<c-[>', '<c-\\><c-n>')

map('n', '<leader>?', ':help ')
map('n', '<leader>v?', ':vert :help ')

map('c', '<c-space>', '<c-f>')
map('n', ':', ':<c-f><c-c>')

map('n', '<c-_>', ':Commentary<cr>') -- secretly <c-/>
map('v', '<c-_>', ':Commentary<cr>')

--
-- Splits
--

map('n', '<leader>w', '<c-w>')

map('n', '<c-h>', '<c-w>h')
map('n', '<c-j>', '<c-w>j')
map('n', '<c-k>', '<c-w>k')
map('n', '<c-l>', '<c-w>l')

map('n', '<leader><c-l>', ':rightbelow :vsp | :Dirvish<cr>')
map('n', '<leader><c-k>', ':aboveleft :sp | :Dirvish<cr>')
map('n', '<leader><c-j>', ':rightbelow :sp | :Dirvish<cr>')
map('n', '<leader><c-h>', ':aboveleft :vsp | :Dirvish<cr>')

--
-- Movement
--

map('n', '<m-d>', '<c-d>')
map('n', '<m-u>', '<c-u>')
map('n', '<c-f>', 'l%')
map('v', '<c-f>', 'l%')
map('v', '<c-n>', ':lua search_visual_selection()<cr>')

--
-- Quickmarks
--

map('n', "'r", ':cd / | :Dirvish<cr>')
map('n', "'h", ':cd ~ | :Dirvish<cr>')

--
-- Emacs Bindings
--

map('i', '<c-b>', '<Left>')
map('i', '<c-f>', '<Right>')
map('i', '<m-b>', '<c-o>b')
map('i', '<m-f>', '<c-o>w')
map('i', '<c-a>', '<Home>')
map('i', '<c-e>', '<End>')

map('i', '<c-d>', '<Delete>')
map('i', '<c-h>', '<BS>')
map('i', '<m-d>', '<c-o>dw')
map('i', '<m-backspace>', '<c-o>db')
map('i', '<c-u>', '<c-o>d^')
map('i', '<c-k>', '<c-o>d$')

map('c', '<c-b>', '<Left>')
map('c', '<c-f>', '<Right>')
map('c', '<m-b>', '<c-f>bi<c-c>')
map('c', '<m-f>', '<c-f>wi<c-c>')
map('c', '<c-a>', '<Home>')
map('c', '<c-e>', '<End>')

map('c', '<c-d>', '<Delete>')
map('c', '<c-h>', '<BS>')
map('c', '<m-d>', '<C-f>dw<C-c>')
map('c', '<m-backspace>', '<C-f>db<C-c>')
map('c', '<c-u>', '<C-f>d^<C-c>')
map('c', '<c-k>', '<C-f>d$A<C-c>')

--
-- LSP Config
--

map('n', '<leader>lsp', ':silent :LspRestart<cr>')
map('i', '<c-space>', 'coc#refresh()', { expr = true, silent = true })

--
-- Telescope
--

map('n', '<leader><leader>', ':lua telescope_favorites()<cr>')
map('n', '<leader>cd', ':lua telescope_change_dir()<cr>')
map('n', '<leader>fd', ':Telescope find_files<cr>')
map('n', '<leader>rg', ':Telescope live_grep<cr>')
map('n', '<leader>ls', ':Telescope buffers<cr>')
