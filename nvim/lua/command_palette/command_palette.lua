local root_commands = require('command_palette.commands')
local settings = require('command_palette.settings')
local nvim_buf_keymap = require('lib.nvim').nvim_buf_keymap
local nvim_feed_termcodes = require('lib.nvim').nvim_feed_termcodes
local string = require('lib.stdlib').string
local table = require('lib.stdlib').table

local M = {}

---@param command_palette CommandPalette
---@return number
function M.resize(command_palette)
  -- Add +1 for prompt
  local window_height = math.min(command_palette.num_filtered_commands + 1, settings.MAX_WINDOW_HEIGHT)
  vim.api.nvim_win_set_height(command_palette.window, window_height)
  return window_height
end

---@param command_palette CommandPalette
function M.highlight(command_palette)
  vim.api.nvim_buf_clear_namespace(command_palette.buffer, settings.NAMESPACE_ID, 0, -1)

  if vim.api.nvim_get_mode().mode ~= 'i' then
    return
  end

  local head = command_palette.path[#command_palette.path]

  if not head.lazy and command_palette.num_filtered_commands > 0 then
    -- -1 since `nvim_buf_add_highlight` is 0-index
    local focused_row = vim.api.nvim_buf_line_count(command_palette.buffer) - command_palette.focused_index - 1

    vim.hl.range(
      command_palette.buffer,
      settings.NAMESPACE_ID,
      'FocusedIndex',
      { focused_row, 0 },
      { focused_row, -1 }
    )
  end

  local window_height = vim.api.nvim_win_get_height(command_palette.window)
  local has_overflow = command_palette.num_filtered_commands + 1 > window_height

  if has_overflow then
    vim.hl.range(
      command_palette.buffer,
      settings.NAMESPACE_ID,
      'OverflowEllipses',
      { 0, 0 },
      { 0, -1 }
    )
  end
end

---@param command_palette CommandPalette
function M.render(command_palette)
  local window_height = M.resize(command_palette)
  local mode = vim.api.nvim_get_mode().mode
  local has_overflow = mode == 'i' and command_palette.num_filtered_commands + 1 > window_height

  local new_buffer_lines = {}

  for i = 1, has_overflow and window_height - 2 or command_palette.num_filtered_commands do
    table.insert(new_buffer_lines, command_palette.filtered_commands[i].label)
  end

  if has_overflow then
    table.insert(new_buffer_lines, '...')
  end

  table.reverse(new_buffer_lines) -- reverse the buffer lines since our prompt is at the bottom

  command_palette.ignore_next_buffer_changes = command_palette.ignore_next_buffer_changes + 1
  vim.api.nvim_buf_set_lines(command_palette.buffer, 0, -2, false, new_buffer_lines)

  -- Unset the `modified` status of the buffer after updating it, so we can
  -- close it without throwing a "No write since last change" error.
  vim.api.nvim_set_option_value('modified', false, { buf = command_palette.buffer })

  if mode == 'i' then
    -- Neovim likes to scroll the window when updating the buffer content in
    -- insert mode, so this is required to keep the prompt at the bottom.
    command_palette.ignore_next_mode_changes = command_palette.ignore_next_mode_changes + 2
    nvim_feed_termcodes('<c-o>zb')
  end

  M.highlight(command_palette)
end

---@param command_palette CommandPalette
function M.filter(command_palette)
  local text = string.trim(vim.api.nvim_buf_get_lines(command_palette.buffer, -2, -1, false)[1])
  local head = command_palette.path[#command_palette.path]

  if text == '' then
    command_palette.filtered_commands = command_palette.commands
    command_palette.num_filtered_commands = #command_palette.filtered_commands
    M.render(command_palette)
    return
  elseif head.lazy then
    command_palette.filtered_commands = head.callback(text)
    command_palette.num_filtered_commands = #command_palette.filtered_commands
    M.render(command_palette)
    return
  end

  command_palette.filtered_commands = {}
  command_palette.num_filtered_commands = 0

  local tokens = table.map(string.split(text), function(token)
    return { pattern = token, case_sensitive = token:find('[A-Z]') }
  end)

  for _, command in ipairs(command_palette.commands) do
    local command_label_lower = command.label:lower()

    local is_valid_command = not table.find(tokens, function(token)
      local label = token.case_sensitive and command.label or command_label_lower
      return not label:find(token.pattern)
    end)

    if is_valid_command then
      command_palette.num_filtered_commands = command_palette.num_filtered_commands + 1
      command_palette.filtered_commands[command_palette.num_filtered_commands] = command
    end
  end

  M.render(command_palette)
end

---@param command_palette CommandPalette
function M.refresh(command_palette)
  local head = command_palette.path[#command_palette.path]
  command_palette.commands = head.callback()

  if vim.api.nvim_get_mode().mode ~= 'i' then
    command_palette.ignore_next_mode_changes = command_palette.ignore_next_mode_changes + 1
    vim.cmd('startinsert!')
  end

  vim.schedule(function() -- use `vim.schedule` to properly detect insert mode
    vim.api.nvim_buf_set_lines(command_palette.buffer, -2, -1, false, { '' })

    -- Manually trigger the first lazy filter, since we do not filter
    -- automatically on buffer change for lazy commands.
    if head.lazy then
      M.filter(command_palette)
    end
  end)
end

---@param command_palette CommandPalette
---@param shift number
function M.focus(command_palette, shift)
  local window_height = vim.api.nvim_win_get_height(command_palette.window)
  local has_overflow = command_palette.num_filtered_commands + 1 > window_height
  local num_focusable_commands = has_overflow and window_height - 2 or command_palette.num_filtered_commands
  command_palette.focused_index = ((command_palette.focused_index + shift - 1) % num_focusable_commands) + 1
  M.highlight(command_palette)
end

---@param command_palette CommandPalette
function M.select(command_palette, index, persist)
  local command = command_palette.filtered_commands[index]

  if command == nil then
    return
  end

  -- Restore the parent window before calling our callback function, just in
  -- case it expects the current window to be the parent.
  vim.api.nvim_set_current_win(command_palette.parent_window)

  local generator = command.callback()

  if generator ~= nil then
    vim.api.nvim_set_current_win(command_palette.window)
    table.insert(command_palette.path, generator)
    M.refresh(command_palette)
  elseif not persist then
    M.close(command_palette)
  end
end

---@param command_palette CommandPalette
function M.open(command_palette)
  command_palette.path = { root_commands }
  M.refresh(command_palette)

  command_palette.window = vim.api.nvim_open_win(command_palette.buffer, true, {
    win = command_palette.parent_window,
    split = 'below',
    height = settings.MAX_WINDOW_HEIGHT,
  })

  vim.api.nvim_win_set_hl_ns(command_palette.window, settings.NAMESPACE_ID)
end

---@param command_palette CommandPalette
function M.close(command_palette)
  vim.api.nvim_set_current_win(command_palette.parent_window)
  vim.api.nvim_win_hide(command_palette.window)
  command_palette.window = -1
end

---@param command_palette CommandPalette
function M.destroy(command_palette)
  if vim.api.nvim_win_is_valid(command_palette.window) then
    vim.api.nvim_win_close(command_palette.window, true)
    vim.api.nvim_buf_delete(command_palette.buffer, {})
  end

  command_palette.window = -1
  command_palette.buffer = -1
end

---@param parent_window number
---@return CommandPalette
function M.create(parent_window)
  ---@type CommandPalette
  local command_palette = {
    buffer = vim.api.nvim_create_buf(false, false),
    window = -1,
    parent_window = parent_window,
    path = { root_commands },
    commands = {},
    filtered_commands = {},
    num_filtered_commands = 0,
    focused_index = 1,
    ignore_next_buffer_changes = 0,
    ignore_next_mode_changes = 0,
  }

  vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = command_palette.buffer })
  vim.api.nvim_set_option_value('buftype', 'prompt', { buf = command_palette.buffer })
  vim.api.nvim_set_option_value('buflisted', false, { buf = command_palette.buffer })
  vim.api.nvim_set_option_value('swapfile', false, { buf = command_palette.buffer })
  vim.fn.prompt_setprompt(command_palette.buffer, '')

  local focus_previous = function() M.focus(command_palette, -1) end
  local focus_next = function() M.focus(command_palette, 1) end

  -- Reverse directions to match bottom prompt
  nvim_buf_keymap(command_palette.buffer, 'i', '<S-Tab>', focus_previous)
  nvim_buf_keymap(command_palette.buffer, 'i', '<down>', focus_previous)
  nvim_buf_keymap(command_palette.buffer, 'i', '<c-n>', focus_previous)
  nvim_buf_keymap(command_palette.buffer, 'i', '<Tab>', focus_next)
  nvim_buf_keymap(command_palette.buffer, 'i', '<up>', focus_next)
  nvim_buf_keymap(command_palette.buffer, 'i', '<c-p>', focus_next)

  nvim_buf_keymap(command_palette.buffer, 'n', 'i', function()
    vim.cmd('startinsert!')
  end)

  nvim_buf_keymap(command_palette.buffer, 'i', '<cr>', function()
    if command_palette.path[#command_palette.path].lazy then
      M.filter(command_palette)
    else
      M.select(command_palette, command_palette.focused_index)
    end
  end)

  nvim_buf_keymap(command_palette.buffer, 'n', '<cr>', function()
    local buffer_line = vim.api.nvim_win_get_cursor(command_palette.window)[1]
    M.select(command_palette, command_palette.num_filtered_commands - buffer_line + 1)
  end)

  nvim_buf_keymap(command_palette.buffer, 'i', '<m-cr>', function()
    if not command_palette.path[#command_palette.path].lazy then
      M.select(command_palette, command_palette.focused_index, true)
    end
  end)

  nvim_buf_keymap(command_palette.buffer, 'n', '<m-cr>', function()
    local buffer_line = vim.api.nvim_win_get_cursor(command_palette.window)[1]
    M.select(command_palette, command_palette.num_filtered_commands - buffer_line + 1, true)
  end)

  nvim_buf_keymap(command_palette.buffer, 'n', '<esc>', function()
    if #command_palette.path == 1 then
      M.close(command_palette)
    else
      table.remove(command_palette.path)
      M.refresh(command_palette)
    end
  end)

  vim.api.nvim_buf_attach(command_palette.buffer, false, {
    on_lines = function()
      vim.schedule(function() -- use `vim.schedule` to update only after `textlock` is removed
        if command_palette.ignore_next_buffer_changes > 0 then
          command_palette.ignore_next_buffer_changes = command_palette.ignore_next_buffer_changes - 1
        elseif not command_palette.path[#command_palette.path].lazy then
          command_palette.focused_index = 1
          M.filter(command_palette)
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd('ModeChanged', {
    group = 'bsuth',
    buffer = command_palette.buffer,
    callback = function()
      if command_palette.ignore_next_mode_changes > 0 then
        command_palette.ignore_next_mode_changes = command_palette.ignore_next_mode_changes - 1
      else
        M.render(command_palette)
      end
    end,
  })

  return command_palette
end

return M
