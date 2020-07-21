-- -----------------------------------------------------------------------------
-- AUTOINSTALL VIM-PLUG
-- -----------------------------------------------------------------------------

local vim_plug_install_path = '$DOTS/nvim/autoload/plug.vim'
local f = io.open(vim_plug_install_path, 'r')

if f == nil then
    os.execute(('silent !curl -fLo %s --create-dirs %s'):format(
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
    [[ Plug 'sheerun/vim-polyglot' ]],
	[[ Plug 'tpope/vim-surround' ]],
	[[ Plug 'tpope/vim-commentary' ]],

	-- unstable
    [[ Plug 'Shougo/neco-vim' ]],
    [[ Plug 'neoclide/coc-neco' ]],
	[[ Plug 'vimwiki/vimwiki' ]],
	-- [[ Plug 'vim-airline/vim-airline' ]],
}

vim.api.nvim_call_function('plug#begin', { '$DOTS/nvim/bundle' })
for _, v in ipairs(plugins) do vim.api.nvim_command(v) end
vim.api.nvim_call_function('plug#end', {})

-- -----------------------------------------------------------------------------
-- GENERAL PLUGIN OPTIONS
-- -----------------------------------------------------------------------------

vim.api.nvim_command([[ colorscheme onedark ]])

-- -----------------------------------------------------------------------------
-- COC.NVIM OPTIONS
-- -----------------------------------------------------------------------------

vim.api.nvim_call_function('coc#add_extension', {
	'coc-lists',
    'coc-snippets',
    'coc-html',
    'coc-emmet',
    'coc-css',
    'coc-json',
    'coc-tsserver',
    'coc-vetur',
    'coc-clangd',
    'coc-lua',
})
