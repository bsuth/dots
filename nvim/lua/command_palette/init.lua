local CP = require('command_palette.command_palette')
local settings = require('command_palette.settings')
local table = require('lib.stdlib').table

---@type table<number, CommandPalette>
local command_palettes = {}

vim.keymap.set('n', '<m-space>', function()
  local current_window = vim.api.nvim_get_current_win()

  for _, command_palette in pairs(command_palettes) do
    if current_window == command_palette.window then
      CP.close(command_palette)
      return
    end
  end

  local current_commander = command_palettes[current_window]

  if current_commander == nil then
    command_palettes[current_window] = CP.create(current_window)
    CP.open(command_palettes[current_window])
  elseif vim.api.nvim_win_is_valid(current_commander.window) then
    vim.api.nvim_set_current_win(current_commander.window)
    vim.cmd('startinsert!')
  else
    CP.open(current_commander)
  end
end)

vim.api.nvim_create_autocmd('WinClosed', {
  group = 'bsuth',
  callback = function(params)
    local closed_window = tonumber(params.match)

    if closed_window and command_palettes[closed_window] ~= nil then
      CP.destroy(command_palettes[closed_window])
      command_palettes[closed_window] = nil
    end

    for _, command_palette in pairs(command_palettes) do
      if closed_window == command_palette.window then
        CP.close(command_palette)
      end
    end
  end,
})

vim.api.nvim_create_autocmd('WinResized', {
  group = 'bsuth',
  callback = function()
    local resized_windows = vim.api.nvim_get_vvar('event').windows

    for parent_window, command_palette in pairs(command_palettes) do
      if table.has(resized_windows, parent_window) and command_palette.window ~= -1 then
        -- Resize the command palette just in case nvim tries to resize the
        -- window for us, for example when another split window is closed.
        CP.resize(command_palette)
      end
    end
  end,
})
