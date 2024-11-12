local C = require('constants')
local path = require('lib.path')
local io = require('lib.stdlib').io
local table = require('lib.stdlib').table

-- -----------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------

local M = {}
local PLUGINS = {}

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

if not io.exists(C.PLUGINS_DIR) then
  os.execute('mkdir -p ' .. C.PLUGINS_DIR)
end

for _, plugin_dir in ipairs(vim.fn.readdir(C.PLUGINS_DIR)) do
  table.insert(PLUGINS, {
    path = path.join(C.PLUGINS_DIR, plugin_dir),
    loaded = false,
    config = nil,
  })
end

-- -----------------------------------------------------------------------------
-- API
-- -----------------------------------------------------------------------------

function M.use(plugin_name, config)
  local plugin_dir = (config and config.dir) or path.basename(plugin_name)
  local plugin_path = path.join(C.PLUGINS_DIR, plugin_dir)

  local plugin = table.find(PLUGINS, function(plugin)
    return plugin.path == plugin_path
  end)

  if plugin ~= nil then
    plugin.loaded = true
    plugin.config = config
    return
  end

  local command = (config and config.symlink)
      and ('ln -sn %s %s'):format(plugin_dir, plugin_path)
      or ('git clone --depth 1 https://github.com/%s.git %s'):format(plugin_name, plugin_path)

  print(command)
  print(vim.fn.system(command))

  if io.exists(path.join(plugin_path, 'lua')) then
    package.path = table.concat({
      package.path,
      path.join(plugin_path, 'lua/?.lua'),
      path.join(plugin_path, 'lua/?/init.lua'),
    }, ';')
  end

  if config and type(config.on_install) == 'function' then
    local cwd = vim.fn.getcwd()
    vim.cmd('cd ' .. plugin_path)
    config.on_install()
    vim.cmd('cd ' .. cwd)
  end

  table.insert(PLUGINS, {
    path = plugin_path,
    loaded = true,
    config = config,
  })
end

function M.update()
  for _, plugin in ipairs(PLUGINS) do
    local command = ('git -C %s pull'):format(plugin.path)

    print(command)
    print(vim.fn.system(command))

    if plugin.config and type(plugin.config.on_update) == 'function' then
      local cwd = vim.fn.getcwd()
      vim.cmd('cd ' .. plugin.path)
      plugin.config.on_update()
      vim.cmd('cd ' .. cwd)
    end
  end
end

function M.clean()
  local used_plugins = {}
  local unused_plugins = {}

  for _, plugin in ipairs(PLUGINS) do
    if plugin.loaded == true then
      table.insert(used_plugins, plugin)
    else
      table.insert(unused_plugins, plugin)
    end
  end

  if #unused_plugins == 0 then
    print('no unused plugins')
    return
  end

  for _, plugin in ipairs(unused_plugins) do
    local basename = path.basename(plugin.path)
    local input = vim.fn.input(("remove %s?: "):format(basename)):lower()

    if input == 'y' or input == 'yes' then
      vim.fn.system('rm -rf ' .. plugin.path)
      table.clear(PLUGINS, plugin)
    end
  end
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return M
