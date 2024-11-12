local Commander = require('commander.commander')
local table = require('lib.stdlib').table

local commanders = {}

vim.keymap.set('n', '<m-space>', function()
  local current_window = vim.api.nvim_get_current_win()

  for _, commander in pairs(commanders) do
    if current_window == commander.window then
      commander:close()
      return
    end
  end

  local current_commander = commanders[current_window]

  if current_commander == nil then
    commanders[current_window] = Commander(current_window)
    commanders[current_window]:open()
  elseif vim.api.nvim_win_is_valid(current_commander.window) then
    vim.api.nvim_set_current_win(current_commander.window)
    vim.cmd('startinsert!')
  else
    current_commander:open()
  end
end)

vim.api.nvim_create_autocmd('WinClosed', {
  group = 'bsuth',
  callback = function(params)
    local closed_window = tonumber(params.match)

    if closed_window and commanders[closed_window] ~= nil then
      commanders[closed_window]:destroy()
      commanders[closed_window] = nil
    end

    for _, commander in pairs(commanders) do
      if closed_window == commander.window then
        commander:close()
      end
    end
  end,
})

vim.api.nvim_create_autocmd('WinResized', {
  group = 'bsuth',
  callback = function()
    local resized_windows = vim.api.nvim_get_vvar('event').windows

    for parent_window, commander in pairs(commanders) do
      if table.has(resized_windows, parent_window) and commander.window ~= -1 then
        commander:render()
        vim.api.nvim_win_set_config(commander.window, {
          width = vim.api.nvim_win_get_width(parent_window),
        })
      end
    end
  end,
})
