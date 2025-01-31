local root_commands = require('commander.commands')
local nvim_buf_keymap = require('lib.nvim').nvim_buf_keymap
local nvim_feed_termcodes = require('lib.nvim').nvim_feed_termcodes
local string = require('lib.stdlib').string
local table = require('lib.stdlib').table
local onedark = require('lib.onedark')

local MAX_WINDOW_HEIGHT = 16

local NAMESPACE_ID = vim.api.nvim_create_namespace('')
vim.api.nvim_set_hl(NAMESPACE_ID, 'OverflowEllipses', { fg = onedark.grey })
vim.api.nvim_set_hl(NAMESPACE_ID, 'FocusedIndex', { fg = onedark.cyan })

local Commander = {}

-- -----------------------------------------------------------------------------
-- Methods
-- -----------------------------------------------------------------------------

function Commander:refresh()
  local head = self.path[#self.path]
  self.raw_commands = head.generator()

  if vim.api.nvim_get_mode().mode ~= 'i' then
    self.ignore_next_mode_changes = self.ignore_next_mode_changes + 1
    vim.cmd('startinsert!')
  end

  vim.schedule(function() -- use `vim.schedule` to properly detect insert mode
    vim.api.nvim_buf_set_lines(self.buffer, -2, -1, false, { '' })

    -- Manually trigger the first lazy filter, since we do not filter
    -- automatically on buffer change for lazy commands.
    if head.lazy then
      self:filter()
    end
  end)
end

function Commander:filter()
  local text = string.trim(vim.api.nvim_buf_get_lines(self.buffer, -2, -1, false)[1])
  local head = self.path[#self.path]

  if text == '' then
    self.commands = self.raw_commands
    self.num_commands = #self.commands
    self:render()
    return
  elseif head.lazy then
    self.commands = head.generator(text)
    self.num_commands = #self.commands
    self:render()
    return
  end

  self.commands = {}
  self.num_commands = 0

  local tokens = table.map(string.split(text), function(token)
    return {
      raw = token,
      pattern = string.escape(token),
      case_sensitive = token:find('[A-Z]'),
    }
  end)

  for _, command in ipairs(self.raw_commands) do
    local command_label_lower = command.label:lower()

    local is_valid_command = not table.find(tokens, function(token)
      local label = token.case_sensitive and command.label or command_label_lower
      return not label:find(token.pattern)
    end)

    if is_valid_command then
      self.num_commands = self.num_commands + 1
      self.commands[self.num_commands] = command
    end
  end

  self:render()
end

function Commander:render()
  local window_height = math.min(
    self.num_commands + 1, -- + 1 for prompt
    math.floor(0.4 * vim.api.nvim_win_get_height(self.parent_window)),
    MAX_WINDOW_HEIGHT
  )

  vim.api.nvim_win_set_height(self.window, window_height)

  local mode = vim.api.nvim_get_mode().mode
  local has_overflow = mode == 'i' and self.num_commands + 1 > window_height

  local new_buffer_lines = {}

  for i = 1, has_overflow and window_height - 2 or self.num_commands do
    table.insert(new_buffer_lines, self.commands[i].label)
  end

  if has_overflow then
    table.insert(new_buffer_lines, '...')
  end

  table.reverse(new_buffer_lines) -- reverse the buffer lines since our prompt is at the bottom

  self.ignore_next_buffer_changes = self.ignore_next_buffer_changes + 1
  vim.api.nvim_buf_set_lines(self.buffer, 0, -2, false, new_buffer_lines)

  -- Unset the `modified` status of the buffer after updating it, so we can
  -- close it without throwing a "No write since last change" error.
  vim.api.nvim_set_option_value('modified', false, { buf = self.buffer })

  if mode == 'i' then
    -- Neovim likes to scroll the window when updating the buffer content in
    -- insert mode, so this is required to keep the prompt at the bottom.
    self.ignore_next_mode_changes = self.ignore_next_mode_changes + 2
    nvim_feed_termcodes('<c-o>zb')
  end

  self:highlight()
end

function Commander:highlight()
  vim.api.nvim_buf_clear_namespace(self.buffer, NAMESPACE_ID, 0, -1)

  if vim.api.nvim_get_mode().mode ~= 'i' then
    return
  end

  if not self.path[#self.path].lazy and self.num_commands > 0 then
    -- -1 for prompt
    -- -1 since `nvim_buf_add_highlight` is 0-index
    local focused_row = vim.api.nvim_buf_line_count(self.buffer) - self.focused_index - 1
    vim.api.nvim_buf_add_highlight(self.buffer, NAMESPACE_ID, 'FocusedIndex', focused_row, 0, -1)
  end

  local window_height = vim.api.nvim_win_get_height(self.window)
  local has_overflow = self.num_commands + 1 > window_height

  if has_overflow then
    vim.api.nvim_buf_add_highlight(self.buffer, NAMESPACE_ID, 'OverflowEllipses', 0, 0, -1)
  end
end

function Commander:focus(index)
  local window_height = vim.api.nvim_win_get_height(self.window)
  local has_overflow = self.num_commands + 1 > window_height
  local num_focusable_commands = has_overflow and window_height - 2 or self.num_commands
  self.focused_index = ((index - 1) % num_focusable_commands) + 1
  self:highlight()
end

function Commander:select(index, persist)
  local command = self.commands[index]

  if command == nil then
    return
  end

  -- Restore the parent window before calling our callback function, just in
  -- case it expects the current window to be the parent.
  vim.api.nvim_set_current_win(self.parent_window)

  local subtree = command.callback()

  if subtree ~= nil then
    vim.api.nvim_set_current_win(self.window)
    table.insert(self.path, subtree)
    self:refresh()
  elseif not persist then
    self:close()
  end
end

function Commander:open()
  self.path = { root_commands }
  self:refresh()

  self.window = vim.api.nvim_open_win(self.buffer, true, {
    relative = 'win',
    win = self.parent_window,
    anchor = 'SW',
    border = { '', { '-', 'WinSeparator' }, '', '', '', '', '', '' },
    col = 0,
    row = vim.api.nvim_win_get_height(self.parent_window),
    width = vim.api.nvim_win_get_width(self.parent_window),
    height = MAX_WINDOW_HEIGHT,
  })

  vim.api.nvim_win_set_hl_ns(self.window, NAMESPACE_ID)
end

function Commander:close()
  vim.api.nvim_set_current_win(self.parent_window)
  vim.api.nvim_win_hide(self.window)
  self.window = -1
end

function Commander:destroy()
  if vim.api.nvim_win_is_valid(self.window) then
    vim.api.nvim_win_close(self.window, true)
    vim.api.nvim_buf_delete(self.buffer, {})
  end

  self.window = -1
  self.buffer = -1
end

-- -----------------------------------------------------------------------------
-- Return
-- -----------------------------------------------------------------------------

return function(parent_window)
  local commander = setmetatable({
    buffer = vim.api.nvim_create_buf(false, false),
    window = -1,
    parent_window = parent_window,

    path = { root_commands },
    raw_commands = {},
    commands = {},
    num_commands = 0,
    focused_index = 1,

    ignore_next_buffer_changes = 0,
    ignore_next_mode_changes = 0,
  }, { __index = Commander })

  vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = commander.buffer })
  vim.api.nvim_set_option_value('buftype', 'prompt', { buf = commander.buffer })
  vim.api.nvim_set_option_value('buflisted', false, { buf = commander.buffer })
  vim.api.nvim_set_option_value('swapfile', false, { buf = commander.buffer })
  vim.fn.prompt_setprompt(commander.buffer, '')

  local focus_previous = function() commander:focus(commander.focused_index - 1) end
  local focus_next = function() commander:focus(commander.focused_index + 1) end

  -- Reverse directions to match bottom prompt
  nvim_buf_keymap(commander.buffer, 'i', '<S-Tab>', focus_previous)
  nvim_buf_keymap(commander.buffer, 'i', '<down>', focus_previous)
  nvim_buf_keymap(commander.buffer, 'i', '<c-n>', focus_previous)
  nvim_buf_keymap(commander.buffer, 'i', '<Tab>', focus_next)
  nvim_buf_keymap(commander.buffer, 'i', '<up>', focus_next)
  nvim_buf_keymap(commander.buffer, 'i', '<c-p>', focus_next)

  nvim_buf_keymap(commander.buffer, 'n', 'i', function()
    vim.cmd('startinsert!')
  end)

  nvim_buf_keymap(commander.buffer, 'i', '<cr>', function()
    if commander.path[#commander.path].lazy then
      commander:filter()
    else
      commander:select(commander.focused_index)
    end
  end)

  nvim_buf_keymap(commander.buffer, 'n', '<cr>', function()
    local buffer_line = vim.api.nvim_win_get_cursor(commander.window)[1]
    commander:select(commander.num_commands - buffer_line + 1)
  end)

  nvim_buf_keymap(commander.buffer, 'i', '<m-cr>', function()
    if not commander.path[#commander.path].lazy then
      commander:select(commander.focused_index, true)
    end
  end)

  nvim_buf_keymap(commander.buffer, 'n', '<m-cr>', function()
    local buffer_line = vim.api.nvim_win_get_cursor(commander.window)[1]
    commander:select(commander.num_commands - buffer_line + 1, true)
  end)

  nvim_buf_keymap(commander.buffer, 'n', '<esc>', function()
    if #commander.path == 1 then
      commander:close()
    else
      table.remove(commander.path)
      commander:refresh()
    end
  end)

  vim.api.nvim_buf_attach(commander.buffer, false, {
    on_lines = function()
      vim.schedule(function() -- use `vim.schedule` to update only after `textlock` is removed
        if commander.ignore_next_buffer_changes > 0 then
          commander.ignore_next_buffer_changes = commander.ignore_next_buffer_changes - 1
        elseif not commander.path[#commander.path].lazy then
          commander.focused_index = 1
          commander:filter()
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd('ModeChanged', {
    group = 'bsuth',
    buffer = commander.buffer,
    callback = function()
      if commander.ignore_next_mode_changes > 0 then
        commander.ignore_next_mode_changes = commander.ignore_next_mode_changes - 1
      else
        commander:render()
      end
    end,
  })

  return commander
end
