-- -----------------------------------------------------------------------------
-- AUTOINSTALL VIM-PLUG
-- -----------------------------------------------------------------------------

local vim_plug_install_path = os.getenv('DOTS') .. '/nvim/autoload/plug.vim'
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
	[[ Plug 'vifm/vifm.vim' ]],
	[[ Plug 'tpope/vim-surround' ]],
	[[ Plug 'tpope/vim-commentary' ]],
	[[ Plug 'junegunn/fzf' ]],
	[[ Plug 'junegunn/fzf.vim' ]],

	-- unstable
    [[ Plug 'tpope/vim-dadbod' ]],
    [[ Plug 'kristijanhusak/vim-dadbod-ui' ]],
    [[ Plug 'Shougo/neco-vim' ]],
    [[ Plug 'neoclide/coc-neco' ]],
	[[ Plug 'vimwiki/vimwiki' ]],

	-- Had conflicts with coc-vetur that caused inconsistent highlighting and
	-- extremely slow startup
    [[ Plug 'sheerun/vim-polyglot' ]],
}

nvim.nvim_call_function('plug#begin', { '$DOTS/nvim/bundle' })
for _, v in ipairs(plugins) do nvim.nvim_command(v) end
nvim.nvim_call_function('plug#end', {})

-- -----------------------------------------------------------------------------
-- ONEDARK
-- -----------------------------------------------------------------------------

nvim.nvim_command([[ colorscheme onedark ]])

-- -----------------------------------------------------------------------------
-- POLYGLOT
-- -----------------------------------------------------------------------------

nvim.nvim_set_var('vue_pre_processors', { 'pug', 'scss' })

-- -----------------------------------------------------------------------------
-- VIM-DADBOD-UI
-- -----------------------------------------------------------------------------

nvim.nvim_set_var('db_ui_auto_execute_table_helpers', 1)

nvim.nvim_set_var('db_ui_table_helpers', {
	mongodb = {
		List = '{table}.find().pretty()',
	},
})

-- -----------------------------------------------------------------------------
-- COC.NVIM
-- -----------------------------------------------------------------------------

nvim.nvim_call_function('coc#add_extension', {
    'coc-snippets',

    'coc-html',
    'coc-css',
    'coc-json',
    'coc-tsserver',
	'coc-prettier',
    'coc-vetur',
	
	'coc-db',

    'coc-clangd',
    'coc-lua',
    'coc-rls',
})

-- Setup prettier command (run automatically on save, see :CocConfig
nvim.nvim_command([[
	command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')
]])

-- " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
-- " position. Coc only does snippet and additional edit on confirm.
nvim.nvim_set_keymap('i', '<cr>', [[ pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>" ]], { 
	noremap = true,
	expr = true,
})

-- " Remap keys for gotos
-- nmap <silent> <c-]> <Plug>(coc-definition)
-- nmap <silent> gy <Plug>(coc-type-definition)
-- nmap <silent> gi <Plug>(coc-implementation)
-- nmap <silent> gr <Plug>(coc-references)

-- " Remap for rename current word
-- nmap <leader>rn <Plug>(coc-rename)

