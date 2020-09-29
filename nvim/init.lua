-- -----------------------------------------------------------------------------
-- INIT
-- -----------------------------------------------------------------------------

ROOT = '/home/bsuth/dots/nvim'
package.path = package.path .. (';%s/?.lua'):format(ROOT)
nvim = vim.api

-- -----------------------------------------------------------------------------
-- AUTOINSTALL VIM-PLUG
-- -----------------------------------------------------------------------------

local vim_plug_install_path = ROOT .. '/autoload/plug.vim'
local f = io.open(vim_plug_install_path, 'r')

if f == nil then
    os.execute(('curl -fLo %s --create-dirs %s'):format(
		vim_plug_install_path,
		'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	))
else
	f:close()
end

-- -----------------------------------------------------------------------------
-- PLUGINS
-- -----------------------------------------------------------------------------

local plugins = {
	-- stable
	[[ Plug 'joshdick/onedark.vim' ]],
	[[ Plug 'neoclide/coc.nvim', { 'branch': 'release' } ]],
	[[ Plug 'tpope/vim-surround' ]],
	[[ Plug 'tpope/vim-commentary' ]],
    [[ Plug 'tpope/vim-eunuch' ]],
    [[ Plug 'justinmk/vim-dirvish' ]],
	[[ Plug 'junegunn/fzf' ]],
	[[ Plug 'junegunn/fzf.vim' ]],
    [[ Plug 'sheerun/vim-polyglot' ]],

	-- unstable
    [[ Plug 'tpope/vim-dadbod' ]],
    [[ Plug 'kristijanhusak/vim-dadbod-ui' ]],
    [[ Plug 'Shougo/neco-vim' ]],
    [[ Plug 'neoclide/coc-neco' ]],
}

nvim.nvim_call_function('plug#begin', { ROOT .. '/bundle' })
for _, plugin in ipairs(plugins) do
	nvim.nvim_command(plugin)
end
nvim.nvim_call_function('plug#end', {})

-- -----------------------------------------------------------------------------
-- OPTIONS
-- -----------------------------------------------------------------------------

local global_options = {
    ignorecase = true,
    smartcase = true,
    termguicolors = true,
	splitright = true,
	splitbelow = true,
	clipboard = 'unnamedplus',
}

local buf_options = {
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
}

local win_options = {
    number = true,
    wrap = false,
	colorcolumn = '80',
	signcolumn = 'yes',
}

-- VimScript's :set command is actually an alias for both :setlocal and
-- :setglobal. We don't have an equivalent api function so we have to remember
-- to change both the local and global options!

for k, v in pairs(global_options) do
    nvim.nvim_set_option(k, v)
end

for k, v in pairs(buf_options) do
    nvim.nvim_set_option(k, v)
    nvim.nvim_buf_set_option(0, k, v)
end

for k, v in pairs(win_options) do
    nvim.nvim_set_option(k, v)
    nvim.nvim_win_set_option(0, k, v)
end

-- -----------------------------------------------------------------------------
-- VARIABLES / SETTINGS
-- -----------------------------------------------------------------------------

local vars = {
	mapleader = ' ',

	vue_pre_processors = { 'typescript', 'scss' },

	fzf_layout =  { down = '50%' },
	fzf_preview_window = 'right:60%',

	db_ui_auto_execute_table_helpers = 1,
	db_ui_table_helpers = {
		mongodb = {
			List = '{table}.find().pretty()',
		},
	},
}

for var, value in pairs(vars) do
	nvim.nvim_set_var(var, value)
end

nvim.nvim_command([[ colorscheme onedark ]])
nvim.nvim_command([[ highlight ColorColumn guibg=#585858 ]])

nvim.nvim_call_function('coc#add_extension', {
    'coc-snippets',
    'coc-html',
    'coc-css',
    'coc-json',
    'coc-tsserver',
    'coc-vetur',
	'coc-db',
	'coc-python',
    'coc-clangd',
    -- 'coc-lua',
})

-- -----------------------------------------------------------------------------
-- AUGROUPS
-- -----------------------------------------------------------------------------

local augroups = {
	term = {
		'TermOpen term://* setlocal nonumber',
	},
	dirvish = {
		'FileType dirvish silent! :cd %',

		-- Hide dot files
		-- [[ FileType dirvish silent keeppatterns g@\v/\.[^\/]+/?$@d _ ]],
	},
}

for augroup, autocmds in pairs(augroups) do
	nvim.nvim_command(('augroup bsuth-%s'):format(augroup))
	for _, autocmd in ipairs(autocmds) do nvim.nvim_command(('au %s'):format(autocmd)) end
	nvim.nvim_command('augroup END')
end

-- -----------------------------------------------------------------------------
-- MAPPINGS
-- -----------------------------------------------------------------------------

local nmap = {
	['<leader>sv'] = ':source $MYVIMRC<cr>',
	['<leader>/'] = ':nohlsearch<cr><c-l>',
	['<c-_>'] = ':Commentary<cr>',

	-- Open console in current directory
	['<leader><cr>'] = ':silent !st -e nvim -c ":term" 2>/dev/null & disown<cr>',

	-- Window
	['<leader>w'] = '<c-w>',
	['<c-h>'] = '<c-w>h',
	['<c-j>'] = '<c-w>j',
	['<c-k>'] = '<c-w>k',
	['<c-l>'] = '<c-w>l',
	['<leader><c-h>'] = '<c-w>H',
	['<leader><c-j>'] = '<c-w>J',
	['<leader><c-k>'] = '<c-w>K',
	['<leader><c-l>'] = '<c-w>L',

	-- Buffers
	['<c-w>'] = ':bd<cr>',
	['<Tab>'] = ':bn<cr>',
	['<s-Tab>'] = ':bp<cr>',

	-- Help
	['<leader><leader>?'] = ':help  | :wincmd o' .. ('<left>'):rep(12),
	['<leader>?'] = ':help ',
	['<leader>v?'] = ':vert :help ',

	-- Term
	['<leader><leader><cr>'] = ':term<cr>:startinsert<cr>',
	['<leader><cr>'] = ':sp|:term<cr>:startinsert<cr>',
	['<leader>v<cr>'] = ':vsp|:term<cr>:startinsert<cr>',

	-- Dirvish
	['<leader>ev'] = ':Dirvish ~/dots/nvim<cr>',
	['<c-t>'] = ':Dirvish<cr>',
	['<leader>sp'] = ':sp|:Dirvish<cr>',
	['<leader>vsp'] = ':vsp|:Dirvish<cr>',

	-- FZF
	['<leader>fd'] = ':Files<cr>',
	['<leader>cd'] = ':call fzf#run(fzf#wrap({"source": "fd --type d"}))<cr>',
	['<leader>rg'] = ':Rg<cr>',
	['<leader>ls'] = ':Buffers<cr>',
}

local vmap = {
	['<c-_>'] = ':Commentary<cr>',
}

local tmap = {
	['<c-[>'] = '<c-\\><c-n>',
}

local default_args = { noremap = true }

for mode, map in pairs({ n = nmap, v = vmap, t = tmap }) do
	for from, to in pairs(map) do
		if type(to) == 'table' then
			nvim.nvim_set_keymap(mode, from, to[1], to[2])
		else
			nvim.nvim_set_keymap(mode, from, to, default_args)
		end
	end
end

-- -----------------------------------------------------------------------------
-- CONFIG
-- -----------------------------------------------------------------------------

local f = io.open(ROOT .. '/__init.lua', 'r')
if f ~= nil then
	require '__init'
	f:close()
end
