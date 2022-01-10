-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

local terminalBufferPatterns = { 'term://*zsh*', 'term://*bash*' }

-- Inject all vim.* properties into global space
for k, v in pairs(vim) do
  if _G[k] == nil then
    _G[k] = v
  end
end

-- Inject all vim.api.nvim_* functions into global space
for k, v in pairs(vim.api) do
  if type(v) == 'function' and k:match('^nvim_') then
    _G[k] = v
  end
end

function file_exists(filename)
  local f = io.open(filename, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function map(mode, lhs, rhs, opts)
  opts = tbl_extend('force', { noremap = true }, opts or {})
  nvim_set_keymap(mode, lhs, rhs, opts)
end

function autocmd(event, command, patterns)
  return table.concat({
    'au',
    event,
    type(patterns) == 'table' and table.concat(patterns, ',') or patterns,
    command,
  }, ' ')
end

function augroup(name, autocommands)
  cmd('augroup ' .. name)
  cmd('au!')

  for i, autocommand in pairs(autocommands) do
    cmd(autocommand)
  end

  cmd('augroup END')
end

function rerequire(moduleName)
  package.loaded[moduleName] = nil -- Unload to allow re-sourcing
  require(moduleName)
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
-- Packer
-- https://github.com/wbthomason/packer.nvim
-- -----------------------------------------------------------------------------

local packer_bootstrap
local packer_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(packer_path)) > 0 then
  packer_bootstrap = fn.system({
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    packer_path,
  })
end

cmd('packadd packer.nvim')
require('packer').startup(function()
  -- core
  use('wbthomason/packer.nvim')
  use('nvim-lua/plenary.nvim')

  -- lsp, completion, formatter
  use('neovim/nvim-lspconfig')
  use('hrsh7th/nvim-cmp')
  use('hrsh7th/vim-vsnip')
  use('hrsh7th/vim-vsnip-integ')
  use('mhartington/formatter.nvim')
  use('fatih/vim-go')

  -- completion sources
  use('hrsh7th/cmp-buffer')
  use('hrsh7th/cmp-path')
  use('hrsh7th/cmp-nvim-lsp')
  use('hrsh7th/cmp-vsnip')

  -- syntax
  use('nvim-treesitter/nvim-treesitter')
  use('navarasu/onedark.nvim')

  -- apps
  use('justinmk/vim-dirvish')
  use('hoob3rt/lualine.nvim')
  use('nvim-telescope/telescope.nvim')
  use({ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' })

  -- util
  use('tpope/vim-surround')
  use('tpope/vim-commentary')
  use('matze/vim-move')
  use('lambdalisue/suda.vim')

  -- Local plugins can be included
  use('~/repos/vim-erde')

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- -----------------------------------------------------------------------------
-- General
-- -----------------------------------------------------------------------------

rerequire('language-support')
rerequire('telescope-config')

-- prevent netrw from taking over:
-- https://github.com/justinmk/vim-dirvish/issues/137
g.loaded_netrwPlugin = true

g.mapleader = ' '
g.suda_smart_edit = true
g.go_fmt_autosave = true

cmd('colorscheme onedark')

augroup('bsuth-general', {
  autocmd('TermOpen', 'setlocal nonumber wrap', terminalBufferPatterns),
  autocmd('TermOpen', 'startinsert', terminalBufferPatterns),
})

map('n', '<leader>ev', ':Dirvish ~/dots/nvim/lua<cr>')
map('n', '<leader>sv', ':source $MYVIMRC<cr>')

map('n', '<c-space>', ':term<cr>')
map('t', '<c-[>', '<c-\\><c-n>')

map('n', '<leader>/', ':nohlsearch<cr><c-l>')

map('n', '<leader>?', ':help ')
map('n', '<leader>v?', ':vert :help ')

map('c', '<c-space>', '<c-f>')
map('n', ':', ':<c-f><c-c>')

map('n', '<c-_>', ':Commentary<cr>') -- <c-_> is secretly <c-/>
map('v', '<c-_>', ':Commentary<cr>') -- <c-_> is secretly <c-/>

map('n', '<c-f>', 'l%')
map('v', '<c-f>', 'l%')

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
-- Telescope
--

map('n', '<leader><leader>', ':lua telescope_favorites()<cr>')
map('n', '<leader>cd', ':lua telescope_change_dir()<cr>')
map('n', '<leader>fd', ':Telescope find_files<cr>')
map('n', '<leader>rg', ':Telescope live_grep<cr>')
map('n', '<leader>buf', ':Telescope buffers<cr>')

-- -----------------------------------------------------------------------------
-- Dirvish
-- -----------------------------------------------------------------------------

function dirvish_xdg_open()
  local file = fn.expand('<cWORD>')
  local dir = fn.fnamemodify(file, ':p:h')
  local ext = fn.fnamemodify(file, ':e')

  if ext == 'png' then
    os.execute('xdg-open ' .. file .. ' &>/dev/null')
  else
    fn['dirvish#open']('edit', 0)
    cmd('cd ' .. dir)
  end
end

augroup('bsuth-dirvish', {
  autocmd('TermClose', 'Dirvish', terminalBufferPatterns),
  autocmd(
    'FileType',
    'nnoremap <buffer><silent> <cr> :lua dirvish_xdg_open()<cr>',
    'dirvish'
  ),
})

-- -----------------------------------------------------------------------------
-- Visual Selection
-- -----------------------------------------------------------------------------

local function get_visual_selection()
  local buffer, line_start, column_start = unpack(fn.getpos("'<"))
  local buffer, line_end, column_end = unpack(fn.getpos("'>"))

  local lines = fn.getline(line_start, line_end)
  fn.setpos('.', { { 0, line_start, column_start, 0 } })

  if #lines == 1 then
    lines[1] = lines[1]:sub(column_start, column_end)
  elseif #lines > 1 then
    lines[1] = lines[1]:sub(column_start)
    lines[#lines] = lines[#lines]:sub(1, column_end)
  end

  return table.concat(lines, '\n')
end

function search_visual_selection()
  fn.setreg('/', get_visual_selection())
  cmd('normal n')
end

function replace_visual_selection()
  nvim_input(':s/' .. get_visual_selection() .. '//g<Left><Left>')
end

map('v', '<c-n>', ':lua search_visual_selection()<cr>')
map('v', '<c-s>', ':lua replace_visual_selection()<cr>')

-- -----------------------------------------------------------------------------
-- CWD Tracking
-- -----------------------------------------------------------------------------

local cwd_cache = {}

function save_cwd()
  local bufname = nvim_buf_get_name(0)
  cwd_cache[bufname] = fn.getcwd()
end

function restore_cwd()
  local bufname = nvim_buf_get_name(0)
  if cwd_cache[bufname] ~= nil then
    cmd(('cd %s'):format(cwd_cache[bufname]))
    cwd_cache[bufname] = nil
  end
end

function track_cwd()
  local bufname = nvim_buf_get_name(0)

  if bufname:match('^term://') then
    if cwd_cache[bufname] ~= nil then
      cmd(('cd %s'):format(cwd_cache[bufname]))
    end
  else
    -- Change to current buffer's parent directory
    cmd(('cd %s'):format(fn.fnamemodify(bufname, ':p:h'):gsub('^suda://', '')))

    -- refresh dirvish after cd
    if nvim_buf_get_option(0, 'filetype') == 'dirvish' then
      cmd('Dirvish')
    end
  end
end

augroup('bsuth-cwd-track', {
  autocmd('BufEnter', 'lua track_cwd()', '*'),
  autocmd('TermOpen', 'lua save_cwd()', terminalBufferPatterns),
  autocmd('TermClose', 'lua restore_cwd()', terminalBufferPatterns),
})

-- -----------------------------------------------------------------------------
-- Stylua
-- https://github.com/JohnnyMorganz/StyLua
-- -----------------------------------------------------------------------------

local function get_stylua_config(dir)
  repeat
    local config = dir .. '/' .. 'stylua.toml'
    if file_exists(config) then
      return config
    end
    dir = fn.fnamemodify(dir, ':h')
  until dir == '/'
end

function apply_stylua()
  local stylua_exec = os.getenv('HOME') .. '/.cargo/bin/stylua'
  if not file_exists(stylua_exec) then
    return
  end

  local filename = fn.expand('%:p')
  local stylua_config = get_stylua_config(fn.fnamemodify(filename, ':h'))
  if not stylua_config then
    return
  end

  cmd(
    ('silent exec "!%s --config-path %s %s" | e!'):format(
      stylua_exec,
      stylua_config,
      filename
    )
  )
end

augroup('bsuth-stylua', {
  autocmd('BufWritePost', 'lua apply_stylua()', '*.lua'),
})

-- -----------------------------------------------------------------------------
-- Lualine
-- https://github.com/hoob3rt/lualine.nvim
-- -----------------------------------------------------------------------------

-- Lualine dissapears on rc reload unless we unload it completely before
-- calling setup. Fixed but awaiting merge. Track here:
-- https://github.com/hoob3rt/lualine.nvim/issues/276
require('plenary.reload').reload_module('lualine', true)

require('lualine').setup({
  options = {
    icons_enabled = false,
    theme = 'onedark',
  },

  sections = {
    lualine_x = {},
  },
})
