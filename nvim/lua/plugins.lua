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

--
-- fzf
--

local fzfPruneDirs = Array {
	'.cache',
	'.git',
	'node_modules',
	'build',
	'dist',
}

nvim_call_function('setenv', { 'FZF_DEFAULT_COMMAND', 'rg --files -L' })
nvim_call_function('setenv', { 'FZF_DEFAULT_OPTS', '--exact --reverse --border' })

nvim_set_var('fzf_layout', { window = 'lua fzf_win()' })
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

function fzf_win()
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

function fzf_cd()
	nvim_call_function('fzf#run', {
		nvim_call_function('fzf#wrap', {{
			source = ([[ fd --follow --type d %s ]]):format(
				fzfPruneDirs:map(function(v) return '--exclude '..v end):join(' ')
			),
			sink = 'FzfCdSink',
		}})
	})
end

nvim_command([[
	command! -nargs=* FzfCdSink exec 'cd ' . <f-args> . '|:Dirvish'
]])

function fzf_favorites_cd()
	local favorites = Array {
		'edtechy',
		'projects',
	}

	nvim_call_function('fzf#run', {
		nvim_call_function('fzf#wrap', {{
			source = ([[ fd --type d --base-directory ~ --exact-depth 1 %s %s ]]):format(
				fzfPruneDirs:map(function(v) return '--exclude '..v end):join(' '),
				favorites:map(function(v) return '--search-path '..v end):join(' ')
			),
			sink = 'FzfBookmarkCdSink',
		}})
	})
end

nvim_command([[
	command! -nargs=* FzfBookmarkCdSink exec 'cd ~/' . <f-args> . '|:Dirvish'
]])

function fzf_rg()
	local fzfOptions = Array {
		'--ansi',
		'--multi',
		'--delimiter :',
		'--nth 2..',
	}

	local rgFlags = Array {
		'--color=always',
		'--smart-case',
		'--line-number',
		'--no-column',
		'--no-heading',
	}

	nvim_call_function('fzf#run', {
		nvim_call_function('fzf#wrap', {{
			source = ([[ rg . %s ]]):format(rgFlags:join(' ')),
			options = fzfOptions:join(' '),
			sink = 'FzfRgSink',
		}})
	})
end

nvim_command([[
	command! -nargs=* FzfRgSink lua fzf_rg_sink(<f-args>)
]])

function fzf_rg_sink(...)
	-- TODO: luascript split
	Array({ ... }):each(function(v)
		local columns = {}
		for match in v:gmatch('[^:]+') do
			table.insert(columns, match)
		end
		nvim_command(('edit +%d %s'):format(columns[2], columns[1]))
	end)
end
