local C = require('constants')

-- -----------------------------------------------------------------------------
-- Telescope
-- https://github.com/nvim-telescope/telescope.nvim
-- -----------------------------------------------------------------------------

local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local config = require('telescope.config').values
local actions = require('telescope.actions')
local actionSet = require('telescope.actions.set')
local actionState = require('telescope.actions.state')

telescope.setup({
  defaults = {
    layout_strategy = 'flex',
    layout_config = {
      flex = {
        flip_columns = 120,
      },
    },
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
  pickers = {
    buffers = {
      mappings = {
        i = {
          ['<c-q>'] = actions.delete_buffer,
        },
        n = {
          ['<c-q>'] = actions.delete_buffer,
        },
      },
    },
  },
})

telescope.load_extension('fzf')

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

local function newTelescopeFdJob(fdFlags)
  return vim.list_extend({
    'fd',
    '--follow',
    '--exclude',
    'go',
    '--exclude',
    'bin',
  }, fdFlags)
end

local function telescopeRun(cwd, job, opts)
  return pickers.new(opts, {
    finder = finders.new_oneshot_job(job, { cwd = cwd }),
    previewer = previewers.vim_buffer_cat.new({ cwd = cwd }),
    sorter = config.generic_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      local currentPicker = actionState.get_current_picker(prompt_bufnr)

      -- Default select does not consider cwd from finder
      actionSet.select:replace(function()
        local selection = actionState.get_selected_entry().value
        actions.close(prompt_bufnr)
        vim.cmd('edit ' .. cwd .. '/' .. selection)
      end)

      return true
    end,
  }):find()
end

-- -----------------------------------------------------------------------------
-- Pickers
-- -----------------------------------------------------------------------------

local function telescopeFavorites()
  local home = os.getenv('HOME')
  telescopeRun(home, { C.FD_FAVORITES_PATH }, { prompt_title = 'Favorites' })
end

local function telescopeFd()
  local job = newTelescopeFdJob({ '--type', 'f' })
  telescopeRun('.', job, { prompt_title = 'fd' })
end

local function telescopeCd()
  local job = newTelescopeFdJob({ '--type', 'd' })
  telescopeRun('.', job, { prompt_title = 'cd' })
end

-- -----------------------------------------------------------------------------
-- Mappings
-- -----------------------------------------------------------------------------

vim.keymap.set('n', '<leader><leader>', telescopeFavorites)
vim.keymap.set('n', '<leader>fd', telescopeFd)
vim.keymap.set('n', '<leader>cd', telescopeCd)
vim.keymap.set('n', '<leader>rg', ':Telescope grep_string only_sort_text=true search=<cr>')
vim.keymap.set('n', '<leader>buf', ':Telescope buffers<cr>')
vim.keymap.set('n', '<leader>ma', ':Telescope marks<cr>')
