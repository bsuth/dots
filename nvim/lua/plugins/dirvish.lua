local edit = require('lib.edit')
local plugins = require('lib.plugins')

plugins.use('justinmk/vim-dirvish')

-- -----------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------

-- prevent netrw from taking over:
-- https://github.com/justinmk/vim-dirvish/issues/137
vim.g.loaded_netrwPlugin = true

local XDG_OPEN_COMMANDS = {
  jpg = 'firefox-developer-edition',
  jpeg = 'firefox-developer-edition',
  mp3 = 'mpv --player-operation-mode=pseudo-gui',
  mp4 = 'mpv --player-operation-mode=pseudo-gui',
  pdf = 'firefox-developer-edition',
  png = 'firefox-developer-edition',
  wav = 'mpv --player-operation-mode=pseudo-gui',
}

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

local function xdg_open()
  local file = vim.api.nvim_get_current_line()
  local extension = vim.fn.fnamemodify(file, ':e')
  local xdg_open_command = XDG_OPEN_COMMANDS[extension]

  if xdg_open_command ~= nil then
    vim.fn.jobstart(('%s "%s" & disown'):format(xdg_open_command, file))
  else
    edit(file)
  end
end

-- -----------------------------------------------------------------------------
-- Autocommands
-- -----------------------------------------------------------------------------

vim.api.nvim_create_autocmd('FileType', {
  group = 'bsuth',
  pattern = 'dirvish',
  callback = function()
    vim.keymap.set('n', '<cr>', xdg_open, { buffer = true })
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = 'bsuth',
  callback = function()
    if vim.api.nvim_buf_get_option(0, 'filetype') == 'dirvish' then
      vim.cmd('Dirvish') -- refresh
    end
  end,
})
