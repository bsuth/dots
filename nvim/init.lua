-- -----------------------------------------------------------------------------
-- INIT
-- -----------------------------------------------------------------------------

ROOT = '/home/bsuth/dots/nvim'
package.path = package.path .. (';%s/?.lua'):format(ROOT)
nvim = vim.api
default_map_args = { noremap = true }

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
	[[ Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } ]],
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

	vue_pre_processors = { 'scss' },

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

local XDG_OPENERS = {
	images = {
		png = 'nomacs',
		jpeg = 'nomacs',
		jpg = 'nomacs',
		pdf = 'xournal',
	},
}


function bsuth_dirvish_xdg_open()
	local file = nvim.nvim_call_function('expand', {'<cWORD>'})
	local dir = nvim.nvim_call_function('fnamemodify', {file, ':p:h'})
	local basename = file:match('([^/]+)$')
	local ext = basename and basename:match('.+%.(.+)$')

	local img_opener = XDG_OPENERS['images'][ext]

	if img_opener ~= nil then
		nvim.nvim_command(('silent !nohup %s %s'):format(img_opener, file))
	else
		nvim.nvim_call_function('dirvish#open', {'edit', 0})
		nvim.nvim_command('cd ' .. dir)
	end
end

function bsuth_bufenter()
	local bufname = nvim.nvim_call_function('bufname', {})
	local bufdir = nvim.nvim_call_function('fnamemodify', {bufname, ':p:h'})
	local bufft = nvim.nvim_buf_get_option(0, 'filetype')

	if not bufname:match('^term://*') then 
		nvim.nvim_command('cd ' .. bufdir)
		if bufft == 'dirvish' then
			nvim.nvim_command('Dirvish')
		end
	end
end

local augroups = {
	general = {
		'BufEnter * lua bsuth_bufenter()',
		'TermOpen term://* setlocal nonumber',
		'FileType dirvish nnoremap <buffer><silent> <cr> :lua bsuth_dirvish_xdg_open()<cr>',
		
		-- Hide dot files
		-- [[ FileType dirvish silent keeppatterns g@\v/\.[^\/]+/?$@d _ ]],
	},
	languages = {
		'FileType html,scss,css,vue setlocal shiftwidth=2 tabstop=2 softtabstop=2',
	}
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
	-- General
	['<leader>ev'] = ':Dirvish ~/dots/nvim<cr>',
	['<leader>sv'] = ':source $MYVIMRC<cr>',
	['<leader>/'] = ':nohlsearch<cr><c-l>',
	['<c-_>'] = ':Commentary<cr>',
	['<c-t>'] = ':Dirvish<cr>',

	-- Window
	['<leader>w'] = '<c-w>',
	['<c-h>'] = '<c-w>h',
	['<c-j>'] = '<c-w>j',
	['<c-k>'] = '<c-w>k',
	['<c-l>'] = '<c-w>l',

	['<leader><c-l>'] = ':rightbelow :vsp|:Dirvish<cr>',
	['<leader><c-k>'] = ':aboveleft :sp|:Dirvish<cr>',
	['<leader><c-j>'] = ':rightbelow :sp|:Dirvish<cr>',
	['<leader><c-h>'] = ':aboveleft :vsp|:Dirvish<cr>',

	['<c-Left>'] = '<c-w>H',
	['<c-Down>'] = '<c-w>J',
	['<c-Up>'] = '<c-w>K',
	['<c-Right>'] = '<c-w>L',

	-- Buffers
	['<c-w>'] = ':bd<cr>',
	['<Tab>'] = ':bn<cr>',
	['<s-Tab>'] = ':bp<cr>',

	-- External Programs
	['<c-space>'] = ':term<cr>:startinsert<cr>',
	['<leader>?'] = ':help ',
	['<leader>v?'] = ':vert :help ',

	-- FZF
	['<leader>fd'] = ':Files<cr>',
	['<leader>cd'] = ':call fzf#run(fzf#wrap({"source": "fdfind -L --type d"}))<cr>',
	['<leader>rg'] = ':Rg<cr>',
	['<leader>ls'] = ':Buffers<cr>',
}

local vmap = {
	['<c-_>'] = ':Commentary<cr>',
}

local tmap = {
	['<c-[>'] = '<c-\\><c-n>',
}

for mode, map in pairs({ n = nmap, v = vmap, t = tmap }) do
	for from, to in pairs(map) do
		if type(to) == 'table' then
			nvim.nvim_set_keymap(mode, from, to[1], to[2])
		else
			nvim.nvim_set_keymap(mode, from, to, default_map_args)
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
