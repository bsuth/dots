local create_command_tree = require('command_tree.command_tree')
local table = require('utils.stdlib').table

local command_trees = {}

local function toggle()
  local window = vim.api.nvim_get_current_win()

  for _, command_tree in pairs(command_trees) do
    if window == command_tree.window then
      command_tree:close()
      return
    end
  end

  local command_tree = command_trees[window]

  if command_tree == nil then
    command_trees[window] = create_command_tree(window)
  elseif vim.api.nvim_win_is_valid(command_tree.window) then
    vim.api.nvim_set_current_win(command_tree.window)
    vim.cmd('startinsert!')
  else
    command_trees[window]:open()
  end
end

vim.keymap.set('i', '<m-space>', toggle)
vim.keymap.set('n', '<m-space>', toggle)

vim.api.nvim_create_autocmd('WinClosed', {
  group = 'bsuth',
  callback = function(params)
    local window = tonumber(params.match)

    if window and command_trees[window] ~= nil then
      command_trees[window]:destroy()
      command_trees[window] = nil
    end

    for _, command_tree in pairs(command_trees) do
      if window == command_tree.window then
        command_tree:close()
      end
    end
  end,
})

vim.api.nvim_create_autocmd('WinResized', {
  group = 'bsuth',
  callback = function()
    for window, command_tree in pairs(command_trees) do
      if table.has(vim.api.nvim_get_vvar('event').windows, window) and command_tree.window ~= -1 then
        command_tree:render()
        vim.api.nvim_win_set_config(command_tree.window, {
          width = vim.api.nvim_win_get_width(window),
        })
      end
    end
  end,
})
