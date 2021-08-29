-- -----------------------------------------------------------------------------
-- Visual Selection
-- -----------------------------------------------------------------------------

function get_visual_selection()
  local buffer, line_start, column_start = unpack(fn.getpos("'<"))
  local buffer, line_end, column_end = unpack(fn.getpos("'>"))

  local lines = fn.getline(line_start, line_end)
  fn.setpos('.', { { 0, line_start, column_start, 0 } })

  if #lines == 1 then
    lines[1] = lines[1]:sub(column_start, column_end)
  elseif #lines > 1 then
    lines[1] = lines[1]:sub(column_start)
    lines[#lines] = lines[#lines]:sub(1, column_end)
  end

  return table.concat(lines, '\n')
end

function search_visual_selection()
  fn.setreg('/', get_visual_selection())
  cmd('normal n')
end

-- -----------------------------------------------------------------------------
-- CWD Tracking
-- -----------------------------------------------------------------------------

local cwd_cache = {}

function save_cwd()
  local bufname = nvim_buf_get_name(0)
  cwd_cache[bufname] = fn.getcwd()
end

function restore_cwd()
  local bufname = nvim_buf_get_name(0)
  if cwd_cache[bufname] ~= nil then
    cmd(('cd %s'):format(cwd_cache[bufname]))
    cwd_cache[bufname] = nil
  end
end

function track_cwd()
  local bufname = nvim_buf_get_name(0)

  if bufname:match('^term://') then
    if cwd_cache[bufname] ~= nil then
      cmd(('cd %s'):format(cwd_cache[bufname]))
    end
  else
    -- Change to current buffer's parent directory
    cmd(('cd %s'):format(fn.fnamemodify(bufname, ':p:h'):gsub('^suda://', '')))

    -- refresh dirvish after cd
    if nvim_buf_get_option(0, 'filetype') == 'dirvish' then
      cmd('Dirvish')
    end
  end
end

-- -----------------------------------------------------------------------------
-- Dirvish
-- -----------------------------------------------------------------------------

function dirvish_xdg_open()
  local file = fn.expand('<cWORD>')
  local dir = fn.fnamemodify(file, ':p:h')
  local ext = fn.fnamemodify(file, ':e')

  if ext == 'png' then
    os.execute('xdg-open ' .. file .. ' &>/dev/null')
  else
    fn['dirvish#open']('edit', 0)
    cmd('cd ' .. dir)
  end
end

-- -----------------------------------------------------------------------------
-- Headers
--
-- Note that the header formatting relies on comments automatically inserted
-- by vim (see :h 'formatoptions').
-- -----------------------------------------------------------------------------

function setupheaders()
  local comment = opt.commentstring._value:gsub('%%s', '')
  local colorcolumn = tonumber(opt.colorcolumn._value)
  cmd(('iabbrev _h1 %s<cr><cr>%s<Up>'):format(
    comment .. ' ' .. ('-'):rep(colorcolumn - #comment - 1),
    ('-'):rep(colorcolumn - #comment - 1)
  ))
  cmd(('iabbrev _h2 %s<cr><cr><Up>'):format(comment))
end

-- -----------------------------------------------------------------------------
-- Stylua
-- TODO: deprecate this
-- -----------------------------------------------------------------------------

function apply_stylua()
  local stylua = '~/.cargo/bin/stylua --config-path ~/dots/stylua.toml'
  local target = fn.expand('%:p')

  local handle = io.popen(stylua .. ' --check ' .. target .. ' 2>&1 >/dev/null')
  local checkOutput = handle:read('*a')
  handle:close()

  if not checkOutput:match('^error') then
    local cursor_pos = fn.getpos('.')
    cmd('silent exec "%! ' .. stylua .. ' -"')
    fn.setpos('.', cursor_pos)
  end
end
