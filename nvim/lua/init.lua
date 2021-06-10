--
-- lua env
-- 1) expose vim.api to global scope
-- 2) expose utils
--

for k, v in pairs(vim.api) do
  if type(v) == 'function' and k:match('^nvim_') then
    _G[k] = v
  end
end

ANSI = {
  RESET = string.char(27) .. '[0m',
  BLACK = string.char(27) .. '[30m',
  RED = string.char(27) .. '[31m',
  GREEN = string.char(27) .. '[32m',
  YELLOW = string.char(27) .. '[33m',
  BLUE = string.char(27) .. '[34m',
  MAGENTA = string.char(27) .. '[35m',
  CYAN = string.char(27) .. '[36m',
  WHITE = string.char(27) .. '[37m',
}

function colorize(s, color)
  return color .. s .. ANSI.RESET
end

--
-- packages
--

local packages = {
  'plugins',
  'helpers',
  'fzf',
  'mappings',
}

for _, v in ipairs(packages) do
  package.loaded[v] = nil
  require(v)
end

--
-- options
--

local global_options = {
  wrap = false,
  ignorecase = true,
  smartcase = true,
  splitright = true,
  splitbelow = true,
  termguicolors = true,
  tabstop = 2,
  softtabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  clipboard = 'unnamedplus',
  scrollback = 100000,
  updatetime = 300,
  suffixes = '.bak,~,.o,.info,.swp,.obj',
}

local window_options = {
  number = true,
  colorcolumn = '80',
  signcolumn = 'yes',
}

local buffer_options = {}

for k, v in pairs(global_options) do
  nvim_set_option(k, v)
end

for k, v in pairs(window_options) do
  nvim_win_set_option(0, k, v)
end

for k, v in pairs(buffer_options) do
  nvim_buf_set_option(0, k, v)
end

nvim_command('highlight ColorColumn guibg=#585858')

--
-- augroups
--

nvim_command('augroup bsuth')
nvim_command('au BufEnter * lua on_bufenter()')
nvim_command('au TermOpen term://*zsh* setlocal nonumber wrap')
nvim_command('au TermOpen term://*zsh* startinsert')
nvim_command('au TermClose term://*zsh* Dirvish')
nvim_command('au FileType dirvish nnoremap <buffer><silent> <cr> :lua dirvish_open()<cr>')
nvim_command('au BufWritePost *.lua lua apply_stylua()')
nvim_command('augroup END')
