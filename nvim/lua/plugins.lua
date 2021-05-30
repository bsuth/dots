local Array = require 'luascript/Array'

--
-- vim-plug
--

local plug = io.open(os.getenv('HOME') .. '/.config/nvim/autoload/plug.vim', 'r')

if plug == nil then
	os.execute([[
		curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	]])
	nvim_command('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
else
  io.close(plug)
end

local plugins = {
	'joshdick/onedark.vim',
	'tpope/vim-surround',
	'tpope/vim-commentary',
	'junegunn/fzf',
	'sheerun/vim-polyglot',
	'lambdalisue/suda.vim',
	'justinmk/vim-dirvish',
	{[[ 'neoclide/coc.nvim', {'branch': 'release'}  ]]},
	'~/projects/nvim-tabby',
	'~/projects/nvim-imacs',
}

nvim_call_function('plug#begin', { '~/.config/nvim/bundle' })
for _, plugin in ipairs(plugins) do
	if type(plugin) == 'string' then
		nvim_command(([[ Plug '%s' ]]):format(plugin))
	elseif type(plugin) == 'table' then
		nvim_command('Plug ' .. plugin[1])
	end
end
nvim_call_function('plug#end', {})

--
-- misc
--

nvim_set_var('suda_smart_edit', true)
nvim_command('colorscheme onedark')

--
-- coc
--

nvim_set_var('coc_global_extensions', {
	'coc-tsserver',
	'coc-css',
	'coc-json',
	'coc-prettier',
})
