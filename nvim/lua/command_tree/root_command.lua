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
    type = 'tree',
    callback = generators.buffer,
  },
  {
    label = 'directories',
    type = 'tree',
    callback = generators.directory,
  },
  {
    label = 'files',
    type = 'tree',
    callback = generators.file,
  },
  {
    label = 'grep',
    type = 'dynamic_tree',
    callback = generators.grep,
  },
  {
    label = 'help',
    type = 'tree',
    callback = generators.help,
  },
  {
    label = 'man',
    type = 'tree',
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
      label = 'directories (project)',
      type = 'tree',
      callback = function()
        return generators.directory(project_root)
      end,
    },
    {
      label = 'files (project)',
      type = 'tree',
      callback = function()
        return generators.file(project_root)
      end,
    },
    {
      label = 'grep (project)',
      type = 'dynamic_tree',
      callback = function(text)
        return generators.grep(text, project_root)
      end,
    },
  }
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return {
  label = '[CT]',
  type = 'tree',
  callback = function()
    local commands = {}

    table.merge(commands, DEFAULT_COMMANDS)
    table.merge(commands, generators.favorites())
    table.merge(commands, get_project_commands())

    return commands
  end,
}
