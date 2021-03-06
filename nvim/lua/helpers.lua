local _ = require('lutil')

function docs()
  local filetype = nvim_buf_get_option(0, 'filetype')
  local cWORD = nvim_call_function('expand', { '<cWORD>' })

  if _.has({ 'vim', 'help' }, filetype) then
    nvim_command('h ' .. cWORD)
  else
    nvim_command('Man ' .. cWORD)
  end
end

function get_visual_selection()
  local buffer, line_start, column_start = unpack(nvim_call_function('getpos', {
    "'<",
  }))

  local buffer, line_end, column_end = unpack(nvim_call_function(
    'getpos',
    { "'>" }
  ))

  local lines = nvim_call_function('getline', { line_start, line_end })
  nvim_call_function('setpos', { '.', { { 0, line_start, column_start, 0 } } })

  if #lines == 1 then
    lines[1] = lines[1]:sub(column_start, column_end)
  elseif #lines > 1 then
    lines[1] = lines[1]:sub(column_start)
    lines[#lines] = lines[#lines]:sub(1, column_end)
  end

  return _.join(lines, '\n')
end

function search_visual_selection()
  nvim_call_function('setreg', { '/', get_visual_selection() })
  nvim_command('normal n')
end

function on_bufenter()
  local buffer = {
    name = nvim_buf_get_name(0),
    dir = nvim_call_function('fnamemodify', { nvim_buf_get_name(0), ':p:h' }):gsub(
      '^suda://',
      ''
    ),
    filetype = nvim_buf_get_option(0, 'filetype'),
  }

  if buffer.name:match('^term://') then
    return
  end

  nvim_command('cd ' .. buffer.dir)

  if buffer.filetype == 'dirvish' then
    nvim_command('Dirvish')
  end
end

function dirvish_open()
  local file = nvim_call_function('expand', { '<cWORD>' })
  local dir = nvim_call_function('fnamemodify', { file, ':p:h' })
  local ext = nvim_call_function('fnamemodify', { file, ':e' })

  if ext == 'png' then
    os.execute('xdg-open ' .. file .. ' &>/dev/null')
  else
    nvim_call_function('dirvish#open', { 'edit', 0 })
    nvim_command('cd ' .. dir)
  end
end

function apply_stylua()
  local stylua = '~/.cargo/bin/stylua --config-path ~/dots/stylua.toml'
  local target = nvim_call_function('expand', { '%:p' })

  local handle = io.popen(stylua .. ' --check ' .. target .. ' 2>&1 >/dev/null')
  local checkOutput = handle:read('*a')
  handle:close()

  if not checkOutput:match('^error') then
    local cursor_pos = nvim_call_function('getpos', { '.' })
    nvim_command('silent exec "%! ' .. stylua .. ' -"')
    nvim_call_function('setpos', { '.', cursor_pos })
  end
end
