-- -----------------------------------------------------------------------------
-- Paq
-- -----------------------------------------------------------------------------

local paqpath = os.getenv('HOME')
  .. '/.local/share/nvim/site/pack/paqs/start/paq-nvim'

local paqfile = io.open(paqpath)
if paqfile == nil then
  os.execute(([[
    git clone --depth=1 https://github.com/savq/paq-nvim.git %s
	]]):format(paqpath))
  cmd('autocmd VimEnter * source $MYVIMRC | PaqSync | source $MYVIMRC')
else
  io.close(paqfile)
end

require('paq')({
  -- core
  'savq/paq-nvim',
  'nvim-lua/plenary.nvim',

  -- syntax
  'nvim-treesitter/nvim-treesitter',
  'navarasu/onedark.nvim',

  -- apps
  'justinmk/vim-dirvish',
  'hoob3rt/lualine.nvim',
  'nvim-telescope/telescope.nvim',
  { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },

  -- util
  'tpope/vim-surround',
  'tpope/vim-commentary',
  'matze/vim-move',
  'lambdalisue/suda.vim',
})

-- -----------------------------------------------------------------------------
-- Misc
-- -----------------------------------------------------------------------------

-- prevent netrw from taking over:
-- https://github.com/justinmk/vim-dirvish/issues/137
g.loaded_netrwPlugin = true

g.suda_smart_edit = true
cmd('colorscheme onedark')

-- -----------------------------------------------------------------------------
-- Lualine
-- -----------------------------------------------------------------------------

-- Lualine dissapears on rc reload unless we unload it completely before
-- calling setup. Fixed but awaiting merge. Track here:
-- https://github.com/hoob3rt/lualine.nvim/issues/276
require('plenary.reload').reload_module('lualine', true)

require('lualine').setup({
  options = {
    icons_enabled = false,
    theme = 'onedark',
  },

  sections = {
    lualine_x = {},
  },
})

-- -----------------------------------------------------------------------------
-- Treesitter
-- -----------------------------------------------------------------------------

require('nvim-treesitter.configs').setup({
  ensure_installed = 'maintained',
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = '<M-p>',
      node_decremental = '<M-n>',
    },
  },
  highlight = {
    enable = true,
  },
})

-- -----------------------------------------------------------------------------
-- Telescope
-- -----------------------------------------------------------------------------

local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local config = require('telescope.config').values
local actions = require('telescope.actions')
local action_set = require('telescope.actions.set')
local action_state = require('telescope.actions.state')

--
-- Setup
--

telescope.setup({
  extensions = {
    fzf = {
      fuzzy = false,
    },
  },
})

telescope.load_extension('fzf')

--
-- Helpers
--

local fd = { 'fd', '--follow', '--type', 'd' }

local function telescope_edit_action(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  actions.close(prompt_bufnr)
  cmd(('edit %s'):format(table.concat({
    current_picker.cwd or '.',
    action_state.get_selected_entry().value,
  }, '/')))
end

--
-- Picker: Favorites
--

function telescope_favorites()
  local opts = {}

  local favorites = { 'dots', 'projects' }
  local job = tbl_flatten({
    fd,
    tbl_flatten(tbl_map(function(v)
      return { '--search-path', v }
    end, favorites)),
  })

  pickers.new(opts, {
    prompt_title = 'Favorites',
    finder = finders.new_oneshot_job(job, { cwd = os.getenv('HOME') }),
    sorter = config.generic_sorter(opts),
    attach_mappings = function(_, map)
      action_set.select:replace(telescope_edit_action)
      return true
    end,
  }):find()
end

--
-- Picker: Change Directory
--

function telescope_change_dir()
  local opts = {}

  local function cwd_tree_finder(cwd)
    return finders.new_oneshot_job(fd, { cwd = cwd })
  end

  pickers.new(opts, {
    prompt_title = 'Change Directory',
    finder = cwd_tree_finder(),
    sorter = config.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      local current_picker = action_state.get_current_picker(prompt_bufnr)
      action_set.select:replace(telescope_edit_action)
      map('i', '<c-b>', function()
        local cwd = table.concat({ '..', current_picker.cwd }, '/')
        current_picker.cwd = cwd
        current_picker:refresh(cwd_tree_finder(cwd), { reset_prompt = true })
      end)
      return true
    end,
  }):find()
end

-- -----------------------------------------------------------------------------
-- DEPRECATED: Vim-Plug + Coc
-- -----------------------------------------------------------------------------

local plug =
  io.open(os.getenv('HOME') .. '/.config/nvim/autoload/plug.vim', 'r')

if plug == nil then
  os.execute([[
		curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	]])
  cmd('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
else
  io.close(plug)
end

local plugins = {
  { [[ 'neoclide/coc.nvim', {'branch': 'release'}  ]] },
}

nvim_call_function('plug#begin', { '~/.config/nvim/bundle' })
for _, plugin in ipairs(plugins) do
  if type(plugin) == 'string' then
    cmd(([[ Plug '%s' ]]):format(plugin))
  elseif type(plugin) == 'table' then
    cmd('Plug ' .. plugin[1])
  end
end
nvim_call_function('plug#end', {})

nvim_set_var('coc_global_extensions', {
  'coc-tsserver',
  'coc-css',
  'coc-json',
  'coc-prettier',
  'coc-clangd',
})
