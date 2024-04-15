local root_command = require('command_tree.root_command')
local nvim_buf_keymap = require('utils.nvim').nvim_buf_keymap
local nvim_feed_termcodes = require('utils.nvim').nvim_feed_termcodes
local string = require('utils.stdlib').string
local table = require('utils.stdlib').table
local onedark = require('utils.onedark')

local MAX_WINDOW_HEIGHT = 16

local NAMESPACE_ID = vim.api.nvim_create_namespace('')
vim.api.nvim_set_hl(NAMESPACE_ID, 'OverflowEllipses', { fg = onedark.grey })
vim.api.nvim_set_hl(NAMESPACE_ID, 'FocusedIndex', { fg = onedark.cyan })

local CommandTree = {}

-- -----------------------------------------------------------------------------
-- Methods
-- -----------------------------------------------------------------------------

function CommandTree:refresh()
  self.raw_commands = self.path[#self.path].callback()

  vim.api.nvim_buf_set_name(
    self.buffer,
    table.concat(table.map(self.path, function(command)
      return command.label
    end), '.')
  )

  self.ignore_next_mode_changes = self.ignore_next_mode_changes + 1
  vim.cmd('startinsert!')

  vim.schedule(function() -- use `vim.schedule` to properly detect insert mode
    vim.api.nvim_buf_set_lines(self.buffer, -2, -1, false, { '' })
  end)
end

function CommandTree:filter()
  local text = string.trim(vim.api.nvim_buf_get_lines(self.buffer, -2, -1, false)[1])

  if text:match('^%s*$') then
    self.commands = self.raw_commands
    self.num_commands = #self.raw_commands
    self:render()
    return
  end

  self.commands = {}
  self.num_commands = 0

  local tokens = table.map(string.split(text), function(token)
    local is_valid_pattern = pcall(function()
      token:match(token)
    end)

    return {
      raw = token,
      pattern = is_valid_pattern and token or string.escape(token),
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

function CommandTree:render()
  local window_height = math.min(
    self.num_commands + 1, -- + 1 for prompt
    math.floor(0.4 * vim.api.nvim_win_get_height(self.restore_window)),
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
  vim.api.nvim_buf_set_option(self.buffer, 'modified', false)

  if mode == 'i' then
    -- Neovim likes to scroll the window when updating the buffer content in
    -- insert mode, so this is required to keep the prompt at the bottom.
    self.ignore_next_mode_changes = self.ignore_next_mode_changes + 2
    nvim_feed_termcodes('<c-o>zb')
  end

  self:highlight()
end

function CommandTree:highlight()
  vim.api.nvim_buf_clear_namespace(self.buffer, NAMESPACE_ID, 0, -1)

  if vim.api.nvim_get_mode().mode ~= 'i' then
    return
  end

  if self.num_commands > 0 then
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

function CommandTree:focus(index)
  local window_height = vim.api.nvim_win_get_height(self.window)
  local has_overflow = self.num_commands + 1 > window_height
  local num_focusable_commands = has_overflow and window_height - 2 or self.num_commands
  self.focused_index = ((index - 1) % num_focusable_commands) + 1
  self:highlight()
end

function CommandTree:select(index)
  local command = self.commands[index]

  if command == nil then
    return
  end

  if command.type == 'tree' then
    table.insert(self.path, command)
    self:refresh()
  elseif command.type == 'persist' then
    vim.api.nvim_set_current_win(self.restore_window)
    command.callback()
  else
    self:close()
    command.callback()
  end
end

function CommandTree:open()
  self.path = { root_command }
  self:refresh()

  self.window = vim.api.nvim_open_win(self.buffer, true, {
    relative = 'win',
    win = self.restore_window,
    anchor = 'SW',
    border = { '', { '-', 'WinSeparator' }, '', '', '', '', '', '' },
    col = 0,
    row = vim.api.nvim_win_get_height(self.restore_window),
    width = vim.api.nvim_win_get_width(self.restore_window),
    height = MAX_WINDOW_HEIGHT,
  })

  vim.api.nvim_win_set_hl_ns(self.window, NAMESPACE_ID)
end

function CommandTree:close()
  vim.api.nvim_set_current_win(self.restore_window)
  vim.api.nvim_win_hide(self.window)
  self.window = -1
end

function CommandTree:destroy()
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

return function(restore_window)
  local command_tree = setmetatable({
    buffer = vim.api.nvim_create_buf(false, false),
    window = -1,
    restore_window = restore_window,

    path = { root_command },
    raw_commands = {},
    commands = {},
    num_commands = 0,
    focused_index = 1,

    ignore_next_buffer_changes = 0,
    ignore_next_mode_changes = 0,
  }, { __index = CommandTree })

  vim.api.nvim_buf_set_option(command_tree.buffer, 'buftype', 'prompt')
  vim.api.nvim_buf_set_option(command_tree.buffer, 'swapfile', false)
  vim.fn.prompt_setprompt(command_tree.buffer, '')

  local focus_previous = function() command_tree:focus(command_tree.focused_index - 1) end
  local focus_next = function() command_tree:focus(command_tree.focused_index + 1) end

  -- Reverse directions to match bottom prompt
  nvim_buf_keymap(command_tree.buffer, 'i', '<S-Tab>', focus_previous)
  nvim_buf_keymap(command_tree.buffer, 'i', '<down>', focus_previous)
  nvim_buf_keymap(command_tree.buffer, 'i', '<c-n>', focus_previous)
  nvim_buf_keymap(command_tree.buffer, 'i', '<Tab>', focus_next)
  nvim_buf_keymap(command_tree.buffer, 'i', '<up>', focus_next)
  nvim_buf_keymap(command_tree.buffer, 'i', '<c-p>', focus_next)

  nvim_buf_keymap(command_tree.buffer, 'n', 'i', function()
    vim.cmd('startinsert!')
  end)

  nvim_buf_keymap(command_tree.buffer, 'i', '<cr>', function()
    command_tree:select(command_tree.focused_index)
  end)

  nvim_buf_keymap(command_tree.buffer, 'n', '<cr>', function()
    local buffer_line = vim.api.nvim_win_get_cursor(command_tree.window)[1]
    command_tree:select(command_tree.num_commands - buffer_line + 1)
  end)

  nvim_buf_keymap(command_tree.buffer, 'n', '<esc>', function()
    if #command_tree.path == 1 then
      command_tree:close()
    else
      table.remove(command_tree.path)
      command_tree:refresh()
    end
  end)

  vim.api.nvim_buf_attach(command_tree.buffer, false, {
    on_lines = function()
      vim.schedule(function() -- use `vim.schedule` to update only after `textlock` is removed
        if command_tree.ignore_next_buffer_changes > 0 then
          command_tree.ignore_next_buffer_changes = command_tree.ignore_next_buffer_changes - 1
        else
          command_tree.focused_index = 1
          command_tree:filter()
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd('ModeChanged', {
    group = 'bsuth',
    buffer = command_tree.buffer,
    callback = function()
      if command_tree.ignore_next_mode_changes > 0 then
        command_tree.ignore_next_mode_changes = command_tree.ignore_next_mode_changes - 1
      else
        command_tree:render()
      end
    end,
  })

  command_tree:open()
  return command_tree
end
