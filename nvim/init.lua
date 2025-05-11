-- -----------------------------------------------------------------------------
-- Settings
-- -----------------------------------------------------------------------------

-- core
vim.g.mapleader = ' '
vim.opt.clipboard = 'unnamedplus'
vim.api.nvim_create_augroup('bsuth', {})

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
vim.opt.number = false
vim.opt.wrap = false
vim.opt.signcolumn = 'no'
vim.opt.showmode = false
vim.opt.laststatus = 3
vim.opt.colorcolumn = '80'
vim.cmd('highlight ColorColumn guibg=#585858')

-- performance
vim.g.matchparen_timeout = 10
vim.opt.synmaxcol = 300
vim.opt.updatetime = 300
vim.opt.scrollback = 100000

-- formating
vim.opt.commentstring = '// %s'
vim.opt.formatoptions = 'jcroql'
vim.api.nvim_create_autocmd('FileType', {
  group = 'bsuth',
  pattern = { 'c', 'cpp' },
  -- override comment string for c / cpp (uses `/* ... */` by default)
  command = 'setlocal commentstring=//\\ %s',
})

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<c-s>', function()
  vim.cmd('update')
end)

vim.keymap.set('n', '<c-q>', function()
  if vim.fn.tabpagenr('$') + vim.fn.winnr('$') > 2 then
    vim.cmd('quit')
  end
end)

vim.keymap.set('n', '_', function()
  vim.cmd('nohlsearch')
end)

-- -----------------------------------------------------------------------------
-- Plugins / Modules
-- -----------------------------------------------------------------------------

local function load(name)
  package.loaded[name] = nil -- unset to force reloading
  require(name)
end

load('commander')

load('modules.cwd')
load('modules.emacs')
load('modules.format')
load('modules.statusline')
load('modules.surroundjump')
load('modules.tabline')
load('modules.tabs')
load('modules.terminal')
load('modules.tidy')
load('modules.windows')

load('plugins.commentary')
load('plugins.dirvish')
load('plugins.fugitive')
load('plugins.lsp')
load('plugins.move')
load('plugins.onedark')
load('plugins.surround')
load('plugins.treesitter')
