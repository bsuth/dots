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
  nvim_command('autocmd VimEnter * source $MYVIMRC | PaqSync | source $MYVIMRC')
else
  io.close(paqfile)
end

-- prevent netrw from taking over:
-- https://github.com/justinmk/vim-dirvish/issues/137
nvim_set_var('loaded_netrwPlugin', true)

require('paq')({
  -- paq
  'savq/paq-nvim',

  -- stable
  'navarasu/onedark.nvim',
  'justinmk/vim-dirvish',
  'tpope/vim-surround',
  'matze/vim-move',
  'lambdalisue/suda.vim',

  -- unstable
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
  'tpope/vim-commentary',
  -- 'itchyny/lightline.vim',
  'nvim-treesitter/nvim-treesitter',
  'hoob3rt/lualine.nvim',
})

-- -----------------------------------------------------------------------------
-- Vim-Plug
-- -----------------------------------------------------------------------------

local plug =
  io.open(os.getenv('HOME') .. '/.config/nvim/autoload/plug.vim', 'r')

if plug == nil then
  os.execute([[
		curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	]])
  nvim_command('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
else
  io.close(plug)
end

local plugins = {
  'junegunn/fzf',
  { [[ 'neoclide/coc.nvim', {'branch': 'release'}  ]] },
}

nvim_call_function('plug#begin', { '~/.config/nvim/bundle' })
for _, plugin in ipairs(plugins) do
  if type(plugin) == 'string' then
    nvim_command(([[ Plug '%s' ]]):format(plugin))
  elseif type(plugin) == 'table' then
    nvim_command('Plug ' .. plugin[1])
  end
end
nvim_call_function('plug#end', {})

-- -----------------------------------------------------------------------------
-- Misc
-- -----------------------------------------------------------------------------

nvim_set_var('suda_smart_edit', true)
nvim_command('colorscheme onedark')

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
-- Coc
-- -----------------------------------------------------------------------------

nvim_set_var('coc_global_extensions', {
  'coc-tsserver',
  'coc-css',
  'coc-json',
  'coc-prettier',
  'coc-clangd',
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

function mypick()
  require('telescope.pickers').new({}, {
    prompt_title = 'Change Directory',
    finder = require('telescope.finders').new_oneshot_job({
      'fd',
      '--follow',
      '--type',
      'd',
    }),
    sorter = require('telescope.sorters').fuzzy_with_index_bias(),
  }):find()
end
