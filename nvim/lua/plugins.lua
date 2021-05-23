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
	'junegunn/fzf.vim',
	'sheerun/vim-polyglot',
	'lambdalisue/suda.vim',
	'justinmk/vim-dirvish',
	{[[ 'neoclide/coc.nvim', {'branch': 'release'}  ]]},
	'~/projects/tabby',
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

--
-- fzf
--

nvim_call_function('setenv', { 'FZF_DEFAULT_COMMAND', 'rg --files -L' })
nvim_call_function('setenv', { 'FZF_DEFAULT_OPTS', '--exact --reverse --border' })

nvim_set_var('fzf_layout', { window = 'lua fzfwin()' })
nvim_set_var('fzf_preview_window', 'right:0%')

nvim_set_var('fzf_action', {
	['ctrl-t'] = 'tab split',
	['ctrl-x'] = 'split',
	['ctrl-v'] = 'vsplit',
})

nvim_set_var('fzf_colors', {
	fg = { 'fg', 'Normal' },
	bg = { 'bg', 'Normal' },
	hl = { 'fg', 'Function' },
	['fg+'] = { 'fg', 'Normal' },
	['bg+'] = { 'bg', 'CursorLine' },
	['hl+'] = { 'fg', 'Function' },
	border = { 'fg', 'Normal' },
	prompt = { 'fg', 'Type' },
	info = { 'fg', 'String' },
	pointer = { 'fg', 'Statement' },
	marker = { 'fg', 'Type' },
	spinner = { 'fg', 'Keyword' },
})

function fzfwin()
	local width = 80
	local height = 20

  local buf = nvim_create_buf(false, true)
  nvim_buf_set_var(buf, 'signcolumn', false)
 
  nvim_open_win(buf, true, {
		width = width,
		height = height,
		row = (nvim_get_option('lines') - height) / 2,
		col = (nvim_get_option('columns') - width) / 2,
		relative = 'editor',
		style = 'minimal',
	})
end
