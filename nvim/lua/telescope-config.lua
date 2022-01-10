local lfs = require('lfs')

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

map('n', '<leader><leader>', ':lua telescope_favorites()<cr>')
map('n', '<leader>fd', ':lua telescope_open()<cr>')
map('n', '<leader>rg', ':Telescope live_grep<cr>')
map('n', '<leader>buf', ':Telescope buffers<cr>')

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

local telescope_fd = {
  'fd',
  '--follow',
  '--type',
  'f',
  '--type',
  'd',
  '--exclude',
  'go',
  '--exclude',
  'bin',
}

local function telescope_edit_action(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  actions.close(prompt_bufnr)
  vim.cmd(('edit %s'):format(table.concat({
    current_picker.cwd or '.',
    action_state.get_selected_entry().value,
  }, '/')))
end

-- -----------------------------------------------------------------------------
-- Pickers
-- -----------------------------------------------------------------------------

function telescope_favorites()
  local opts = {}

  local favorites = { 'dots', 'repos' }
  local job = vim.tbl_flatten({
    telescope_fd,
    vim.tbl_flatten(vim.tbl_map(function(v)
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

function telescope_open()
  local opts = {}

  local function fd_finder(dir)
    return finders.new_oneshot_job(telescope_fd, { cwd = dir })
  end

  local function picker_cd(picker, dir)
    picker.cwd = dir
    picker:refresh(fd_finder(dir), { reset_prompt = true })
  end

  pickers.new(opts, {
    prompt_title = 'Open',
    finder = fd_finder(),
    sorter = config.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      local current_picker = action_state.get_current_picker(prompt_bufnr)
      action_set.select:replace(telescope_edit_action)

      map('i', '<c-i>', function()
        local newCwd = (current_picker.cwd or '.')
          .. '/'
          .. action_state.get_selected_entry()[1]

        local newCwdAttr = lfs.attributes(newCwd)
        if newCwdAttr and newCwdAttr.mode == 'file' then
          newCwd = newCwd:gsub('/[^/]*$', '')
        end

        picker_cd(current_picker, newCwd)
      end)

      map('i', '<c-o>', function()
        picker_cd(current_picker, (current_picker.cwd or '.') .. '/..')
      end)

      map('i', '<c-space>', function()
        actions.close(prompt_bufnr)
        vim.cmd('Dirvish ' .. current_picker.cwd)
      end)

      return true
    end,
  }):find()
end
