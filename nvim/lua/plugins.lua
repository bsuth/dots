local plug = io.open(os.getenv('HOME') .. '/.config/nvim/autoload/plug.vim', 'r')

if plug == nil then
	os.execute([[
		curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	]])
	vim.api.nvim_command('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
else
  io.close(plug)
end

local plugins = {
	'joshdick/onedark.vim',
	'drewtempelmeyer/palenight.vim',
	'tpope/vim-surround',
	'tpope/vim-commentary',
	'junegunn/fzf',
	'junegunn/fzf.vim',
	'sheerun/vim-polyglot',
	'lambdalisue/suda.vim',
	'justinmk/vim-dirvish',
	{[[ 'neoclide/coc.nvim', {'branch': 'release'}  ]]},
}

vim.api.nvim_call_function('plug#begin', { '~/.config/nvim/bundle' })
for _, plugin in ipairs(plugins) do
	if type(plugin) == 'string' then
		vim.api.nvim_command(([[ Plug '%s' ]]):format(plugin))
	elseif type(plugin) == 'table' then
		vim.api.nvim_command('Plug ' .. plugin[1])
	end
end
vim.api.nvim_call_function('plug#end', {})

vim.api.nvim_set_var('fzf_layout', { down = '50%' })
vim.api.nvim_set_var('fzf_preview_window', 'right:60%')
vim.api.nvim_set_var('suda_smart_edit', true)
vim.api.nvim_command('colorscheme onedark')

vim.api.nvim_set_var('coc_global_extensions', {
	'coc-tsserver',
	'coc-css',
	'coc-json',
	'coc-prettier',
})
