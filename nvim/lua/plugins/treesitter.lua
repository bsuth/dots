local plugins = require('lib.plugins')

plugins.use('nvim-treesitter/nvim-treesitter')
plugins.use('nvim-treesitter/nvim-treesitter-textobjects')

-- -----------------------------------------------------------------------------
-- Setup
-- -----------------------------------------------------------------------------

require('nvim-treesitter.configs').setup({
  auto_install = true,
  sync_install = false,
  ignore_install = {},
  ensure_installed = {},

  modules = {},
  highlight = { enable = true },

  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@conditional.outer",
        ["ic"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
      },
    },

    move = {
      enable = true,
      set_jumps = true,
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[c"] = "@conditional.outer",
        ["[l"] = "@loop.outer",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[C"] = "@conditional.outer",
        ["[L"] = "@loop.outer",
      },
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]c"] = "@conditional.outer",
        ["]l"] = "@loop.outer",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
        ["]C"] = "@conditional.outer",
        ["]L"] = "@loop.outer",
      },
    },
  },
})
