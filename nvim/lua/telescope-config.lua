local lfs = require('lfs')

-- -----------------------------------------------------------------------------
-- Telescope
-- https://github.com/nvim-telescope/telescope.nvim
-- -----------------------------------------------------------------------------

local telescope = require('telescope')
local from_entry = require('telescope.from_entry')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local config = require('telescope.config').values
local actions = require('telescope.actions')
local actionSet = require('telescope.actions.set')
local actionState = require('telescope.actions.state')

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

map('n', '<leader><leader>', ':lua telescopeFavorites()<cr>')
map('n', '<leader>fd', ':lua telescopeFd()<cr>')
map('n', '<leader>cd', ':lua telescopeCd()<cr>')
map('n', '<leader>rg', ':Telescope grep_string search=<cr>')
map('n', '<leader>buf', ':Telescope buffers<cr>')

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
  }):find()
end

-- -----------------------------------------------------------------------------
-- Pickers
-- -----------------------------------------------------------------------------

function telescopeFavorites()
  local home = os.getenv('HOME')
  local favorites = { 'dots', 'repos' }

  local job = newTelescopeFdJob({ '--type', 'd' })
  for i, favorite in pairs(favorites) do
    job[#job + 1] = '--search-path'
    job[#job + 1] = favorite
  end

  telescopeRun(home, job, { prompt_title = 'Favorites' })
end

function telescopeFd()
  local job = newTelescopeFdJob({ '--type', 'f' })
  telescopeRun('.', job, { prompt_title = 'fd' })
end

function telescopeCd()
  local job = newTelescopeFdJob({ '--type', 'd' })
  telescopeRun('.', job, { prompt_title = 'cd' })
end
