--
-- Lua Environment
-- 1) expose vim.api to global scope
-- 2) expose utils
--

for k, v in pairs(vim.api) do
  if type(v) == 'function' and k:match('^nvim_') then
    _G[k] = v
  end
end

--
-- Modules
--

local modules = {
  'plugins',
  'helpers',
  'fzf',
  'mappings',
}

for _, v in ipairs(modules) do
  package.loaded[v] = nil
  require(v)
end

--
-- Options
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
  showmode = false, -- replaced by lightline
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
-- Autogroups
--

nvim_command('augroup bsuth')

-- CWD Tracking
nvim_command('au TermOpen term://*zsh* lua save_cwd()')
nvim_command('au TermClose term://*zsh* lua restore_cwd()')
nvim_command('au BufEnter * lua track_cwd()')

-- Dirvish
nvim_command('au TermClose term://*zsh* Dirvish')
nvim_command('au FileType dirvish nnoremap <buffer><silent> <cr> :lua dirvish_xdg_open()<cr>')

-- Term
nvim_command('au TermOpen term://*zsh* setlocal nonumber wrap')
nvim_command('au TermOpen term://*zsh* startinsert')

-- Misc
nvim_command('au BufWritePost *.lua lua apply_stylua()')

nvim_command('augroup END')
