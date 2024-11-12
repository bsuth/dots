local nvim_feed_termcodes = require('lib.nvim').nvim_feed_termcodes
local nvim_get_line_column = require('lib.nvim').nvim_get_line_column
local string = require('lib.stdlib').string

-- -----------------------------------------------------------------------------
-- Variables
-- -----------------------------------------------------------------------------

local WORDCHARS = { _ = true }

for _, char in string.chars(os.getenv('WORDCHARS') or '') do
  WORDCHARS[char] = true
end

for byte = string.byte('0'), string.byte('9') do
  WORDCHARS[string.char(byte)] = true
end

for byte = string.byte('a'), string.byte('z') do
  WORDCHARS[string.char(byte)] = true
end

for byte = string.byte('A'), string.byte('Z') do
  WORDCHARS[string.char(byte)] = true
end

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

local function get_word_back_column(text, column)
  local next_char = text:sub(column - 1, column - 1)

  while column > 1 and not WORDCHARS[next_char] do
    column = column - 1
    next_char = text:sub(column - 1, column - 1)
  end

  while column > 1 and WORDCHARS[next_char] do
    column = column - 1
    next_char = text:sub(column - 1, column - 1)
  end

  return column
end

local function get_move_word_forward_column(text, column)
  local next_char = text:sub(column + 1, column + 1)

  while column < #text and WORDCHARS[next_char] do
    column = column + 1
    next_char = text:sub(column + 1, column + 1)
  end

  while column < #text and not WORDCHARS[next_char] do
    column = column + 1
    next_char = text:sub(column + 1, column + 1)
  end

  return column + 1
end

local function get_delete_word_forward_column(text, column)
  local next_char = text:sub(column + 1, column + 1)

  while column < #text and not WORDCHARS[next_char] do
    column = column + 1
    next_char = text:sub(column + 1, column + 1)
  end

  while column < #text and WORDCHARS[next_char] do
    column = column + 1
    next_char = text:sub(column + 1, column + 1)
  end

  return column + 1
end

local function move_word_back()
  if vim.fn.mode() == 'c' then
    local column = vim.fn.getcmdpos()
    local text = vim.fn.getcmdline()
    nvim_feed_termcodes(('<Left>'):rep(column - get_word_back_column(text, column)))
  else
    local line, column = nvim_get_line_column()
    local text = vim.fn.getline('.')
    vim.fn.setcharpos('.', { 0, line, get_word_back_column(text, column), 0 })
  end
end

local function move_word_forward()
  if vim.fn.mode() == 'c' then
    local column = vim.fn.getcmdpos()
    local text = vim.fn.getcmdline()
    nvim_feed_termcodes(('<Right>'):rep(get_move_word_forward_column(text, column) - column))
  else
    local line, column = nvim_get_line_column()
    local text = vim.fn.getline('.')
    vim.fn.setcharpos('.', { 0, line, get_move_word_forward_column(text, column), 0 })
  end
end

local function delete_char_back()
  local _, column = nvim_get_line_column()
  if vim.fn.mode() == 'c' or column > 1 then
    nvim_feed_termcodes('<BS>')
  end
end

local function delete_char_forward()
  local _, column = nvim_get_line_column()
  local text = vim.fn.getline('.')
  if vim.fn.mode() == 'c' or column <= #text then
    nvim_feed_termcodes('<Delete>')
  end
end

local function delete_word_back()
  if vim.fn.mode() == 'c' then
    local column = vim.fn.getcmdpos()
    local text = vim.fn.getcmdline()
    nvim_feed_termcodes(('<BS>'):rep(column - get_word_back_column(text, column)))
  else
    local line, column = nvim_get_line_column()
    local text = vim.fn.getline('.')
    local new_col = get_word_back_column(text, column)
    vim.fn.setline(line, text:sub(1, new_col - 1) .. text:sub(column))
    vim.fn.setcharpos('.', { 0, line, new_col, 0 })
  end
end

local function delete_word_forward()
  if vim.fn.mode() == 'c' then
    local column = vim.fn.getcmdpos()
    local text = vim.fn.getcmdline()
    nvim_feed_termcodes(('<Delete>'):rep(get_delete_word_forward_column(text, column) - column))
  else
    local line, column = nvim_get_line_column()
    local text = vim.fn.getline('.')
    local new_col = get_delete_word_forward_column(text, column)
    vim.fn.setline(line, text:sub(1, column - 1) .. text:sub(new_col))
  end
end

local function delete_line_back()
  if vim.fn.mode() == 'c' then
    nvim_feed_termcodes(('<BS>'):rep(vim.fn.getcmdpos()))
  else
    local line, column = nvim_get_line_column()
    local text = vim.fn.getline('.')
    vim.fn.setline(line, text:sub(column))
    vim.fn.setcharpos('.', { 0, line, 1, 0 })
  end
end

local function delete_line_forward()
  if vim.fn.mode() == 'c' then
    local column = vim.fn.getcmdpos()
    local text = vim.fn.getcmdline()
    nvim_feed_termcodes(('<Delete>'):rep(#text - column + 1))
  else
    local line, column = nvim_get_line_column()
    local text = vim.fn.getline('.')
    vim.fn.setline(line, text:sub(1, column - 1))
  end
end

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('i', '<c-b>', '<Left>')
vim.keymap.set('i', '<c-f>', '<Right>')
vim.keymap.set('i', '<c-a>', '<Home>')
vim.keymap.set('i', '<c-e>', '<End>')
vim.keymap.set('i', '<m-b>', move_word_back)
vim.keymap.set('i', '<m-f>', move_word_forward)
vim.keymap.set('i', '<c-h>', delete_char_back)
vim.keymap.set('i', '<c-d>', delete_char_forward)
vim.keymap.set('i', '<m-backspace>', delete_word_back)
vim.keymap.set('i', '<m-d>', delete_word_forward)
vim.keymap.set('i', '<c-u>', delete_line_back)
vim.keymap.set('i', '<c-k>', delete_line_forward)

vim.keymap.set('c', '<c-b>', '<Left>')
vim.keymap.set('c', '<c-f>', '<Right>')
vim.keymap.set('c', '<c-a>', '<Home>')
vim.keymap.set('c', '<c-e>', '<End>')
vim.keymap.set('c', '<m-b>', move_word_back)
vim.keymap.set('c', '<m-f>', move_word_forward)
vim.keymap.set('c', '<c-h>', delete_char_back)
vim.keymap.set('c', '<c-d>', delete_char_forward)
vim.keymap.set('c', '<m-backspace>', delete_word_back)
vim.keymap.set('c', '<m-d>', delete_word_forward)
vim.keymap.set('c', '<c-u>', delete_line_back)
vim.keymap.set('c', '<c-k>', delete_line_forward)
