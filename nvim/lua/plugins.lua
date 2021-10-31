-- -----------------------------------------------------------------------------
-- Packer
-- https://github.com/wbthomason/packer.nvim
-- -----------------------------------------------------------------------------

local packer_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(packer_path)) > 0 then
  fn.system({
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    packer_path,
  })
end

cmd('packadd packer.nvim')
require('packer').startup(function()
  -- core
  use('wbthomason/packer.nvim')
  use('nvim-lua/plenary.nvim')

  -- lsp, completion, formatter
  use('neovim/nvim-lspconfig')
  use('hrsh7th/nvim-cmp')
  use('hrsh7th/vim-vsnip')
  use('hrsh7th/vim-vsnip-integ')
  use('mhartington/formatter.nvim')

  -- completion sources
  use('hrsh7th/cmp-buffer')
  use('hrsh7th/cmp-path')
  use('hrsh7th/cmp-nvim-lsp')
  use('hrsh7th/cmp-vsnip')

  -- syntax
  use('nvim-treesitter/nvim-treesitter')
  use('navarasu/onedark.nvim')

  -- apps
  use('justinmk/vim-dirvish')
  use('hoob3rt/lualine.nvim')
  use('nvim-telescope/telescope.nvim')
  use({ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' })

  -- util
  use('tpope/vim-surround')
  use('tpope/vim-commentary')
  use('matze/vim-move')
  use('lambdalisue/suda.vim')

  -- Local plugins can be included
  use('~/repos/vim-erde')
end)

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
-- https://github.com/hoob3rt/lualine.nvim
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
-- https://github.com/nvim-treesitter/nvim-treesitter
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
-- LSP Completion
-- https://github.com/hrsh7th/nvim-cmp/
-- -----------------------------------------------------------------------------

local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      fn['vsnip#anonymous'](args.body)
    end,
  },
  mapping = {
    ['<c-d>'] = cmp.mapping.scroll_docs(-4),
    ['<c-f>'] = cmp.mapping.scroll_docs(4),
    ['<c-Space>'] = cmp.mapping.complete(),
    -- ['<c-c>'] = cmp.mapping.close(),
    -- ['<cr>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
})

-- -----------------------------------------------------------------------------
-- LSP Config
-- https://github.com/neovim/nvim-lspconfig
-- -----------------------------------------------------------------------------

local lspconfig = require('lspconfig')
local lspCapabilities = require('cmp_nvim_lsp').update_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)

local lspServers = {
  clangd = {},
  cssls = {},
  graphql = {},
  gopls = {},
  jsonls = {
    filetypes = { 'json', 'jsonc' },
    settings = {
      json = {
        -- https://www.schemastore.org
        schemas = {
          {
            fileMatch = { 'package.json' },
            url = 'https://json.schemastore.org/package.json',
          },
          {
            fileMatch = { 'tsconfig*.json' },
            url = 'https://json.schemastore.org/tsconfig.json',
          },
          {
            fileMatch = {
              '.prettierrc',
              '.prettierrc.json',
              'prettier.config.json',
            },
            url = 'https://json.schemastore.org/prettierrc.json',
          },
          {
            fileMatch = { '.eslintrc', '.eslintrc.json' },
            url = 'https://json.schemastore.org/eslintrc.json',
          },
          {
            fileMatch = { '.babelrc', '.babelrc.json', 'babel.config.json' },
            url = 'https://json.schemastore.org/babelrc.json',
          },
        },
      },
    },
  },
  tsserver = {},
}

for server, config in pairs(lspServers) do
  lspconfig[server].setup(vim.tbl_deep_extend('force', {
    capabilities = lspCapabilities,
  }, config))
end

-- -----------------------------------------------------------------------------
-- Formatter
-- https://github.com/mhartington/formatter.nvim
-- -----------------------------------------------------------------------------

local formatter = require('formatter')

function prettierFormatter()
  return {
    exe = 'prettierd',
    args = { nvim_buf_get_name(0) },
    stdin = true,
  }
end

formatter.setup({
  filetype = {
    javascript = { prettierFormatter },
    javascriptreact = { prettierFormatter },
    typescript = { prettierFormatter },
    typescriptreact = { prettierFormatter },
    css = { prettierFormatter },
    scss = { prettierFormatter },
  },
})

-- -----------------------------------------------------------------------------
-- Telescope
-- https://github.com/nvim-telescope/telescope.nvim
-- -----------------------------------------------------------------------------

local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local config = require('telescope.config').values
local actions = require('telescope.actions')
local action_set = require('telescope.actions.set')
local action_state = require('telescope.actions.state')

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ['<c-space>'] = actions.toggle_selection,
        ['<m-space>'] = actions.send_selected_to_qflist + actions.open_qflist,
      },
      n = {
        ['<c-space>'] = actions.toggle_selection,
        ['<m-space>'] = actions.send_selected_to_qflist + actions.open_qflist,
      },
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

  local favorites = { 'dots', 'repos' }
  local job = tbl_flatten({
    fd,
    tbl_flatten(tbl_map(function(v)
      return { '--search-path', v }
    end, favorites)),
  })

  pickers.new(opts, {
    prompt_title = 'Favorites',
    cwd = os.getenv('HOME'),
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
