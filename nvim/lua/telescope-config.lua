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
