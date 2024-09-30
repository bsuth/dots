local C = require('constants')
local generators = require('command_tree.generators')
local path = require('utils.path')
local io = require('utils.stdlib').io
local table = require('utils.stdlib').table
local sudo = require('utils.sudo')

-- -----------------------------------------------------------------------------
-- Default Commands
-- -----------------------------------------------------------------------------

local DEFAULT_COMMANDS = {

  -- ---------------------------------------------------------------------------
  -- General
  -- ---------------------------------------------------------------------------

  {
    label = 'source',
    callback = function()
      vim.cmd('source $MYVIMRC')
    end,
  },
  {
    label = 'sudo (write)',
    callback = sudo.write,
  },
  {
    label = 'syntax (refresh)',
    callback = function()
      vim.cmd('syntax clear | syntax reset | syntax enable')
    end,
  },
  {
    label = 'clean (buffers)',
    callback = function()
      for _, bufinfo in ipairs(vim.fn.getbufinfo()) do
        if bufinfo.listed == 1 and #bufinfo.windows == 0 then
          vim.api.nvim_buf_delete(bufinfo.bufnr, {})
        end
      end
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Generators
  -- ---------------------------------------------------------------------------

  {
    label = 'buffers',
    subtree = true,
    callback = generators.buffer,
  },
  {
    label = 'directories',
    subtree = true,
    callback = generators.directory,
  },
  {
    label = 'files',
    subtree = true,
    callback = generators.file,
  },
  {
    label = 'grep',
    subtree = true,
    dynamic = true,
    callback = generators.grep,
  },
  {
    label = 'help',
    subtree = true,
    callback = generators.help,
  },
  {
    label = 'man',
    subtree = true,
    callback = generators.man,
  },

  -- ---------------------------------------------------------------------------
  -- Quicklinks
  -- ---------------------------------------------------------------------------

  {
    label = 'home',
    callback = function()
      vim.cmd('edit ' .. C.HOME)
    end,
  },
  {
    label = 'plugins',
    callback = function()
      vim.cmd('edit ' .. C.PLUGINS_DIR)
    end,
  },
  {
    label = 'root',
    callback = function()
      vim.cmd('edit /')
    end,
  },
  {
    label = 'swap',
    callback = function()
      vim.cmd('edit ' .. C.SWAP_DIR)
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Plugins
  -- ---------------------------------------------------------------------------

  {
    label = 'clean (plugins)',
    callback = function()
      -- NOTE: Neovim requires commands for multiline printing...
      -- https://github.com/neovim/neovim/issues/5067
      vim.cmd('lua require("utils.plugins").clean()')
    end,
  },
  {
    label = 'update (plugins)',
    callback = function()
      vim.cmd('lua require("utils.plugins").update()')
    end,
  },
}

-- -----------------------------------------------------------------------------
-- Project Commands
-- -----------------------------------------------------------------------------

local function get_project_root(dir)
  dir = dir or path.lead(vim.fn.getcwd())

  while dir:match('^' .. C.HOME .. '/.+') do
    if io.exists(path.join(dir, '.git')) then
      return dir
    else
      dir = path.lead(path.dirname(dir))
    end
  end
end

local function get_project_commands()
  local project_root = get_project_root()

  if project_root == nil then
    return {}
  end

  return {
    {
      label = 'project',
      callback = function()
        vim.cmd('edit ' .. project_root)
      end,
    },
    {
      label = 'project.directories',
      subtree = true,
      callback = function()
        return generators.directory(project_root)
      end,
    },
    {
      label = 'project.files',
      subtree = true,
      callback = function()
        return generators.file(project_root)
      end,
    },
    {
      label = 'project.grep',
      subtree = true,
      dynamic = true,
      callback = function(text)
        return generators.grep(text, project_root)
      end,
    },
  }
end

-- -----------------------------------------------------------------------------
-- Make Commands
-- -----------------------------------------------------------------------------

local function get_make_root(dir)
  dir = dir or path.lead(vim.fn.getcwd())

  while dir:match('^' .. C.HOME .. '/.+') do
    if io.exists(path.join(dir, 'Makefile')) then
      return dir
    else
      dir = path.lead(path.dirname(dir))
    end
  end
end

local function get_make_commands()
  local make_root = get_make_root()

  if make_root == nil then
    print('blah')
    return {}
  end

  local cmd = table.concat({
    ('make --directory "%s" --dry-run --print-data-base'):format(make_root),
    'grep ".PHONY\\s*:"',
    'sed -E "s/.PHONY\\s*:\\s*(.*)/\\1/"',
    'tr " " "\\n"',
  }, ' | ')

  local subcommands = {}
  local pipe = assert(io.popen(cmd, 'r'))

  print('bah', cmd)
  for line in pipe:lines() do
    print('boo', line)
    table.insert(subcommands, {
      label = line,
      callback = function()
        vim.cmd(('silent exec "!make %s"'):format(line))
      end,
    })
  end

  if #subcommands == 0 then
    return {}
  end

  return {
    {
      label = 'make',
      subtree = true,
      callback = function()
        return subcommands
      end,
    },
  }
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return {
  callback = function()
    return table.merge(
      DEFAULT_COMMANDS,
      generators.favorites(),
      get_project_commands(),
      get_make_commands()
    )
  end,
}
