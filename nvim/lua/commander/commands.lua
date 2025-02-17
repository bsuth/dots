local C = require('constants')
local generators = require('commander.generators')
local path = require('lib.path')
local io = require('lib.stdlib').io
local table = require('lib.stdlib').table
local sudo = require('lib.sudo')

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
    callback = function()
      return { generator = generators.buffers }
    end,
  },
  {
    label = 'directories',
    subtree = true,
    callback = function()
      local cwd = vim.fn.getcwd()

      local function cwd_directories()
        return generators.directories(cwd)
      end

      return { generator = cwd_directories }
    end,
  },
  {
    label = 'files',
    subtree = true,
    callback = function()
      local cwd = vim.fn.getcwd()

      local function cwd_files()
        return generators.files(cwd)
      end

      return { generator = cwd_files }
    end,
  },
  {
    label = 'grep',
    callback = function()
      local cwd = vim.fn.getcwd()

      local function cwd_grep(text)
        return generators.grep(text, cwd)
      end

      return { generator = cwd_grep, lazy = true }
    end,
  },
  {
    label = 'help',
    subtree = true,
    callback = function()
      return { generator = generators.help }
    end,
  },
  {
    label = 'man',
    subtree = true,
    callback = function()
      return { generator = generators.man }
    end,
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
    label = 'plugins.root',
    callback = function()
      vim.cmd('edit ' .. C.PLUGINS_DIR)
    end,
  },
  {
    label = 'plugins.clean',
    callback = function()
      -- NOTE: Neovim requires commands for multiline printing...
      -- https://github.com/neovim/neovim/issues/5067
      vim.cmd('lua require("lib.plugins").clean()')
    end,
  },
  {
    label = 'plugins.update',
    callback = function()
      vim.cmd('lua require("lib.plugins").update()')
    end,
  },
}

-- -----------------------------------------------------------------------------
-- Project Commands
-- -----------------------------------------------------------------------------

local function get_git_root(dir)
  dir = dir or path.lead(vim.fn.getcwd())

  while dir:match('^' .. C.HOME .. '/.+') do
    if io.exists(path.join(dir, '.git')) then
      return dir
    else
      dir = path.lead(path.dirname(dir))
    end
  end
end

local function get_git_commands()
  local git_root = get_git_root()

  if git_root == nil then
    return {}
  end

  return {
    {
      label = 'git.root',
      callback = function()
        vim.cmd('edit ' .. git_root)
      end,
    },
    {
      label = 'git.directories',
      subtree = true,
      callback = function()
        local function git_directories()
          return generators.directories(git_root)
        end

        return { generator = git_directories }
      end,
    },
    {
      label = 'git.files',
      subtree = true,
      callback = function()
        local function git_files()
          return generators.files(git_root)
        end

        return { generator = git_files }
      end,
    },
    {
      label = 'git.grep',
      subtree = true,
      lazy = true,
      callback = function()
        local function git_grep(text)
          return generators.grep(text, git_root)
        end

        return { generator = git_grep, lazy = true }
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
    return {}
  end

  local pipe_cmd = table.concat({
    ('make --directory "%s" --dry-run --print-data-base'):format(make_root),
    'grep ".PHONY\\s*:"',
    'sed -E "s/.PHONY\\s*:\\s*(.*)/\\1/"',
    'tr " " "\\n"',
  }, ' | ')

  local commands = {}
  local pipe = assert(io.popen(pipe_cmd, 'r'))

  for line in pipe:lines() do
    table.insert(commands, {
      label = "make." .. line,
      callback = function()
        vim.cmd(('silent exec "!make --directory %s %s"'):format(make_root, line))
      end,
    })
  end

  return commands
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return {
  generator = function()
    return table.merge(
      DEFAULT_COMMANDS,
      generators.favorites(),
      get_git_commands(),
      get_make_commands()
    )
  end,
}
