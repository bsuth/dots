-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

-- Inject all vim.api.nvim_* functions into global space
for key, value in pairs(vim.api) do
  if type(value) == 'function' and key:match('^nvim_') then
    _G[key] = value
  end
end

-- Unload to allow re-sourcing
package.loaded['constants'] = nil
package.loaded['language-support'] = nil
package.loaded['telescope-config'] = nil
package.loaded['work'] = nil

local C = require('constants')

-- When resolving modules, neovim looks for 'lua/?.lua;lua/?/init.lua' for all
-- paths in `runtimepath`. However, since package managers often manipulate this
-- value at runtime, neovim opts to provide a custom package loader instead of
-- manipulating package.path in order to always get the correct `runtimepath`
-- value _at require time_.
--
-- This causes some problems (such as erde not being able to find our neovim
-- modules), so we adjust package.path for our neovim modules manually.
--
-- @see https://github.com/neovim/neovim/blob/master/runtime/lua/vim/_init_packages.lua
package.path = ('%s/nvim/lua/?.lua;%s/lua/?/init.lua;%s'):format(C.DOTS, C.DOTS, package.path)

require('erde').load('jit')

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
  use('mhartington/formatter.nvim')
  use('hrsh7th/nvim-cmp')
  use('hrsh7th/cmp-nvim-lsp') -- lsp
  use('hrsh7th/vim-vsnip') -- lsp snippets
  use('hrsh7th/cmp-vsnip') -- lsp snippets
  use('hrsh7th/cmp-buffer') -- words in current buffer
  use('hrsh7th/cmp-path') -- file paths
  use('hrsh7th/cmp-nvim-lua') -- neovim lua api
  use('hrsh7th/cmp-nvim-lsp-signature-help') -- fancy function signature highlighting

  -- syntax
  use('nvim-treesitter/nvim-treesitter')
  use('navarasu/onedark.nvim')
 
  -- languages
  use('peterhoeg/vim-qml')
  use('fatih/vim-go')
  use('tridactyl/vim-tridactyl')

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
  use({ 'phaazon/hop.nvim', branch = 'v2' })

  -- Local plugins can be included
  use('~/repos/vim-erde')
  use('~/repos/emacs-bindings.nvim')

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packerBootstrap then
    require('packer').sync()
  end
end)

-- -----------------------------------------------------------------------------
-- Settings
-- -----------------------------------------------------------------------------

vim.g.mapleader = ' '

-- Create general augroup
nvim_create_augroup('bsuth', {})

-- prevent netrw from taking over:
-- https://github.com/justinmk/vim-dirvish/issues/137
vim.g.loaded_netrwPlugin = true

-- dark, darker, cool, deep, warm, warmer
require('onedark').setup({ style = 'warmer' })
require('onedark').load()

vim.g.suda_smart_edit = true
vim.g.go_fmt_autosave = true

--
-- Options
--

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
-- Mappings
-- -----------------------------------------------------------------------------

--
-- General
--

vim.keymap.set('n', '<leader>ev', ':Dirvish ~/dots/nvim<cr>')
vim.keymap.set('n', '<leader>sv', ':source $MYVIMRC<cr>')

vim.keymap.set('n', '<c-w>', ':write<cr>')
vim.keymap.set('n', '<c-q>', ':quit<cr>')

vim.keymap.set('c', '<c-space>', '<c-f>')
vim.keymap.set('n', ':', ':<c-f><c-c>')

vim.keymap.set('n', '<c-_>', ':Commentary<cr>') -- <c-_> is secretly <c-/>
vim.keymap.set('v', '<c-_>', ':Commentary<cr>') -- <c-_> is secretly <c-/>

-- TODO: improve these
vim.keymap.set('n', '<char-62>', 'l%')
vim.keymap.set('v', '<char-62>', 'l%')
vim.keymap.set('n', '<char-60>', 'h%')
vim.keymap.set('v', '<char-60>', 'h%')

vim.keymap.set('n', '<leader>/', ':nohlsearch<cr><c-l>')

vim.keymap.set('n', '<leader>?', ':help ')
vim.keymap.set('n', '<leader>v?', ':vert :help ')

vim.keymap.set('n', '<leader>syn', ':syntax clear | syntax reset | syntax enable<cr>')

-- Remove annoying default map of K to manual
vim.keymap.set('n', 'K', function() end)

--
-- Quick Links
--

vim.keymap.set('n', '<leader>swp', ':Dirvish ~/.local/share/nvim/swap<cr>')
vim.keymap.set('n', '<leader>pack', ':Dirvish ~/.local/share/nvim/site/pack/packer/start<cr>')
vim.keymap.set(
  'n',
  '<leader>pack',
  ':Dirvish ~/.local/share/nvim/site/pack/packer/start<cr>'
)

--
-- Window Management
--

vim.keymap.set('n', '<leader>w', '<c-w>')
vim.keymap.set('n', '<c-h>', '<c-w>h')
vim.keymap.set('n', '<c-j>', '<c-w>j')
vim.keymap.set('n', '<c-k>', '<c-w>k')
vim.keymap.set('n', '<c-l>', '<c-w>l')
vim.keymap.set('n', '<leader><c-l>', ':rightbelow :vsp | :Dirvish<cr>')
vim.keymap.set('n', '<leader><c-k>', ':aboveleft :sp | :Dirvish<cr>')
vim.keymap.set('n', '<leader><c-j>', ':rightbelow :sp | :Dirvish<cr>')
vim.keymap.set('n', '<leader><c-h>', ':aboveleft :vsp | :Dirvish<cr>')

--
-- Git
--

vim.keymap.set('n', '<leader>gg', ':Git ')
vim.keymap.set('n', '<leader>git', ':Git<cr>')
vim.keymap.set('n', '<leader>ga', ':Git add .<cr>')
vim.keymap.set('n', '<leader>gc', ':Git commit<cr>')
vim.keymap.set('n', '<leader>gd', ':Git diff<cr>')
vim.keymap.set('n', '<leader>gl', ':Git log<cr>')
vim.keymap.set('n', '<leader>gb', ':Git blame<cr>')

--
-- Hop
--

require('hop').setup() -- init hop
vim.keymap.set('n', '<c-f>', ':HopWord<cr>')
-- use <cmd> to prevent "No range allowed" errors in visual mode.
-- see https://github.com/phaazon/hop.nvim/issues/126#issuecomment-910761167
vim.keymap.set('v', '<c-f>', '<cmd>HopWord<cr>')
vim.keymap.set('n', '<leader>hl', ':HopLine<cr>')
vim.keymap.set('n', '<leader>hp', ':HopPattern<cr>')

-- -----------------------------------------------------------------------------
-- Terminal
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<c-space>', ':term<cr>')
vim.keymap.set('t', '<c-[>', '<c-\\><c-n>')
vim.keymap.set('t', '<esc>', '<c-\\><c-n>')

local function onTermClose()
  local termBuffer = nvim_win_get_buf(0)
  -- Dirvish throws an error when using :Dirvish from a term buffer, but it
  -- still works so just silence it.
  vim.cmd('silent Dirvish ' .. vim.fn.getcwd())
  nvim_buf_delete(termBuffer, {})
end

nvim_create_autocmd('TermOpen', {
  group = 'bsuth',
  pattern = C.TERM_PATTERNS,
  command = 'setlocal nonumber wrap',
})

nvim_create_autocmd('TermOpen', {
  group = 'bsuth',
  pattern = C.TERM_PATTERNS,
  command = 'startinsert',
})

nvim_create_autocmd('TermClose', {
  group = 'bsuth',
  pattern = C.TERM_PATTERNS,
  callback = onTermClose,
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

nvim_create_autocmd('FileType', {
  group = 'bsuth',
  pattern = 'dirvish',
  callback = function()
    vim.keymap.set('n', '<cr>', dirvishXdgOpen, {
      buffer = true,
      silent = true,
    })
  end,
})

-- -----------------------------------------------------------------------------
-- Visual Selection
-- -----------------------------------------------------------------------------

local function getVisualSelection()
  -- Do not use '> and '< registers in getpos! These registers are only updated 
  -- _after_ leaving visual mode.
  -- @see https://github.com/neovim/neovim/pull/13896#issuecomment-774680224
  local _, line_start, column_start = unpack(vim.fn.getpos('v'))
  local _, line_end, column_end = unpack(vim.fn.getcurpos())

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

vim.keymap.set('v', '<c-n>', function()
  vim.fn.setreg('/', getVisualSelection())
  nvim_feedkeys(nvim_replace_termcodes('<esc>', true, false, true), 'n', false)
  vim.cmd('normal n')
end)

-- -----------------------------------------------------------------------------
-- CWD Tracking
-- -----------------------------------------------------------------------------

local cwdCache = {}

local CWD_TRACK_BLACKLIST = {
  '^term://',
  '^fugitive://',
}

function getTrackDir(bufName)
  return vim.fn.fnamemodify(bufName, ':p:h'):gsub('^sudo://', '')
end

function isTrackBlacklisted(bufName)
  for _, pattern in ipairs(CWD_TRACK_BLACKLIST) do
    if bufName:match(pattern) then
      return true
    end
  end
end

-- Do not make this local! zsh needs this for cd hook in nested terminal.
function saveTermCwd()
  local bufName = nvim_buf_get_name(0)
  if not isTrackBlacklisted(bufName) then
    cwdCache[bufName] = vim.fn.getcwd()
  end
end

local function clearTermCwd()
  local bufName = nvim_buf_get_name(0)
  if not isTrackBlacklisted(bufName) and cwdCache[bufName] ~= nil then
    cwdCache[bufName] = nil
  end
end

local function trackCwd()
  local bufName = nvim_buf_get_name(0)
  if bufName:match('^term://') then
    if cwdCache[bufName] ~= nil then
      vim.cmd('cd ' .. cwdCache[bufName])
    end
  elseif not isTrackBlacklisted(bufName) then
    vim.cmd('cd ' .. getTrackDir(bufName))
    if nvim_buf_get_option(0, 'filetype') == 'dirvish' then
      vim.cmd('Dirvish') -- refresh dirvish after cd
    end
  end
end

nvim_create_autocmd('BufEnter', {
  group = 'bsuth',
  pattern = '*',
  callback = trackCwd,
})

nvim_create_autocmd('TermOpen', {
  group = 'bsuth',
  pattern = C.TERM_PATTERNS,
  callback = saveTermCwd,
})

nvim_create_autocmd('TermClose', {
  group = 'bsuth',
  pattern = C.TERM_PATTERNS,
  callback = clearTermCwd,
})

-- -----------------------------------------------------------------------------
-- Marks
-- -----------------------------------------------------------------------------

-- Clear all marks on startup
vim.cmd('delm!')
vim.cmd('delm A-Z0-9')
local markCounter = 0

local function pushMark()
  vim.cmd('normal m' .. tostring(markCounter))
  markCounter = (markCounter + 1) % 10
end

vim.keymap.set('n', '<leader>mm', pushMark)

-- -----------------------------------------------------------------------------
-- Lualine
-- https://github.com/hoob3rt/lualine.nvim
-- -----------------------------------------------------------------------------

require('lualine').setup({
  options = {
    icons_enabled = false,
    theme = 'onedark',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_c = { { 'filename', path = 3 } },
    lualine_x = {},
  },
})

-- -----------------------------------------------------------------------------
-- Home vs Work
-- -----------------------------------------------------------------------------

pcall(function()
  require('work')
end)

-- -----------------------------------------------------------------------------
-- Modules
-- -----------------------------------------------------------------------------

require('language-support')
require('telescope-config')
