-- -----------------------------------------------------------------------------
-- Settings
-- -----------------------------------------------------------------------------

-- core
vim.g.mapleader = ' '
vim.opt.clipboard = 'unnamedplus'
vim.api.nvim_create_augroup('bsuth', {})

-- splitting
vim.opt.splitright = true
vim.opt.splitbelow = true

-- casing
vim.opt.ignorecase = true
vim.opt.smartcase = true

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
vim.opt.formatoptions = 'jcroql'

-- neovide
if vim.g.neovide then
  vim.o.guifont = "Roboto Mono:h12"

  vim.g.neovide_position_animation_length = 0
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0.2

  vim.g.neovide_padding_top = 8
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 8
  vim.g.neovide_padding_left = 8
end

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

-- Save
vim.keymap.set('n', '<c-s>', function()
  vim.cmd('update')
end)

-- Close
vim.keymap.set('n', '<c-q>', function()
  if vim.fn.tabpagenr('$') + vim.fn.winnr('$') > 2 then
    vim.cmd('quit')
  end
end)

-- Comments
vim.keymap.set('n', '<c-/>', 'gcc', { remap = true })
vim.keymap.set('v', '<c-/>', 'gc', { remap = true })

-- Search current view
vim.keymap.set('n', '\\', 'VHoL<esc>H/\\%V')

-- Insert-Mode Paste
vim.keymap.set('i', '<c-v>', '<c-r>+')
vim.keymap.set('c', '<c-v>', '<c-r>+')
vim.keymap.set('t', '<c-v>', '<c-\\><c-n>pi')

-- Highlighting
vim.keymap.set('n', '_', function()
  vim.cmd('nohlsearch')
end)

-- Tabs
vim.keymap.set('n', '<c-t>', function() vim.cmd('tabnew ' .. vim.fn.getcwd()) end)
vim.keymap.set('n', '<c-s-Tab>', function() vim.cmd('tabprevious') end)
vim.keymap.set('n', '<c-Tab>', function() vim.cmd('tabnext') end)
vim.keymap.set('n', '<', function() pcall(function() vim.cmd('-tabmove') end) end)
vim.keymap.set('n', '>', function() pcall(function() vim.cmd('+tabmove') end) end)

-- LSP
vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover)                                  -- h(over)
vim.keymap.set('n', '<leader>o', vim.diagnostic.open_float)                          -- o(pen)
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename)                                 -- r(ename)
vim.keymap.set('n', '<leader>d', vim.lsp.buf.definition)                             -- d(efinition)
vim.keymap.set('n', '<leader>p', function() vim.diagnostic.jump({ count = -1 }) end) -- p(rev)
vim.keymap.set('n', '<leader>n', function() vim.diagnostic.jump({ count = 1 }) end)  -- n(ext)
vim.keymap.set('n', '<leader>l', vim.diagnostic.setloclist)                          -- l(ist)
vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action)                            -- a(ction)

-- Unbind
vim.keymap.set('n', '<c-z>', function() end)

-- -----------------------------------------------------------------------------
-- Plugins / Modules
-- -----------------------------------------------------------------------------

local function load(name)
  package.loaded[name] = nil -- unset to force reloading
  require(name)
end

load('command_palette')

load('modules.cwd')
load('modules.emacs')
load('modules.statusline')
load('modules.surroundjump')
load('modules.tabline')
load('modules.terminal')
load('modules.tidy')
load('modules.windows')

load('plugins.colorscheme')
load('plugins.completion')
load('plugins.dirvish')
load('plugins.fugitive')
load('plugins.mason')
load('plugins.move')
load('plugins.surround')
load('plugins.treesitter')

load('languages.c')
load('languages.gleam')
load('languages.lua')
load('languages.tailwind')
load('languages.typescript')

pcall(function()
  load('work')
end)
