local path = require('lib.path')
local string = require('lib.stdlib').string

local M = {}

function M.buffers()
  local commands = {}

  for _, bufinfo in ipairs(vim.fn.getbufinfo()) do
    if bufinfo.listed == 1 then
      table.insert(commands, {
        label = bufinfo.name,
        weight = bufinfo.lastused,
        callback = function()
          vim.api.nvim_win_set_buf(0, bufinfo.bufnr)
        end,
      })
    end
  end

  table.sort(commands, function(a, b)
    return b.weight < a.weight
  end)

  return commands
end

function M.directories(cwd)
  cwd = cwd or vim.fn.getcwd()

  local commands = {}

  local cmd = ('fd --type d --base-directory %s'):format(cwd)
  local pipe = assert(io.popen(cmd, 'r'))

  for line in pipe:lines() do
    table.insert(commands, {
      label = line,
      callback = function()
        vim.cmd('edit ' .. path.join(cwd, line))
      end,
    })
  end

  pipe:close()
  return commands
end

function M.favorites()
  local commands = {}

  table.insert(commands, {
    label = '~/Downloads/todo.md',
    callback = function()
      vim.cmd('edit ~/Downloads/todo.md')
    end,
  })

  for _, directory in ipairs({ '~/dots', '~/repos', '~/extern' }) do
    table.insert(commands, {
      label = directory,
      callback = function()
        vim.cmd('edit ' .. directory)
      end,
    })

    local cmd = ('fd --type d --base-directory %s --max-depth 1'):format(directory)
    local pipe = assert(io.popen(cmd, 'r'))

    for line in pipe:lines() do
      local filepath = path.join(directory, line)
      table.insert(commands, {
        label = filepath,
        callback = function()
          vim.cmd('edit ' .. filepath)
        end,
      })
    end

    pipe:close()
  end

  return commands
end

function M.files(cwd)
  cwd = cwd or vim.fn.getcwd()

  local commands = {}

  local cmd = ('fd --type f --base-directory %s'):format(cwd)
  local pipe = assert(io.popen(cmd, 'r'))

  for line in pipe:lines() do
    table.insert(commands, {
      label = line,
      callback = function()
        vim.cmd('edit ' .. path.join(cwd, line))
      end,
    })
  end

  pipe:close()
  return commands
end

function M.grep(text, cwd)
  text = text or ''
  cwd = cwd or vim.fn.getcwd()

  local commands = {}

  if text == '' then
    return commands
  end

  -- NOTE: Use `cd` over `rg PATTERN PATH` argument since `cd` will preserve
  -- relative paths in `rg` output.
  local cmd = ('cd %s; rg --fixed-strings --line-number "%s"'):format(cwd, text:gsub('"', '\\"'))
  local pipe = assert(io.popen(cmd, 'r'))

  for line in pipe:lines() do
    local filepath, row, content = line:match('^([^:]+):([0-9]+):%s*(.*)$')

    table.insert(commands, {
      label = filepath .. ': ' .. content,
      callback = function()
        vim.cmd(('edit +%d %s'):format(row, path.join(cwd, filepath)))
      end,
    })
  end

  pipe:close()
  return commands
end

function M.help()
  local commands = {}

  for _, filepath in ipairs(vim.api.nvim_get_runtime_file('doc/tags', true)) do
    local file = assert(io.open(filepath, 'r'))

    for line in file:lines() do
      local name = string.split(line)[1]

      table.insert(commands, {
        label = name,
        weight = #name,
        callback = function()
          vim.cmd('enew | set buftype=help | help ' .. name)
        end,
      })
    end

    file:close()
  end

  table.sort(commands, function(a, b)
    return a.weight < b.weight
  end)

  return commands
end

function M.man()
  local commands = {}
  local pipe = assert(io.popen('apropos .', 'r'))

  for line in pipe:lines() do
    local name, section = line:match('^([^%s]+) %(([^%s]+)%)')

    table.insert(commands, {
      label = line,
      weight = #name,
      callback = function()
        vim.cmd(('enew | set filetype=man | Man %s(%s)'):format(name, section))
      end,
    })
  end

  table.sort(commands, function(a, b)
    return a.weight < b.weight
  end)

  pipe:close()
  return commands
end

return M
