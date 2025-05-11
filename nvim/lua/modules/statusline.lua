local onedark = require('lib.onedark')

-- -----------------------------------------------------------------------------
-- Highlight
-- -----------------------------------------------------------------------------

local highlight_name_counter = 1
local highlight_groups = {}

local function highlight(config)
  local highlight_name = 'bsuth_statusline_highlight_' .. highlight_name_counter
  highlight_name_counter = highlight_name_counter + 1
  highlight_groups[highlight_name] = config
  return highlight_name
end

vim.api.nvim_create_autocmd('SourcePost', {
  group = 'bsuth',
  callback = function()
    for name, config in pairs(highlight_groups) do
      -- need to wait until VimEnter to setup our custom highlights
      vim.api.nvim_set_hl(0, name, config)
    end
  end,
})

-- -----------------------------------------------------------------------------
-- Mode
-- -----------------------------------------------------------------------------

local MODE_CONFIG = {
  {
    label = 'NORMAL',
    modes = { 'n', 'no', 'nov', 'noV', 'no', 'niI', 'niR', 'niV', 'nt', 'ntT' },
    highlight = highlight({ fg = onedark.black, bg = onedark.light_grey, bold = true }),
  },
  {
    label = 'VISUAL',
    modes = { 'v', 'vs' },
    highlight = highlight({ fg = onedark.black, bg = onedark.purple, bold = true }),
  },
  {
    label = 'VISUAL LINE',
    modes = { 'V', 'Vs' },
    highlight = highlight({ fg = onedark.black, bg = onedark.purple, bold = true }),
  },
  {
    label = 'VISUAL BLOCK',
    modes = { '', 's' },
    highlight = highlight({ fg = onedark.black, bg = onedark.purple, bold = true }),
  },
  {
    label = 'SELECT',
    modes = { 's' },
    highlight = highlight({ fg = onedark.black, bg = onedark.purple, bold = true }),
  },
  {
    label = 'SELECT LINE',
    modes = { 'S' },
    highlight = highlight({ fg = onedark.black, bg = onedark.purple, bold = true }),
  },
  {
    label = 'SELECT BLOCK',
    modes = { '' },
    highlight = highlight({ fg = onedark.black, bg = onedark.purple, bold = true }),
  },
  {
    label = 'INSERT',
    modes = { 'i', 'ic', 'ix' },
    highlight = highlight({ fg = onedark.black, bg = onedark.green, bold = true }),
  },
  {
    label = 'REPLACE',
    modes = { 'R', 'Rc', 'Rx' },
    highlight = highlight({ fg = onedark.black, bg = onedark.red, bold = true }),
  },
  {
    label = 'VIRTUAL REPLACE',
    modes = { 'Rv', 'Rvc', 'Rvx' },
    highlight = highlight({ fg = onedark.black, bg = onedark.red, bold = true }),
  },
  {
    label = 'COMMAND',
    modes = { 'c' },
    highlight = highlight({ fg = onedark.black, bg = onedark.blue, bold = true }),
  },
  {
    label = 'EX',
    modes = { 'cv' },
    highlight = highlight({ fg = onedark.black, bg = onedark.blue, bold = true }),
  },
  {
    label = 'PROMPT',
    modes = { 'r', 'rm', 'r?' },
    highlight = highlight({ fg = onedark.black, bg = onedark.red, bold = true }),
  },
  {
    label = 'SHELL',
    modes = { '!' },
    highlight = highlight({ fg = onedark.black, bg = onedark.red, bold = true }),
  },
  {
    label = 'TERMINAL',
    modes = { 't' },
    highlight = highlight({ fg = onedark.black, bg = onedark.yellow, bold = true }),
  },
}

local MODE_CONFIG_LOOKUP = {}

for _, config in pairs(MODE_CONFIG) do
  for _, mode in ipairs(config.modes) do
    MODE_CONFIG_LOOKUP[mode] = config
  end
end

--- @return string
local function statusline_mode()
  local mode = vim.api.nvim_get_mode().mode
  local config = MODE_CONFIG_LOOKUP[mode]
  return ("%%#%s# %s %%#Normal#"):format(config.highlight, config.label)
end

-- -----------------------------------------------------------------------------
-- Buffer State
-- -----------------------------------------------------------------------------

local BUFFER_STATE_CONFIG = {
  {
    label = '[-]',
    highlight = highlight({ fg = onedark.red, bold = true }),
    qualifier = function()
      return not vim.api.nvim_get_option_value('modifiable', { buf = 0 })
    end,
  },
  {
    label = '[RO]',
    highlight = highlight({ fg = onedark.yellow, bold = true }),
    qualifier = function()
      return vim.api.nvim_get_option_value('readonly', { buf = 0 })
    end,
  },
  {
    label = '[+]',
    highlight = highlight({ fg = onedark.blue, bold = true }),
    qualifier = function()
      return vim.api.nvim_get_option_value('modified', { buf = 0 })
    end,
  },
}

--- @return string
local function statusline_buffer_state()
  for _, config in ipairs(BUFFER_STATE_CONFIG) do
    if config.qualifier() then
      return ("%%#%s# %s %%#Normal#"):format(config.highlight, config.label)
    end
  end

  return ''
end

-- -----------------------------------------------------------------------------
-- LSP
-- -----------------------------------------------------------------------------

local LSP_CONFIG = {
  {
    severity = vim.diagnostic.severity.HINT,
    highlight = highlight({ fg = onedark.dark_purple, bold = true }),
  },
  {
    severity = vim.diagnostic.severity.INFO,
    highlight = highlight({ fg = onedark.dark_cyan, bold = true }),
  },
  {
    severity = vim.diagnostic.severity.WARN,
    highlight = highlight({ fg = onedark.dark_yellow, bold = true }),
  },
  {
    severity = vim.diagnostic.severity.ERROR,
    highlight = highlight({ fg = onedark.dark_red, bold = true }),
  },
}

--- @return string
local function statusline_lsp()
  local statusline = {}

  for _, config in ipairs(LSP_CONFIG) do
    local count = #vim.diagnostic.get(0, { severity = config.severity })

    if count > 0 then
      table.insert(statusline, ("%%#%s#[%d]%%#Normal#"):format(
        config.highlight,
        count
      ))
    end
  end

  return ' ' .. table.concat(statusline, ' ') .. ' '
end

-- -----------------------------------------------------------------------------
-- Filetype
-- -----------------------------------------------------------------------------

local FILETYPE_HIGHLIGHT = highlight({
  fg = onedark.black,
  bg = onedark.purple,
  bold = true,
})

local FILETYPE_GETTERS = {
  function() return vim.api.nvim_get_option_value('filetype', { buf = 0 }) end,
  function() return vim.api.nvim_get_option_value('buftype', { buf = 0 }) end,
  function() return vim.api.nvim_get_option_value('syntax', { buf = 0 }) end,
  function() return '???' end,
}

--- @return string
local function statusline_filetype()
  for _, filetype_getter in ipairs(FILETYPE_GETTERS) do
    local filetype = filetype_getter()

    if filetype ~= '' then
      return ("%%#%s# %s %%#Normal#"):format(
        FILETYPE_HIGHLIGHT,
        string.upper(filetype)
      )
    end
  end
end

-- -----------------------------------------------------------------------------
-- Cursor
-- -----------------------------------------------------------------------------

local CURSOR_HIGHLIGHT = highlight({
  fg = onedark.black,
  bg = onedark.blue,
  bold = true,
})

--- @return string
local function statusline_cursor()
  return ("%%#%s# %%l/%%L %%#Normal#"):format(CURSOR_HIGHLIGHT)
end

-- -----------------------------------------------------------------------------
-- Statusline
-- -----------------------------------------------------------------------------

--- @return string
function STATUSLINE()
  return table.concat({
    statusline_mode(),
    ' %F',
    statusline_buffer_state(),
    '%=',
    statusline_lsp(),
    statusline_cursor(),
    statusline_filetype(),
  })
end

vim.opt.statusline = "%!v:lua.STATUSLINE()"
