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
map('n', '<leader>fd', ':lua telescopeOpen()<cr>')
map('n', '<leader>rg', ':Telescope grep_string search=<cr>')
map('n', '<leader>buf', ':Telescope buffers<cr>')

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

local telescopeFd = {
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

local function fdPicker(root, opts)
  local cwd = root

  local function fdFinder()
    return finders.new_oneshot_job(telescopeFd, { cwd = cwd })
  end

  local function refreshPicker(picker)
    picker.cwd = cwd
    picker:refresh(fdFinder(), { reset_prompt = true })
  end

  -- Telescope gives us no way to set the current dir of previewers so we have
  -- to create our own previewer
  local previewer = previewers.new_buffer_previewer({
    define_preview = function(self, entry, status)
      local relpath = from_entry.path(entry, true)
      if relpath == nil or relpath == '' then
        return
      end

      config.buffer_previewer_maker(cwd .. '/' .. relpath, self.state.bufnr, {
        bufname = self.state.bufname,
        winid = self.state.winid,
      })
    end,
  })

  return pickers.new(opts, {
    finder = fdFinder(),
    previewer = previewer,
    sorter = config.generic_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      local currentPicker = actionState.get_current_picker(prompt_bufnr)

      actionSet.select:replace(function()
        local selection = actionState.get_selected_entry().value
        actions.close(prompt_bufnr)
        vim.cmd('edit ' .. cwd .. '/' .. selection)
      end)

      map('i', '<c-i>', function()
        cwd = cwd .. '/' .. actionState.get_selected_entry()[1]

        local cwdAttr = lfs.attributes(cwd)
        if cwdAttr and cwdAttr.mode == 'file' then
          cwd = cwd:gsub('/[^/]*$', '')
        end

        refreshPicker(currentPicker)
      end)

      map('i', '<c-o>', function()
        cwd = cwd .. '/..'
        refreshPicker(currentPicker)
      end)

      map('i', '<c-space>', function()
        actions.close(prompt_bufnr)
        vim.cmd('Dirvish ' .. cwd)
      end)

      return true
    end,
  })
end

-- -----------------------------------------------------------------------------
-- Pickers
-- -----------------------------------------------------------------------------

function telescopeFavorites()
  local home = os.getenv('HOME')
  local favorites = { 'dots', 'repos' }

  fdPicker(home, {
    prompt_title = 'Favorites',
    finder = finders.new_oneshot_job(
      vim.tbl_flatten({
        telescopeFd,
        vim.tbl_flatten(vim.tbl_map(function(value)
          return { '--search-path', value }
        end, favorites)),
      }),
      { cwd = home }
    ),
  }):find()
end

function telescopeOpen()
  fdPicker('.', { prompt_title = 'Open' }):find()
end
