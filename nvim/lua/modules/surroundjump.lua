local nvim_get_position = require('lib.nvim').nvim_get_position

-- -----------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------

local OPEN_SURROUND_CHARS = {
  ['('] = true,
  ['{'] = true,
  ['['] = true,
}

local CLOSE_SURROUND_CHARS = {
  [')'] = true,
  ['}'] = true,
  [']'] = true,
}

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

---@param line number
---@param column number
local function cursor_jump(line, column)
  -- use `lineGcol|` over `setcursorcharpos` so we can push to the jumplist
  vim.cmd(("normal %dG%d|"):format(line, column))
end

---@return string
local function get_cursor_char()
  local line, column = nvim_get_position()
  return vim.fn.getline(line):sub(column, column)
end

---@return fun(): number, number, string
local function prev_chars()
  local line, column = nvim_get_position()
  local text = vim.fn.getline(line)

  return function()
    if column > 1 then
      column = column - 1
      return line, column, text:sub(column, column)
    elseif line > 1 then
      line = line - 1
      text = vim.fn.getline(line)
      column = #text
      return line, column, text:sub(column, column)
    end
  end
end

---@return fun(): number, number, string
local function next_chars()
  local line, column = nvim_get_position()
  local text = vim.fn.getline(line)
  local line_limit, column_limit = vim.fn.line('$'), #text

  return function()
    if column < column_limit then
      column = column + 1
      return line, column, text:sub(column, column)
    elseif line < line_limit then
      line = line + 1
      text = vim.fn.getline(line)
      column, column_limit = 1, #text
      return line, column, text:sub(column, column)
    end
  end
end

local function deep_surround_jump_back()
  for line, column, char in prev_chars() do
    if OPEN_SURROUND_CHARS[char] or CLOSE_SURROUND_CHARS[char] then
      cursor_jump(line, column)
      return
    end
  end
end

local function shallow_surround_jump_back()
  if CLOSE_SURROUND_CHARS[get_cursor_char()] then
    vim.cmd('normal %')
  else
    deep_surround_jump_back()
  end
end

local function deep_surround_jump_forward()
  for line, column, char in next_chars() do
    if OPEN_SURROUND_CHARS[char] or CLOSE_SURROUND_CHARS[char] then
      cursor_jump(line, column)
      return
    end
  end
end

local function shallow_surround_jump_forward()
  if OPEN_SURROUND_CHARS[get_cursor_char()] then
    vim.cmd('normal %')
  else
    deep_surround_jump_forward()
  end
end

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '{', deep_surround_jump_back)
vim.keymap.set('v', '{', deep_surround_jump_back)
vim.keymap.set('n', '}', deep_surround_jump_forward)
vim.keymap.set('v', '}', deep_surround_jump_forward)

vim.keymap.set('n', '(', shallow_surround_jump_back)
vim.keymap.set('v', '(', shallow_surround_jump_back)
vim.keymap.set('n', ')', shallow_surround_jump_forward)
vim.keymap.set('v', ')', shallow_surround_jump_forward)
