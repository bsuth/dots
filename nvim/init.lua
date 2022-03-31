-- -----------------------------------------------------------------------------
-- Constants
-- -----------------------------------------------------------------------------

BUFFER_PATTERNS = {
  term = { 'term://*zsh*', 'term://*bash*' },
  json = { '*.json', '*.cjson' },
  js = { '*.js', '*.jsx', '*.ts', '*.tsx' },
  css = { '*.css', '*.scss', '*.less' },
}

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

-- Inject all vim.api.nvim_* functions into global space
for key, value in pairs(vim.api) do
  if type(value) == 'function' and key:match('^nvim_') then
    _G[key] = value
  end
end

function fileExists(filename)
  local f = io.open(filename, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', { noremap = true }, opts or {})
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
  vim.cmd('augroup ' .. name)
  vim.cmd('au!')

  for i, autocommand in pairs(autocommands) do
    vim.cmd(autocommand)
  end

  vim.cmd('augroup END')
end

function rerequire(moduleName)
  package.loaded[moduleName] = nil -- Unload to allow re-sourcing
  require(moduleName)
end

-- -----------------------------------------------------------------------------
-- Options
-- -----------------------------------------------------------------------------

-- casing
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- splitting
vim.opt.splitright = true
vim.opt.splitbelow = true

-- tabs
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- interface
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.signcolumn = 'yes'
vim.opt.showmode = false
vim.opt.colorcolumn = '80'
vim.cmd('highlight ColorColumn guibg=#585858')

-- misc
vim.opt.wrap = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.updatetime = 300
vim.opt.scrollback = 100000
vim.opt.commentstring = '//%s'

-- -----------------------------------------------------------------------------
-- Packer
-- https://github.com/wbthomason/packer.nvim
-- -----------------------------------------------------------------------------

local packerBootstrap
local packerPath = vim.fn.stdpath('data')
  .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(packerPath)) > 0 then
  packerBootstrap = vim.fn.system({
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    packerPath,
  })
end

vim.cmd('packadd packer.nvim')
require('packer').startup(function()
  -- core
  use('wbthomason/packer.nvim')
  use('nvim-lua/plenary.nvim')

  -- lsp, completion, formatter
  use('neovim/nvim-lspconfig')
  use('hrsh7th/nvim-cmp')
  use('hrsh7th/vim-vsnip')
  use('hrsh7th/vim-vsnip-integ')
  use('rafamadriz/friendly-snippets')
  use('mhartington/formatter.nvim')
  use('fatih/vim-go')

  -- completion sources
  use('hrsh7th/cmp-buffer')
  use('hrsh7th/cmp-path')
  use('hrsh7th/cmp-nvim-lsp')
  use('hrsh7th/cmp-vsnip')

  -- syntax
  use('nvim-treesitter/nvim-treesitter')
  use('savq/melange')

  -- apps
  use('justinmk/vim-dirvish')
  use('hoob3rt/lualine.nvim')
  use('nvim-telescope/telescope.nvim')
  use({ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' })

  -- util
  use('tpope/vim-surround')
  use('tpope/vim-commentary')
  use('tpope/vim-fugitive')
  use('matze/vim-move')
  use('lambdalisue/suda.vim')
  use('tpope/vim-dadbod')

  -- Local plugins can be included
  use('~/repos/vim-erde')

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packerBootstrap then
    require('packer').sync()
  end
end)

-- -----------------------------------------------------------------------------
-- General
-- -----------------------------------------------------------------------------

-- prevent netrw from taking over:
-- https://github.com/justinmk/vim-dirvish/issues/137
vim.g.loaded_netrwPlugin = true

vim.g.mapleader = ' '
vim.g.suda_smart_edit = true
vim.g.go_fmt_autosave = true

vim.cmd('colorscheme melange')

map('n', '<leader>ev', ':Dirvish ~/dots/nvim/lua<cr>')
map('n', '<leader>sv', ':source $MYVIMRC<cr>')

map('n', '<leader>/', ':nohlsearch<cr><c-l>')

map('n', '<leader>?', ':help ')
map('n', '<leader>v?', ':vert :help ')

map('c', '<c-space>', '<c-f>')
map('n', ':', ':<c-f><c-c>')

map('n', '<c-_>', ':Commentary<cr>') -- <c-_> is secretly <c-/>
map('v', '<c-_>', ':Commentary<cr>') -- <c-_> is secretly <c-/>

map('n', '<c-f>', 'l%')
map('v', '<c-f>', 'l%')

map('n', '<leader>swp', ':Dirvish ~/.local/share/nvim/swap<cr>')

--
-- Windows
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
-- Git
--

map('n', '<leader>gg', ':Git ')
map('n', '<leader>git', ':Git<cr>')
map('n', '<leader>ga', ':Git add .<cr>')
map('n', '<leader>gc', ':Git commit<cr>')
map('n', '<leader>gd', ':Git diff<cr>')
map('n', '<leader>gl', ':Git log<cr>')
map('n', '<leader>gb', ':Git blame<cr>')

--
-- Abbreviations
--

vim.cmd('iabbrev _rhed // eslint-disable-line react-hooks/exhaustive-deps')
vim.cmd('iabbrev _tsi // eslint-disable-next-line<cr>@ts-ignore')

-- -----------------------------------------------------------------------------
-- Terminal
-- -----------------------------------------------------------------------------

map('n', '<c-space>', ':term<cr>')
map('t', '<c-[>', '<c-\\><c-n>')

function onTermClose()
  local termBuffer = nvim_win_get_buf(0)
  -- Dirvish throws an error when using :Dirvish from a term buffer, but it
  -- still works so just silence it.
  vim.cmd('silent Dirvish ' .. vim.fn.getcwd())
  nvim_buf_delete(termBuffer, {})
end

augroup('bsuth-terminal', {
  autocmd('TermOpen', 'setlocal nonumber wrap', BUFFER_PATTERNS.term),
  autocmd('TermOpen', 'startinsert', BUFFER_PATTERNS.term),
  autocmd('TermClose', 'lua onTermClose()', BUFFER_PATTERNS.term),
})

-- -----------------------------------------------------------------------------
-- Dirvish
-- -----------------------------------------------------------------------------

function dirvishXdgOpen()
  local file = vim.fn.expand('<cWORD>')
  local dir = vim.fn.fnamemodify(file, ':p:h')
  local ext = vim.fn.fnamemodify(file, ':e')

  if ext == 'png' then
    os.execute('xdg-open ' .. file .. ' &>/dev/null')
  else
    vim.fn['dirvish#open']('edit', 0)
    vim.cmd('cd ' .. dir)
  end
end

augroup('bsuth-dirvish', {
  autocmd(
    'FileType',
    'nnoremap <buffer><silent> <cr> :lua dirvishXdgOpen()<cr>',
    'dirvish'
  ),
})

-- -----------------------------------------------------------------------------
-- Visual Selection
-- -----------------------------------------------------------------------------

local function getVisualSelection()
  local buffer, line_start, column_start = unpack(vim.fn.getpos("'<"))
  local buffer, line_end, column_end = unpack(vim.fn.getpos("'>"))

  local lines = vim.fn.getline(line_start, line_end)
  vim.fn.setpos('.', { { 0, line_start, column_start, 0 } })

  if #lines == 1 then
    lines[1] = lines[1]:sub(column_start, column_end)
  elseif #lines > 1 then
    lines[1] = lines[1]:sub(column_start)
    lines[#lines] = lines[#lines]:sub(1, column_end)
  end

  return table.concat(lines, '\n')
end

function searchVisualSelection()
  vim.fn.setreg('/', getVisualSelection())
  vim.cmd('normal n')
end

function replaceVisualSelection()
  nvim_input(':s/' .. getVisualSelection() .. '//g<Left><Left>')
end

map('v', '<c-n>', ':lua searchVisualSelection()<cr>')
map('v', '<c-s>', ':lua replaceVisualSelection()<cr>')

-- -----------------------------------------------------------------------------
-- CWD Tracking
-- -----------------------------------------------------------------------------

local cwdCache = {}

function saveTermCwd()
  local bufname = nvim_buf_get_name(0)
  cwdCache[bufname] = vim.fn.getcwd()
end

function clearTermCwd()
  local bufname = nvim_buf_get_name(0)
  if cwdCache[bufname] ~= nil then
    cwdCache[bufname] = nil
  end
end

function trackCwd()
  local bufname = nvim_buf_get_name(0)

  if bufname:match('^term://') then
    if cwdCache[bufname] ~= nil then
      vim.cmd('cd ' .. cwdCache[bufname])
    end
  else
    -- Change to current buffer's parent directory
    local parentDir = vim.fn.fnamemodify(bufname, ':p:h'):gsub('^suda://', '')
    vim.cmd('cd ' .. parentDir)

    -- refresh dirvish after cd
    if nvim_buf_get_option(0, 'filetype') == 'dirvish' then
      vim.cmd('Dirvish')
    end
  end
end

augroup('bsuth-cwd-track', {
  autocmd('BufEnter', 'lua trackCwd()', '*'),
  autocmd('TermOpen', 'lua saveTermCwd()', BUFFER_PATTERNS.term),
  autocmd('TermClose', 'lua clearTermCwd()', BUFFER_PATTERNS.term),
})

-- -----------------------------------------------------------------------------
-- Marks
-- -----------------------------------------------------------------------------

-- Clear all marks on startup
vim.cmd('delm!')
vim.cmd('delm A-Z0-9')
local markCounter = 0

function pushMark()
  vim.cmd('normal m' .. tostring(markCounter))
  markCounter = (markCounter + 1) % 10
end

map('n', '<leader>mm', ':lua pushMark()<cr>')

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
    theme = 'gruvbox_dark',
  },

  sections = {
    lualine_x = {},
  },
})

-- -----------------------------------------------------------------------------
-- Modules
-- -----------------------------------------------------------------------------

rerequire('language-support')
rerequire('telescope-config')
