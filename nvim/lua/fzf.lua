local Array = require('luascript/Array')
local helpers = require('./helpers')

--
-- constants
--

local FZF_PRUNE_DIRS = Array({
  '.cache',
  '.git',
  'node_modules',
  'build',
  'dist',
})

--
-- settings
--

nvim_call_function('setenv', { 'FZF_DEFAULT_COMMAND', 'rg --files -L' })
nvim_call_function(
  'setenv',
  { 'FZF_DEFAULT_OPTS', '--exact --reverse --border' }
)

nvim_set_var('fzf_action', {
  ['ctrl-t'] = 'tab split',
  ['ctrl-x'] = 'split',
  ['ctrl-v'] = 'vsplit',
})

--
-- theme
--

nvim_set_var('fzf_layout', { window = 'lua fzf_win()' })
nvim_set_var('fzf_preview_window', 'right:0%')

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

--
-- fzf_fd
--

function fzf_fd()
  nvim_call_function('fzf#run', {
    nvim_call_function('fzf#wrap', {
      {
        source = ([[ fd --follow --type f %s ]]):format(FZF_PRUNE_DIRS
            :map(function(v)
            return '--exclude ' .. v
          end)
            :join(' ')),
        sink = 'FzfFdSink',
      },
    }),
  })
end

nvim_command([[
	command! -nargs=* FzfFdSink exec 'edit ' . <f-args>
]])

--
-- fzf_cd
--

function fzf_cd()
  nvim_call_function('fzf#run', {
    nvim_call_function('fzf#wrap', {
      {
        source = ([[ fd --follow --type d %s ]]):format(FZF_PRUNE_DIRS
            :map(function(v)
            return '--exclude ' .. v
          end)
            :join(' ')),
        sink = 'FzfCdSink',
      },
    }),
  })
end

nvim_command([[
	command! -nargs=* FzfCdSink exec 'cd ' . <f-args> . '|:Dirvish'
]])

--
-- fzf_favorite_cd
--

function fzf_favorites_cd()
  local favorites = Array({
    'edtechy',
    'projects',
  })

  nvim_call_function('fzf#run', {
    nvim_call_function('fzf#wrap', {
      {
        source = ([[ fd --type d --base-directory ~ --exact-depth 1 %s %s ]]):format(
          FZF_PRUNE_DIRS
              :map(function(v)
              return '--exclude ' .. v
            end)
              :join(' '),
          favorites
              :map(function(v)
              return '--search-path ' .. v
            end)
              :join(' ')
        ),
        sink = 'FzfFavoritesCdSink',
      },
    }),
  })
end

nvim_command([[
	command! -nargs=* FzfFavoritesCdSink exec 'cd ~/' . <f-args> . '|:Dirvish'
]])

--
-- fzf_rg
--

function fzf_rg()
  local rgFlags = Array({
    '--color=always',
    '--smart-case',
    '--line-number',
    '--no-column',
    '--no-heading',
  })

  nvim_call_function('fzf#run', {
    nvim_call_function('fzf#wrap', {
      {
        source = ([[ rg . %s ]]):format(rgFlags:join(' ')),
        options = Array({
          '--ansi',
          '--multi',
          '--delimiter :',
          '--nth 2..',
        }):join(' '),
        sink = 'FzfRgSink',
      },
    }),
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

--
-- fzf_tabby
--

function fzf_tabby()
  nvim_call_function('fzf#run', {
    nvim_call_function('fzf#wrap', {
      {
        source = require('tabby').list(true)
            :map(function(tabname, i)
            return colorize(tostring(i + 1), ANSI.GREEN) .. ':' .. colorize(
              tabname,
              ANSI.RED
            )
          end)
            :raw(),
        options = Array({
          '--ansi',
          '--delimiter :',
          '--nth 2..',
        }):join(' '),
        sink = 'FzfTabbySink',
      },
    }),
  })
end

nvim_command([[
	command! -nargs=* FzfTabbySink lua fzf_tabby_sink(<f-args>)
]])

function fzf_tabby_sink(selection)
  require('tabby').open(selection:match('([^:]+)'))
end
