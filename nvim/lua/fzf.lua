local _ = require('lutil')

--
-- Constants
--

local FZF_PRUNE_DIRS = {
  '.cache',
  '.git',
  'node_modules',
  'build',
  'dist',
}

--
-- Settings
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
-- Theme
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
        source = ([[ fd --follow --type f %s ]]):format(_.join(
          _.map(FZF_PRUNE_DIRS, function(v)
              return '--exclude ' .. v
            end),
          ' '
        )),
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
        source = ([[ fd --follow --type d %s ]]):format(_.join(
          _.map(FZF_PRUNE_DIRS, function(v)
              return '--exclude ' .. v
            end),
          ' '
        )),
        sink = 'FzfCdSink',
      },
    }),
  })
end

nvim_command([[
	command! -nargs=* FzfCdSink exec 'cd ' . <f-args> . '|:Dirvish'
]])

--
-- fzf_favorites
--

function fzf_favorites()
  local favorites = {
    'edtechy',
    'projects',
  }

  nvim_call_function('fzf#run', {
    nvim_call_function('fzf#wrap', {
      {
        source = ([[ fd --type d --base-directory ~ --exact-depth 1 %s %s ]]):format(
          _.join(
            _.map(FZF_PRUNE_DIRS, function(v)
                return '--exclude ' .. v
              end),
            ' '
          ),
          _.join(
            _.map(favorites, function(v)
              return '--search-path ' .. v
            end),
            ' '
          )
        ),
        sink = 'FzfFavoritesSink',
      },
    }),
  })
end

nvim_command([[
	command! -nargs=* FzfFavoritesSink exec 'cd ~/' . <f-args> . '|:Dirvish'
]])

--
-- fzf_rg
--

function fzf_rg()
  local rgFlags = {
    '--color=always',
    '--smart-case',
    '--line-number',
    '--no-column',
    '--no-heading',
  }

  nvim_call_function('fzf#run', {
    nvim_call_function('fzf#wrap', {
      {
        source = ([[ rg . %s ]]):format(_.join(rgFlags, ' ')),
        options = _.join({
          '--ansi',
          '--multi',
          '--delimiter :',
          '--nth 2..',
        }, ' '),
        sink = 'FzfRgSink',
      },
    }),
  })
end

nvim_command([[
	command! -nargs=* FzfRgSink lua fzf_rg_sink(<f-args>)
]])

function fzf_rg_sink(...)
  _.each({ ... }, function(v)
    local columns = _.split(v, ':')
    nvim_command(('edit +%d %s'):format(columns[2], columns[1]))
  end)
end

--
-- fzf_ls
--

function fzf_ls()
  nvim_call_function('fzf#run', {
    nvim_call_function('fzf#wrap', {
      {
        source = {},
        sink = 'FzfLsSink',
      },
    }),
  })
end

nvim_command([[
	command! -nargs=* FzfLsSink exec 'edit ' . <f-args>
]])
